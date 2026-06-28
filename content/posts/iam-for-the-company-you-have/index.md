+++
date = '2026-06-07T10:00:00-07:00'
draft = false
title = "You'll Never Be Greenfield: IAM for the Company You Actually Have"
aliases = []
description = "There is no single perfect IAM setup, and you will never get the unlimited budget or the greenfield to build one. What 'good' looks like depends on your company's size and stage. The real skill is knowing which identity investment to make next, and which to skip until later."
categories = ['Security', 'Leadership']
tags = ['Security', 'IAM', 'Identity', 'SSO', 'Least Privilege', 'Access Management', 'CISO', 'Startups', 'RBAC']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

I started writing a different post. It was going to lay out the perfect IAM stack, configured the way I would do it with no constraints: the identity provider, the provisioning pipeline, the policy engine, just-in-time access to everything. I got three paragraphs in and deleted them, because the premise was broken. There is no unlimited IAM budget. There is no greenfield. And "perfect" means one thing at a fifteen-person company and something else entirely at fifteen hundred.

The useful question was never what perfect IAM looks like. It is what good IAM looks like for the company you actually have today, and what you should buy next.

## There Is Already a Ladder

Identity has no shortage of maturity models, and they are worth knowing before you invent your own.

[Gartner's IAM Program Maturity Model](https://www.gartner.com/en/documents/1203314) sorts a program into five levels, from Initial (ad hoc, no real process) up through Defined, Managed, and Operational Excellence to Transformational, where governance and architecture are tuned for business value. It measures the maturity of your program and process, and it lives behind a Gartner paywall, which is the most Gartner thing about it. The [CISA Zero Trust Maturity Model](https://www.cisa.gov/zero-trust-maturity-model) is more concrete on the technical side: its identity pillar runs through four stages, Traditional, Initial, Advanced, and Optimal. Traditional is passwords and static access. Optimal is continuous, risk-based authentication with automated, real-time policy. Both models are good, and both describe the rungs well.

What neither tells you, because it is not their job, is which rung you should be standing on. Read literally, every maturity model points at the top and implies you should climb to it. That is the part I would push back on. CISA's Optimal stage is exactly right for a bank. It is a waste of money and attention for a thirty-person startup whose largest identity risk is a shared admin login pasted into a Slack DM.

## Right-Sized IAM

The skill worth building is right-sizing: matching your IAM investment to your company's size and stage, and buying the next rung when the pain justifies it.

Two failure modes sit on either side of that. Over-buying early is real and wasteful: the startup that licenses an enterprise identity governance suite at twenty people and never deploys it, because there is no joiner-mover-leaver volume to govern and no one to run it. Under-buying late is more common and more dangerous: the eight-hundred-person company still sharing a root credential because it has always worked, right up until it doesn't.

The rest of this is the ladder I would actually climb, by size, with the trigger that tells you it is time for the next rung.

| Stage | Headcount (rough) | What "good" looks like | The trigger to level up |
|-------|-------------------|------------------------|--------------------------|
| Seed | 1–20 | Shared password manager, MFA on every app that supports it, no shared personal logins | Offboarding means hunting through a dozen apps by hand |
| Growth | 20–100 | SSO and an IdP, MFA centralized, a named owner for identity | A customer questionnaire asks who can reach production, and you can't answer |
| Scale | 100–500 | Automated provisioning (SCIM), joiner-mover-leaver lifecycle, RBAC, automated deprovisioning | Access reviews become a recurring burden and least-privilege gaps become audit findings |
| Enterprise | 500+ | Least privilege, just-in-time elevation, PAM, access certifications, risk-based auth | One compromised over-privileged account can damage the whole company |

### Seed: A Password Manager Is Enough (roughly 1–20 people)

At the start there is no SSO, and that is fine. People log into apps directly. Good here is cheap and modest: a shared password manager so credentials live somewhere other than spreadsheets and chat, MFA turned on for every app that supports it (email and the cloud console first), and a hard rule that nobody shares a personal login. That is the whole program. It is CISA's Traditional stage, and at this size Traditional is correct. An identity provider now would cost more than it returns, because you have six apps and everyone needs all of them.

The trigger to level up is when onboarding and offboarding start to hurt. The day a departing employee means manually hunting through a dozen apps to revoke access, and you are not confident you got them all, the manual model has run out of road.

### Growth: When SSO Pays for Itself (roughly 20–100 people)

SSO is the first real investment, and it pays off on a specific equation: number of apps times number of employees. At fifty people across thirty apps, that is fifteen hundred access relationships nobody is tracking by hand, and every departure is a chance to leave one open. Past a certain product of those two numbers, manual provisioning and the risk of a missed offboarding cost more than an identity provider does. Stand up an IdP, with Okta, Entra ID, or Google Workspace as the directory, put MFA behind it, and give identity a named owner instead of leaving it as everyone's part-time job.

This is also where the thing most founders worry about becomes structural. People wear many hats and accumulate access from every project they touch, and nobody takes it away. That is tolerable for now, but start naming it as debt, because the next stage is about paying it down. The trigger is access sprawl made visible, usually by a customer security questionnaire or an auditor asking the question you cannot answer: who can reach production?

### Scale: When You Can't Offboard by Hand (roughly 100–500 people)

Now the lifecycle becomes the work. Automated provisioning through SCIM, a real joiner-mover-leaver process, role-based access so that what a back-end engineer gets is defined once instead of negotiated per hire, and automated deprovisioning so that leaving the company actually removes access everywhere. This is where the broad-access debt from the growth stage gets paid down with role design. On CISA's ladder you are moving from Initial toward Advanced.

The trigger is that access reviews stop being a once-a-year annoyance and become a recurring burden, and least-privilege gaps start showing up as audit findings instead of hypotheticals.

### Enterprise: Where Least Privilege Is Worth the Overhead (roughly 500+ people)

This is the stage everyone pictures when they imagine perfect IAM, and it is the only stage where the picture is correct. Least privilege enforced rather than aspired to, [just-in-time elevation instead of standing admin](/posts/break-glass-without-the-backdoor/), privileged access management, access certifications, and authentication that adapts to risk and context. CISA calls the top of this Optimal. It is expensive and operationally heavy, and at this scale it is worth it, because the blast radius of a single compromised over-privileged account is now large enough that the governance overhead is cheap by comparison.

I have written about the far end of this ladder before: [access reviews that run on telemetry instead of quarterly attestation](/posts/telemetry-driven-access-reviews/), and [why both human and agent access should be scoped to capabilities rather than broad roles](/posts/agents-need-capabilities-not-roles/). Both assume you are already here. The trigger to invest is scale and regulation arriving at the same time.

## Let the Pain Set the Pace

The pattern across all four stages is that the right time to invest is set by a trigger you can name, not by a vendor's roadmap. Each rung has a specific operational pain that means it is time: the missed offboarding, the unanswerable production-access question, the audit finding, the company-wide blast radius. Buy the next rung when that pain arrives, and let the cost of staying on the current rung justify the cost of the next one. The salesperson will always tell you it is time. The pain tells you the truth.

## When the Stages Don't Apply

This is a heuristic, not a law, and the exceptions are real.

Some companies are regulated from day one. A ten-person health-tech startup handling patient data needs SSO, audit logging, and real access controls that a ten-person clothing brand does not, because HIPAA does not care about your headcount. For them, compliance sets the floor, and they will skip stages the rest of us climb. The same goes for fintech and for anyone selling into regulated buyers early.

Acquisitions reset the clock. You inherit someone else's stage, often a different one than yours, and merging the two is its own project. And "good for your stage" still carries debt. You are never done, and every stage is imperfect on purpose, because the imperfections that are cheap to tolerate now are the ones you are deliberately deferring.

One number is worth keeping in view while you right-size down. The [Identity Defined Security Alliance](https://www.idsalliance.org/) reports that 94% of organizations have had an identity-related breach, and that 99% of those were preventable. Most of the preventable ones came down to the cheap, early controls: MFA, fast deprovisioning, no shared credentials. Right-sizing down means deferring the expensive rungs, not skipping the basics. The basics are stage zero, and they are not optional at any size.

## Almost Nobody Is Right-Sized

The clean ladder makes it sound like companies climb in step with their growth. Almost none of them do. Most companies are mis-sized, and the mismatch runs one direction far more than the other: large companies running small-company IAM. Identity work gets deferred because it rarely blocks shipping product, so growth outpaces it, year after year.

And the gap compounds. Every year of growth adds identities, systems, integrations, and standing grants, so the cleanup that would have taken a quarter at a hundred people takes a year at a thousand. Audits get harder on the same curve: more accounts to review, more systems in scope, more evidence to produce, and more places a gap can hide. Identity debt does not sit still. It accrues interest.

So the honest version of right-sizing is that most readers are not picking the next rung from a comfortable position. They are behind, and trying to catch up while the target keeps moving. That case deserves its own playbook.

## Digging Out of Identity Debt

When you are already large and carrying years of debt, you cannot do a big-bang remediation, and the neat ladder order is a luxury you no longer have. You triage by blast radius, and the climb runs roughly the reverse of the greenfield one.

**See it before you fix it.** You cannot govern what you cannot inventory. Pull telemetry from the identity provider, the cloud, and the systems that matter into one picture of who has access to what and who actually uses it. The inventory is your first deliverable, and it is the first thing an auditor will ask for anyway.

**Stop the bleeding on the crown jewels first.** Do not open with a company-wide RBAC redesign. Start with the smallest set of systems whose compromise would hurt most, production, the cloud root, the customer data store, and kill standing privileged access there: just-in-time elevation, no permanent admin, shared credentials rotated or retired. That is the largest risk reduction per unit of effort you will find.

**Automate deprovisioning before you perfect provisioning.** The dangerous debt is access that should have been removed and was not. Wire up automated deprovisioning, at least for departures and the crown-jewel systems, before you invest in an elegant role model. Removing wrong access matters more than granting right access cleanly.

**Then design roles, in slices.** Once the bleeding is stopped, pay down the structural debt with RBAC and lifecycle automation, one system or one team at a time, highest risk first. Accept a hybrid state for a long time. The goal is to shrink the ungoverned surface every quarter, not to hit a clean end state on a deadline.

**Make the auditor a partner.** You will not be fully governed for a while, and pretending otherwise manufactures the evidence gaps you are trying to close. Show the inventory, the prioritized remediation plan, and measurable progress against it. A documented, in-progress plan backed by [outcomes-based evidence](/posts/grc-engineering/) is a stronger audit posture than a claim of completeness that collapses under sampling.

The order is deliberately upside down from the greenfield ladder. Greenfield builds the system and then operates it. A company in debt has to operate first, contain the worst risk, and build the clean system underneath while everything keeps running. It is slower and less satisfying, and it is the only version that works once you are already big.

## You'll Never Be Greenfield

The post I set out to write assumed a company that does not exist: unlimited budget, no legacy, free to build identity correctly from scratch. Nobody gets that. You get the company you have, at the size it is, with the access debt it already carries and a budget that has other claims on it.

Each rung here has its own depth, and the rest of this series takes them one at a time. Building the ladder runs from getting to a single sign-on and one identity provider, through the joiner-mover-leaver lifecycle and a role model that does not explode, to how an authorization broker makes "no standing access" real, [why transitive permissions stay invisible](/posts/you-can-reach-more-than-you-were-granted/), [when workload identity is within reach and when you are stuck with secrets](/posts/when-you-can-use-workload-identity/), how to govern the machine identities that outnumber your people, how to build break-glass that is not a backdoor, and [zero trust as a sequence](/posts/zero-trust-is-a-sequence/) anchored by [phishing-resistant MFA](/posts/mfa-that-survives-phishing/) and device trust. Running what you have built is its own thread: ending sessions that outlive their accounts, moving from point-in-time to continuous access decisions, and the detections that catch what prevention misses. This post is the overview. Each of those takes one rung and goes deep.

The work was never designing the perfect stack. It is knowing which rung you are on, what good looks like there, and which specific pain means it is time to climb. Get that sequence right and you are never over-built and never dangerously behind. You'll never be greenfield. The work was always the sequencing.

<!-- ON PUBLISH: as each deep-dive goes live, inline-link it in the forward-reference paragraph above. Only link posts already published (avoid 404s).
  Build-the-ladder: one-front-door-one-place-to-revoke (SSO), automate-the-leaver-before-the-joiner (lifecycle), roles-dont-scale-the-way-you-think (roles), authorization-broker-models (broker), you-can-reach-more-than-you-were-granted (DONE), when-you-can-use-workload-identity (DONE), non-human-identities (machine identities), break-glass-without-the-backdoor, zero-trust-is-a-sequence + mfa-that-survives-phishing + trust-the-user-then-the-machine (zero trust / MFA / device).
  Operational thread: logging-out-is-harder-than-logging-in (sessions), identity-is-becoming-continuous (continuous), the-other-half-of-identity-security (detection). -->

