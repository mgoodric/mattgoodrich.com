+++
date = '2026-05-30T12:00:00-07:00'
draft = false
title = "Your Access Review Is Already Stale: Telemetry-Driven Least Privilege"
aliases = []
description = "Most organizations still run access reviews as a quarterly attestation ritual. The telemetry to do them continuously has existed for years; the shift is from evidence of process to evidence of outcomes. AI takes the routine volume, and a named human still signs the call."
categories = ['Security', 'AI', 'Engineering', 'Leadership']
tags = ['Security', 'IAM', 'GRC', 'GRC Engineering', 'Identity', 'Access Reviews', 'Least Privilege', 'Compliance', 'CISO', 'AI', 'JIT', 'Telemetry']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Every quarter, an email arrives. "Please review the access for your team." A manager who hasn't touched a `kubectl` command in two years clicks **Approve** on a list of permissions they don't understand for people whose work they only partially see. Compliance gets its checkbox. Nothing actually changed.

The system that's supposed to catch over-permissioning produced no useful signal. The data to do it well already exists in the systems that grant and serve those permissions. We just keep asking humans to review what telemetry could decide.

This isn't an indictment of access reviews. It's an indictment of how we run them.

## The Quarterly Ritual

Most organizations run access reviews the same way. Manager-driven. Based on a static list of role/group/permission membership. Asking the manager to validate access for direct reports whose day-to-day work the manager only partially sees.

The "LGTM" (Looks Good To Me) rate on these reviews approaches 100% in most orgs I've seen or heard about. There's no real signal in the approvals because there can't be. The manager doesn't have the information to evaluate "should this person have this permission." They have the information to evaluate "is this person still on my team."

Compliance teams know this. They're stuck because the controls framework asks for a periodic review, and a periodic review is what gets provided. The framework wants evidence of process; process is what we generate.

The actual outcome: stale permissions accumulate. Departed teammates' service accounts linger. The Jenkins token from the project that ended in 2023 still has prod write. The contractor who left last year is still in the security group. Everyone sort-of-knows the review is theater. Nobody has a clear path to make it not theater.

## The Data Already Exists

Here's the thing that should bother you. The data to do this well exists. Most of it has existed for years.

**Identity provider telemetry.** SSO/IdP logs from Okta, Entra ID, or whichever vendor you use. Every authentication, every app accessed, every conditional access decision. SCIM/IGA tooling that tracks what's granted, when, by whom.

**Cloud and infrastructure telemetry.** CloudTrail, GCP Audit Logs, Azure Activity Logs: every API call with caller identity. Kubernetes audit logs: every `kubectl` operation by user or service account. Database audit logs (where enabled): every query by user. Vault and secret-manager logs: every secret read with caller identity.

**Application-layer telemetry.** API gateway access logs with bearer-token identity. SaaS admin actions across Salesforce, GitHub, Snowflake. Internal tool authorization decisions. Even custom apps usually emit "user X did Y" somewhere.

The data isn't missing. The data isn't even hard to get. We just don't *use* it to inform the review. We treat the review as a separate exercise that happens on a calendar and produces a snapshot, instead of as a continuous output of the systems that already know who is using what.

## What Telemetry-Driven Least Privilege Looks Like

The shape of the system: continuous evaluation of every (user, permission) pair against actual usage telemetry, with auto-revocation policies for permissions that go stale.

### The Three Questions a Telemetry-Driven Review Answers

For every (user, permission) pair, three questions:

1. **Has it ever been used?** Granted but never used is a clear candidate for revocation.
2. **Has it been used recently?** Used 14 months ago and not since is also a candidate, with a grace period.
3. **Is the usage pattern consistent with the role?** A read-only API key suddenly making writes is an anomaly worth investigating, even if the writes are technically authorized.

A manual quarterly review can't answer any of these reliably. Telemetry can answer all three continuously.

### Continuous, Not Periodic

The system runs every day, not every 90 days. Permissions hit a "stale" threshold (call it 90 days without use) and the user or owner gets a soft notification: *"You have access to X that hasn't been used in 90 days. Keep it or drop it."* Permissions hit a "dormant" threshold (180 days, say) and the system auto-revokes with notification and an easy re-grant flow.

The user still gets a human-in-the-loop moment. It's just targeted, just-in-time, and based on real data instead of being a quarterly batch reviewed at 3 seconds per item.

### Make Re-Granting Cheaper Than Hoarding

This is the make-or-break design decision. If re-granting takes a week, people will hoard permissions out of self-preservation. If re-granting is one command plus a justification plus an automatic approval for low-risk permissions, people will let go of unused permissions because losing them is reversible.

The principle: make the *correct* path easier than the cautious path. If staying over-permissioned is more convenient than re-acquiring access when needed, your system has the wrong incentives by design.

### Anomaly-Driven Investigation, Not Calendar-Driven Review

"User X used a permission they hadn't used in six months" is more interesting than "User X is in the developers group." "Service account Y started writing to a table it had only ever read from" is more interesting than "Service account Y is in the data-pipeline role."

The review isn't a once-a-quarter ritual. It's a continuous stream of signals, with humans in the loop only when the signal is anomalous. The anomalies are where human judgment actually adds value. The membership lists are not.

## The Precondition: No Long-Lived Production Access

The whole picture only works if production access is ephemeral.

Just-in-time elevation via Teleport, AWS SSO temporary creds, OIDC workload identity, break-glass with auto-expiry. No standing prod admin grants. Service accounts using short-lived tokens, not static API keys. When the access expires, the question "is this permission still needed" is asked by *the system* every time someone re-requests it.

Without this precondition, the "use telemetry to expire stale grants" model degrades. Because the dangerous grants are the ones that never expire and are therefore never re-justified. And those are the ones that periodic review fails on too.

The good news is the precondition is achievable. JIT access tooling has matured significantly. The blocker is usually organizational change: the SRE team that's used to having keys, the legacy app that doesn't support workload identity yet, the on-call rotation that needs break-glass for the 3am call. Those are real constraints, but they're contained, not fundamental.

Even with the precondition met, the model has a scope limit worth naming. JIT and short-lived tokens cover production infrastructure well: the cloud, the cluster, the database. They cover less of the rest. SaaS apps that aren't yet behind a JIT broker still hand out standing access. IdP group memberships persist across roles. Service accounts in legacy systems hold static credentials because the legacy systems don't speak workload identity. Break-glass accounts exist on purpose and won't be JIT-mediated.

The realistic outcome is hybrid. JIT shrinks the scope of the periodic review by the size of the JIT-covered estate, which is significant, without eliminating the review entirely, because there is a long tail of access the broker doesn't see. PCI DSS 7.2.4 also hard-codes a six-month review of all user accounts and access privileges regardless of telemetry quality, so for the PCI-scoped portion of the estate that calendar item stays. The honest claim is that telemetry-driven review plus JIT replaces the theater of the quarterly ritual and shrinks the surface area where the ritual still applies, without ever fully eliminating it.

## Where This Lands GRC Engineering and IAM

This is a discipline that sits at the intersection of [GRC engineering](/posts/grc-engineering/) and IAM, and it benefits from being thought about as that intersection rather than as a problem belonging to either side alone.

### For GRC Engineering

Compliance frameworks ask for evidence that access is appropriate. They don't actually mandate manager-clicks-approve, and in most cases they don't even mandate a cadence. SOC 2 CC6.3 says reviews should happen "on a periodic basis" without specifying when. ISO 27001 A.5.18 says access rights are reviewed "at planned intervals," with the interval set by the organization. NIST 800-53 AC-2(j) literally reads "[Assignment: organization-defined frequency]." The frameworks treat cadence as something you decide and defend, not as a fixed calendar requirement. The exception is PCI DSS 7.2.4, which hard-codes six months for human accounts. Everything else is control-objective, not calendar.

A telemetry-driven access review produces *better* evidence: not "manager approved on date X" but "permission Y was unused for Z days and was revoked on date W, with these N exceptions explicitly justified." The auditor wants to know your access is appropriate. Telemetry-driven review answers that question with data instead of with attestation.

This is the GRC-as-code pattern. Stop generating PDFs about controls and start emitting machine-readable assertions about what's actually happening.

### For IAM

The shift is from role-based static grants to [capability-based continuous evaluation](/posts/agents-need-capabilities-not-roles/). Roles still exist as the bundle that gets granted; what changes is that the bundle is evaluated against actual usage and pruned automatically.

The IAM team's job moves from "grant management" to "policy management": defining what stale means, what auto-revoke windows apply to which classes of permission, what the re-grant friction should be per risk tier. The day-to-day operational toil of access reviews disappears, replaced by the work of designing the policies that make the toil unnecessary.

## What This Changes for the Audit Conversation

The audit conversation gets faster and more rigorous at the same time.

"Show me your access review" → here's the dashboard. Live. Every revocation event timestamped and attributed.

"Show me a sample of approvals" → here's every (user, permission) over the last 12 months with last-used date and decision rationale.

"Show me your exception process" → here are the cases where a permission was kept despite being unused, with the human justification on each one.

The auditor stops asking for evidence of a process and starts asking for evidence of *outcomes*, which is what they actually wanted in the first place. Once you can produce outcomes-based evidence, the burden of every audit cycle drops, because you're not assembling evidence packages on an artificial cadence. You're querying a system that already has the answer.

## AI Earns the Triage, Not the Decision

The next practical question is whether AI agents can do the access review. The honest answer, today, is yes for some of it and no for the part that matters.

What auditors will accept is AI doing the triage, the prioritization, the explanation, and the evidence packaging. A model can read 500 (user, permission) tuples, mark the unused ones, write a plain-language justification for each recommended action, and route the actionable ones to a human. Lumos, Veza, Opal, ConductorOne, SailPoint, and Saviynt all ship versions of this today. It produces faster, more consistent evidence than the human-only equivalent.

What auditors will not accept, today, is the agent making the decision unsupervised. The IIA's AI Auditing Framework and ISACA's guidance on AI in audit land in the same place: a named human is accountable for an AI-assisted decision, and the agent's reasoning becomes part of the evidence the human attests to, not a substitute for the attestation. The EU AI Act's Annex III classification reinforces it for any workforce-access decisioning.

The shape that works is the same shape as the rest of this argument. Continuous telemetry runs the program. JIT carries the production load. AI takes the volume of routine decisions and presents them to a human as a short, justified list. The human signs the call. The system is faster and more rigorous, and still has a person on the hook the way every framework requires.

## Why Humans Will Always Lose This Race

The honest argument for the data-over-judgment position.

A manager reviews access for ~10 reports across ~50 systems once a quarter. That's roughly 500 (user, permission) tuples reviewed in maybe 30 minutes. ~3.6 seconds per item. That isn't review. That's a rubber stamp.

Telemetry evaluates the same 500 tuples in 30 milliseconds and never gets bored. More importantly, it knows which of those 500 the user *actually used*. That is information the manager doesn't have and can't reasonably get.

This isn't an argument against human judgment. It's an argument for putting human judgment where it actually matters: the anomalies, the exceptions, the genuinely ambiguous cases. The 5% of decisions that need a person. Not the 95% that need a query.

## What's Hard About This

Worth being honest about the gaps.

**Data quality.** Not every permission system emits clean usage logs. Some permissions are inferred (was this S3 bucket read because of role X or role Y?). Some are missing entirely (legacy apps, on-prem systems that never got modern auditing). Where the data is bad or missing, telemetry-driven review can't help, and you're back to manual review for those slices.

**Permission granularity.** "User has the developer role" is observable. "User has the developer role and used the kubectl-exec capability" requires deeper telemetry plumbing. Coarse permissions are easier to review against; fine-grained capabilities are where the real over-permissioning hides.

**Cross-system correlation.** A user touches Okta, then GitHub, then AWS, then Snowflake. Stitching that into a single "what did they actually use" view is non-trivial. Most orgs haven't connected these views yet.

**Edge cases that look like inactivity.** A permission used once a year for the annual audit looks identical to a forgotten grant. The system needs to support "rare but real" patterns, typically with explicit annotations on the permission itself.

**Service accounts.** [Bot identities](/posts/service-accounts-that-improvise/) don't have managers and don't read notification emails. The lifecycle has to be owned by the team that owns the workload, with automation enforcing rotation and revocation. Many orgs don't have good ownership data on their service accounts to begin with.

None of these are blockers to starting. They're the parts you build out as you mature the system.

## The Access Review Wasn't a Bad Idea

The access review wasn't a bad idea. It was the right idea built for an era when telemetry didn't exist and humans were the only review mechanism. That era ended.

The telemetry exists. The dashboards exist. The auto-revocation tooling exists. The blocker is organizational, not technical: replacing a ritual that everyone agrees is theater is harder than it should be, because the ritual is *legible* to auditors and the new model isn't yet.

GRC engineering is the discipline that makes the new model legible. IAM is the discipline that makes it operational. The two have to meet.

Telemetry-driven least privilege isn't a vision. It's an engineering project that pays back in audit speed, reduced standing privilege, and fewer departing-employee credential leaks. The argument for doing it is the same argument as for any of the things compliance organizations have already accepted in adjacent domains: automated evidence collection, continuous monitoring, GRC-as-code.

The access review was the last big domain that hadn't moved. It's time it moved.
