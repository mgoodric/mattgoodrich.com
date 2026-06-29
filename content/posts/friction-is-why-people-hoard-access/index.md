+++
date = '2026-07-07T00:01:00-07:00'
draft = false
title = 'Friction Is Why People Hoard Access'
aliases = []
description = "Slow access is why environments end up over-provisioned: when a ticket takes three days, the rational move is to hoard every permission you might need and never give it back. Build paved roads instead, fast self-service access with automated approval, and people let go of what they don't need because getting it back is cheap. The environment locks down harder, and security gets the approval chain and audit trail for free."
categories = ['Security', 'Engineering', 'Leadership']
tags = ['Security', 'IAM', 'Identity', 'Least Privilege', 'Just-in-Time Access', 'Developer Experience', 'Access Management', 'Compliance', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

A ticket for production access sits in a queue for three days. The engineer who filed it had a deadline yesterday. So the next time they need anything, they do the rational thing: they ask for everything they might conceivably need, all at once, up front, and then they never give any of it back. Why would they? Asking again costs three more days.

Multiply that across every engineer and every quarter, and you have explained why your environment is over-provisioned. People respond to incentives: the cost of getting access is high and the cost of holding it is zero, so the rational move is to get it once and keep it forever. The hoarding in your access logs is not carelessness. It is a sensible answer to a slow process.

## Friction Is Why People Hoard

Every slow access process teaches the same lesson: get it while you can and keep it as long as you can. A grant that takes a day to obtain is a grant you do not give up, because giving it up means paying that day again. A review queue measured in weeks turns least privilege into a fantasy, because nobody working under a deadline will voluntarily return access they had to wait two weeks for.

The slow gate is the cause of the hoarding. Every barrier built to make access careful — the approval, the review, the wait — taught the engineers under it to keep everything they grabbed. The sprawl is what a slow gate produces, every quarter.

You can see the residue in any access review: the long-tenured engineer who has accumulated read access to half the company, not because anyone decided they should have it, but because every project they ever touched left a grant behind that was easier to keep than to clean up.

![The Friction Feedback Loop: a Slow Request Queue Teaches Engineers to Ask for Everything They Might Need, Which Gets Granted and Then Held Forever Because Returning It Means Waiting Again, Which Shows Up as Sprawl in the Access Logs and Sets Up the Next Request to Behave the Same Way](diagram-friction-feedback-loop.png)

## Make the Easy Path the Safe Path

Flip the economics and the behavior flips with it. When getting access is fast, scoped, and self-service, and getting it back tomorrow is just as fast, people stop hoarding, because there is no reason to. They request what the work in front of them needs, and they let the rest expire, because re-acquiring it is cheap. This is the principle underneath [telemetry-driven access reviews](/posts/telemetry-driven-access-reviews/): make the correct path easier than the cautious one, and people will take it.

The borrowed name for this is the paved road. Platform teams use it for the golden path that makes the right way to build also the easy way. The same idea applies to access: build the paved road to getting permissions, the fast, obvious, self-service route, and make it the route that also happens to be the most locked-down. People take the easy path. The only question worth asking is whether the easy path is the safe one.

## What the Paved Road Is Made Of

A paved road for access is a few concrete things working together.

**A self-service request, not a ticket in a human queue.** The person picks the access they need from a catalog and asks for it in the flow of their work, instead of filing a request and waiting for someone to notice it.

**Automated approval for the low-risk majority.** Most requests are routine, and a policy can approve them in seconds: this role, for this person, on this resource, within these bounds, auto-granted with the decision recorded. Human approval is reserved for the high-risk minority that genuinely needs a person's judgment.

**Instant propagation.** The grant takes effect immediately, through [automated provisioning](/posts/automate-the-leaver-before-the-joiner/), not a nightly sync or a manual step across five systems. Fast to ask is worthless if it is slow to land.

**Short lifetimes with easy renewal.** Access expires on its own, and getting it back is one click. This is what makes letting go safe: you are not surrendering something you will have to fight to recover. For the most sensitive access, the paved road is [just-in-time elevation through a broker](/posts/authorization-broker-models/), where the grant exists only for the task and revokes itself.

**Birthright access for the baseline**, so people never queue for the obvious. The tools everyone in a role needs are granted automatically at the start, so the request path is reserved for the access that actually varies.

Put together, the path looks like this. An engineer needs to read the payments team's production database for a debugging session. They pick it from a self-service catalog; a policy confirms they are on the payments team and that the request is read-only and time-boxed, and auto-approves in seconds; provisioning grants it immediately, scoped to that one database, for eight hours; and when the window closes it expires on its own. Every step, the request, the decision, the grant, and the expiry, lands in the log, and the engineer never filed a ticket.

You assemble most of this from parts that already exist: a broker for the just-in-time grants, SCIM-based provisioning for the propagation, and a policy engine like [OPA](https://www.openpolicyagent.org/) for the auto-approval. The piece you usually build yourself is the self-service catalog and the request workflow that ties them together, and that is where the developer experience is won or lost. If you would rather buy the catalog and workflow than build them, the access-request and just-in-time tools now cover most of this: [Opal](https://opal.dev/), [Apono](https://www.apono.io/), [Lumos](https://www.lumos.com/), [C1](https://www.conductorone.com/) (formerly ConductorOne), [Teleport](https://goteleport.com/), and [BeyondTrust](https://www.beyondtrust.com/), which acquired Entitle.

![Ticket Queue Versus Paved Road: in the Top Row a Request Sits in a Three-Day Human Queue, the Grant Has No Expiry, the Access Is Held Forever, and the Audit Surfaces Orphaned Permissions With No Trail or Justification; in the Bottom Row a Self-Service Request Auto-Approves by Policy, Provisions Instantly, Returns Itself on Expiry, and Every Step Is Logged With a Reason so the Audit Becomes a Single Query](diagram-slow-vs-paved-road.png)

## Start Where the Pain Is

You do not get to the paved road by flipping a switch on everything at once. You get there by paving one road first, the one where the friction is most obviously costing you, and then extending the same pattern outward.

**Start with the worst-friction system you have.** The canonical first target is read access to a production data store, because every engineer needs it sometimes, the wait is long, the request is genuinely low-risk, and the audit trail today is "Slack messages, mostly." Pick one system that fits that shape. Build the self-service request, the auto-approval policy, the time-bound grant, and the expiry on it. One system. Get it working.

**Migrate one team off the slow queue.** Pick a team that is loud about the friction and willing to be the pilot. Their requests for the cataloged system now flow through the paved road; their requests for everything else still go through the old queue. The contrast shows up immediately, and you have a concrete success story for the next conversation.

**Expand the catalog.** Add the next high-friction system, then the next. Each new entry is mostly the workflow code you already wrote, plus the policy for what auto-approves on that system. The platform compounds: the second system takes half the work of the first, the fifth takes a fraction.

**Layer in birthright and just-in-time.** Once the catalog covers most routine requests, identify the access everyone in a role obviously needs and make it birthright (no request at all). At the other end, identify the most sensitive access and remove the standing grant entirely. The catalog now handles the middle, which is most of it.

**Retire the slow queue.** When the paved road covers most requests, the ticket queue is left for the genuinely novel ones, and those are now signal: they tell you the next thing to add to the catalog.

## Security Gets More, Not Less

Every request down the paved road produces exactly what a security and compliance program wants, as a byproduct of the work itself.

There is an approval chain on every grant, automated or human, recording who asked, what policy or person approved it, and why. There is an audit trail of who held what access, when, and for how long, because the system issued it and logged it. There is a justification attached to each request. And there is auto-expiry, so there is far less standing access to certify in the first place, which is the single biggest source of audit findings.

The slow ticket queue produced none of this reliably. It produced a spreadsheet someone assembled the week before the audit, describing access that had drifted for months. The paved road produces the evidence continuously, because the evidence is the same act as the grant. Auditors stop finding orphaned permissions because there are far fewer of them, and the ones that remain have a name, a reason, and an expiry attached. An auditor who samples a grant in a paved-road environment finds the request, the approving policy, the justification, and the expiry on it in a single query. In the ticket-queue environment, the same sample turns up a permission with no record of who approved it or why, and that absence is the finding.

## Speed Without Guardrails Is Just Risk

None of this works if speed is the only goal. A paved road that auto-approves everything fast removes a control rather than adding one, just with better latency. The guardrails are what make the road safe to pave: the risk tiering that decides what auto-approves and what needs a human, the policies that bound what each role can even request, the audit trail, and the expiry. Strip those out and you have built a fast path to over-privilege, which is worse than the slow path, because now it scales.

And the road is real work to build. Self-service catalogs, policy-based approval, automated provisioning, and just-in-time elevation are platform engineering, not a config change, and a half-built road, fast to request but still slow to provision, just relocates the friction without removing it. Some access should also stay slow on purpose. The standing keys to the most dangerous systems deserve a deliberate, human, unhurried decision, and the paved road's answer there is not to speed up the approval but to remove the standing grant entirely. Pave the routine. Guard the exceptional. Do not confuse the two.

## Make It Easy to Lock It Down

Easy access is what makes least privilege survivable for the people living under it. The teams with the most locked-down environments are usually the ones where getting access is the easiest, because friction creates the sprawl that lock-down is supposed to prevent.

So if you want to lock it down, make it easy. Build the paved road, put the guardrails in the road itself, and let people get exactly what they need the moment they need it. They will stop hoarding when hoarding stops being the smart move.
