+++
date = '2026-05-14T09:00:00-07:00'
draft = false
title = "AI Governance, Calibrated: Why the Real Risk Isn't What Most People Think"
aliases = []
description = "Most AI governance discourse is overheated. The destructive-action panic ignores the boring truth that we already have most of the controls we need. The actual gap is narrower and more specific: the identities we grant agents, and the production access handed out alongside them."
categories = ['Security', 'AI', 'Leadership']
tags = ['AI', 'AI Governance', 'Security', 'Identity', 'CISO', 'Risk Management', 'Least Privilege', 'IAM']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Open any LinkedIn feed in 2026 and you'll find someone insisting that AI agents will `rm -rf` production any minute now. The panic case sells. The calibrated case doesn't.

But after twenty-plus years of running and advising on security programs, the destructive-action problem isn't new. We've been protecting production from junior engineers, broken CI pipelines, and admin-token misuse for decades. AI agents inherit all of that protection by default — they're operating inside the same control stack as everything else.

The interesting question isn't whether AI agents can destroy production. It's *what they expose that the existing layer wasn't designed for*. And when you look at the gap honestly, it's much narrower than the discourse suggests — and concentrated in a place most organizations can fix without a brand-new framework.

## What's Already Protected (and Why That Matters)

Take the typical "AI agent destroys production" scenarios that show up in vendor pitch decks. Force-pushes to main. `kubectl delete namespace production`. `DROP TABLE users`. Public S3 buckets. DNS misconfiguration. Permissive IAM policies.

Now look at what an AI agent actually hits when it tries any of those things in a half-decent enterprise security stack:

**Source control.** Branch protection on main and release branches blocks force-pushes and history rewrites. Required reviews mean agents can't merge their own PRs. Secret scanning on push catches credentials before they reach history. Pre-commit hooks add a local guard before anything goes server-side.

**Infrastructure.** Kubernetes RBAC binds service accounts to specific namespaces; nothing has cluster-admin without ceremony. IAM least-privilege means agents inherit whatever role they're assigned, not god-mode. Network policies restrict east-west traffic by default in modern clusters. Cloud budget alerts surface cost anomalies before they become catastrophic.

**Data layer.** Database role separation keeps application accounts distinct from DBA accounts. Backup and point-in-time recovery make `DROP TABLE` recoverable. Schema migration frameworks force DDL through a pipeline rather than ad-hoc connections.

**Change management.** Deployment gates require approvals — even for humans. Staging environments exist specifically so that broken code breaks there first. Audit logs make every action attributable.

An AI agent operating inside this stack hits the same controls a misconfigured Jenkins pipeline does. The agent doesn't get a special pass. The control wasn't designed for AI specifically, but it wasn't designed for AI-shaped risks specifically either — it was designed for "non-human or under-supervised actor with too much access trying to do something destructive," and that description fits a poorly-scoped CI pipeline as well as it fits an AI agent.

The implication: if your existing security stack is in reasonable shape, most of what you need to mitigate AI risk is already in place. You're not starting from zero.

## Where the Existing Layer Falls Short

That doesn't mean there's nothing new. There are three places the existing control layer doesn't fully cover, and they're worth being precise about.

### Prompt Injection Is a Genuinely New Failure Mode

We don't have a 20-year-old control library for "untrusted text in a code comment hijacking the agent's intent." Indirect injection via documents, web content, repo data — these are real attack patterns and they bypass the controls that protect against everything else.

The reason they bypass those controls is subtle: the agent's outbound action looks legitimate. It's authenticated. It's scoped. It's authorized. The *intent* is what's been hijacked, not the credential. A WAF doesn't help. RBAC doesn't help. Branch protection doesn't help. The action is technically allowed; it just isn't the action you wanted.

This is the one category where the security industry needs to build new things. Input sanitization on content the agent processes. Agent isolation that prevents cross-context data access. Monitoring for anomalous agent behavior — unexpected network calls, unusual data access patterns, output that doesn't match the apparent task. Regular adversarial testing of deployed agents.

Some of that exists in early form. None of it is solved.

### Production Write Access Granted Too Generously

The "let the agent write" temptation is the real risk multiplier, and it shows up everywhere because it's easy to justify with a speed-of-iteration argument.

Read-only agents are dramatically lower risk than write-capable agents. And most use cases I see don't actually need write. "Generate a report on production data" doesn't need write. "Review the configuration" doesn't need write. "Suggest a fix" doesn't need write. The cases where an agent genuinely needs to *apply* changes to production are narrow.

When write access genuinely is needed, the question shifts from "can the agent write" to "which specific tables, namespaces, or endpoints, with what row-count limits, behind what approval flow." That's a different conversation. And it's the conversation most organizations skip in favor of granting broad write access because the agent might need it.

### Shared and Over-Scoped Service Accounts

The classic anti-pattern: one "AI Agent" service account with broad scope, used by 12 different agents, owned by a team that doesn't remember granting half the permissions on it.

You can't audit what did what. A single compromise rotates 12 sets of credentials. Access reviews are meaningless because the account isn't tied to a single function. The identity sprawl is the real attack surface — not the LLM itself.

This is a textbook non-human-identity problem. The pattern that fixes it is also textbook. We just keep forgetting to apply it the moment a new tool shows up.

## Identity Guardrails: The Real Mitigation

The framing that ties this together: AI agents are non-human identities operating against your environment. We have a 20-year playbook for non-human identities. Use it.

The guardrails that close most of the gap aren't AI-specific. They're the boring identity-and-access-management hygiene we already know how to do.

### Per-Agent Service Accounts

One agent, one identity, one scope. The identity is the audit unit. If you can't say "agent X did Y," your audit log isn't useful — and you'd be amazed how many "AI governance" programs can't say that today.

Scoped permissions matched to the actual task — not "what we think the agent might need." If the scope expands later, that's a deliberate decision with a paper trail.

### Read-Only by Default in Production

The default permission for a production-touching agent is `SELECT`, `GET`, list, describe. Write access is a separate, deliberate decision per agent, per resource.

"But the agent needs to apply the fix" — does it, or does it propose the fix and a human applies it? Most of the time, propose-and-approve is fine. The cases where end-to-end autonomous write access is genuinely needed are rare enough to justify a slower decision-making process for each one.

### Short-Lived, Auto-Rotating Credentials

Static API tokens for agents are a bad idea even when the agent is well-behaved. Workload identity federation, OIDC tokens, ephemeral credentials via Vault. If the credential lives 15 minutes, exfiltration is a much smaller window. If it lives forever, exfiltration is a much bigger one.

This is the kind of control that pays back disproportionately. You spend the engineering cost once and you get a structurally lower risk surface for every agent that uses the pattern thereafter.

### Rate Limits and Circuit Breakers

Agents loop. They will loop. Plan for it.

Hard caps on operations-per-session, commits-per-hour, resource-creation-per-minute. Circuit breakers that halt the agent and page a human after anomalous behavior. The default failure mode for an unbounded agent is to do something expensive at machine speed for an hour before anyone notices. The default failure mode for a rate-limited agent is to stop and ask for help.

### Tied to a Human Identity

Every agent session traces back to a human owner. Access reviews on the same cadence as human access. This is the boring governance hygiene that nobody wants to do but that makes the entire program defensible to audit.

When the auditor asks "who is responsible for this agent's actions," the answer needs to be a name — not "the AI tooling team."

## A Calibrated Risk Picture

If you take all of the AI risk scenarios that get cited in vendor decks and CISO panels and sort them into three buckets, the picture gets much clearer.

**Already mitigated by existing controls:**

- Force-push to a protected branch — branch protection
- Repo content destruction — required reviews
- Mass PR merge bypass — agents shouldn't have merge perms in the first place
- Schema corruption on production — migration review process
- `kubectl delete namespace production` — Kubernetes RBAC scoping

**Genuinely new and needs new controls:**

- Prompt injection — input sanitization, agent isolation, behavioral monitoring

**Old problem, new actor:**

- `DROP TABLE` on production — same fix as for any non-DBA: read-only role
- Unbounded HPA cost runaway — same fix as for any pipeline: caps plus budget alerts
- DNS modification — same fix as any infrastructure change: change management plus restricted IAM
- Pipeline secret exfiltration via CI config changes — same fix as any untrusted pipeline edit: protected variables and egress restrictions
- IP leakage to external AI providers — same fix as any third-party data flow: DPA plus DLP monitoring
- PII in prompt context sent to AI providers — same fix as any sensitive-data handling: classification and masking before the data leaves your boundary

The first bucket is the one most of the discourse focuses on. It's also the one where the security industry has the most existing answers. Audit your stack and confirm the controls are actually applied. Don't rebuild what works.

The second bucket is where the new investment goes. It's small. It's solvable. It's not existential.

The third bucket is where most organizations actually fail. We know how to do this. We just keep skipping it because the agent is "just helping out" and "we'll formalize the access later."

## What This Means for the Risk Conversation

A few things I'd argue for if you're sitting in the room when this comes up.

Stop pretending AI is a brand-new threat surface that requires a brand-new framework. Most of what you need, you already have. Audit it. Confirm it's applied to non-human identities. Tighten where it isn't.

The genuinely new risk — prompt injection — is a specific, addressable problem. Treat it as a research-and-engineering investment, not as an existential one. The fact that we don't have it solved yet doesn't mean we're paralyzed; it means there's work to do, and the work is bounded.

The biggest preventable risk is over-permissioning. Identity guardrails — least privilege, scoped service accounts, read-only defaults, ephemeral credentials, rate limits — close most of the gap. None of those are exotic. All of them require organizational discipline more than technical sophistication.

The hardest part of any of this is saying "no, this agent doesn't need write access in prod." Saying that is a governance muscle, not a code change. And it's the muscle most organizations haven't built.

## Same Problems, New Actor

The CISO mental model that I've found most useful: AI agents are non-human identities operating against your environment. We have a 20-year playbook for non-human identities. Use it.

Then build the *one* new thing that's actually new: prompt injection defenses. That's the boundary of what this generation of AI risk genuinely demands of the security industry.

That last point is a change of mind. About a year ago I wrote ["AI Governance: Same Problems, Same Solutions"](/posts/ai-governance-same-old-problems/), and I'd still defend the "same problems" half of that title without hesitation — this post is really the more specific version of it. But back then I lumped prompt injection in with everything else: I compared it to SQL injection and said input validation principles would carry over.

I'd put it differently now. SQL injection has a fixed grammar. Prompt injection doesn't — and a year of watching indirect injection work through documents, repo content, and tool output has convinced me it isn't a variation on an old problem. It's the one place "same solutions" doesn't hold yet. The "same problems" framing survived the year. The "same solutions" framing didn't, at least not here.

The discourse will keep being overheated. The frameworks will keep being announced. The vendor decks will keep claiming this is a unique threat surface that requires a unique response. Most of that is wrong, or at least mis-prioritized.

Confident AI adoption, not cautious avoidance. The boring hygiene of scoped identity and rate limiting is the substance of confident adoption. Everything else is a marketing layer on top.
