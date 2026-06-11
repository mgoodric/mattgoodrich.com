+++
date = '2026-06-24T00:01:00-07:00'
draft = false
title = 'Zero Trust Is a Sequence, Not a Posture'
aliases = []
description = "Zero trust gets sold as a posture you either have or don't, and as a product you can buy. It's neither. It's a set of controls that pay off in an order, and most organizations can't reach the end state at once. Here's the sequence and when each piece earns its place."
categories = ['Security', 'Leadership', 'Engineering']
tags = ['Security', 'Zero Trust', 'IAM', 'NIST', 'CISA', 'Identity', 'Least Privilege', 'CISO', 'Architecture']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Zero trust gets sold two wrong ways at once. As a posture, something you either have or do not, usually claimed on a slide. And as a product, something a vendor will sell you that makes you "zero trust" the moment it is deployed. It is neither. Zero trust is a set of controls that pay off in an order, and the useful question is which part you should build next.

## It Is Not a Product

The core idea is old and simple: stop trusting the network. [NIST's 800-207](https://csrc.nist.gov/pubs/sp/800/207/final) defines it as removing implicit trust based on location and verifying every request on its own merits. No vendor sells you that, because it is a property of an architecture, not a feature. You can buy components that help, an identity provider, [an access broker](/posts/authorization-broker-models/), microsegmentation, device posture checks, and you can deploy every one of them and still extend implicit trust somewhere that matters. The product is sometimes necessary and never sufficient.

## The Sequence

CISA's [Zero Trust Maturity Model](https://www.cisa.gov/zero-trust-maturity-model) is more useful than the marketing because it is staged. Each of its pillars moves through Traditional, Initial, Advanced, and Optimal, and the order you mature them in matters more than the labels.

**Identity first.** Everything else in zero trust assumes you can answer "who or what is this" with confidence. Strong authentication, phishing-resistant MFA, one source of identity. If you cannot trust the identity, segmenting the network or scoring the device buys you nothing, because you do not know whose request you are evaluating. This is also the order the [right-sized IAM ladder](/posts/iam-for-the-company-you-have/) implies: identity is the foundation the other controls stand on.

**Then the device.** Once you trust the identity, you start asking about the thing it is coming from: [is it managed, patched, posture-checked](/posts/trust-the-user-then-the-machine/). This is where most programs slow down, because device trust touches every endpoint you have.

**Then least privilege and segmentation.** With trusted identity and device, you can shrink what each one reaches: per-application access instead of network access, microsegmentation, just-in-time elevation. This is where the blast-radius reduction actually happens.

**Then continuous, risk-based evaluation.** The Optimal end state, where every request is scored in real time against context and access is adjusted dynamically. This is genuinely valuable and genuinely expensive, and it is the last thing you build, not the first.

| Stage | What good looks like | Concrete controls | The common mistake |
|-------|----------------------|-------------------|--------------------|
| Identity | You can name who or what made every request | One IdP, phishing-resistant MFA, SSO everywhere, no standing local accounts | Rolling out a product before consolidating identity |
| Device | Access depends on the health of the endpoint | MDM, posture checks, a managed-device requirement on sensitive apps | Trusting devices you do not manage |
| Least privilege | Each identity reaches only what it needs, briefly | Per-app access, microsegmentation, just-in-time elevation, no standing prod admin | Segmenting the network with no identity behind it |
| Continuous | Every request scored in real time against context | Risk-based auth, mid-session re-evaluation, automated response | Buying the risk engine first |

None of these stages needs a zero-trust product, and open source covers a lot of each. For identity, [Keycloak](https://keycloak.org/), [Authentik](https://goauthentik.io/), or [Zitadel](https://zitadel.com/) give you an IdP with phishing-resistant MFA and SSO. For the device, [osquery](https://www.osquery.io/) with [Fleet](https://fleetdm.com/) collects posture and [Wazuh](https://wazuh.com/) covers EDR-style telemetry, with [step-ca](https://smallstep.com/) issuing the device certificates. For least privilege, [OpenZiti](https://openziti.io/) or [Pomerium](https://pomerium.com/) put per-application access in front of internal apps, [OPA](https://openpolicyagent.org/) carries the policy, and [Teleport](https://goteleport.com/) brokers just-in-time access to production. The continuous layer is the least settled, but the [Shared Signals Framework](https://openid.net/specs/openid-sharedsignals-framework-1_0-final.html) and receivers like [caep.dev](https://caep.dev/) are where the open plumbing is forming.

## Five Pillars, Three Capabilities, One Order

CISA draws the model as five pillars, not four stages, and it helps to hold both pictures at once. The pillars are Identity, Devices, Networks, Applications and Workloads, and Data. Three capabilities cut across all five: Visibility and Analytics, Automation and Orchestration, and Governance. Each pillar matures through its own Traditional to Optimal columns.

Those five pillars are what you mature. The sequence in this post is the order you mature them in. Identity first is the Identity pillar. The device is the Devices pillar. Least privilege and segmentation are the Networks and the Applications-and-Workloads pillars together, because shrinking what an identity reaches happens at the network and at the application at the same time. Continuous, risk-based evaluation is the Optimal column arriving across all of them at once, and it is what the Visibility and Automation capabilities exist to feed. Data is the pillar the other four protect, and knowing what the data is runs alongside the whole climb rather than waiting at the top. Governance is how you decide what least privilege even means for each pillar, so it runs the whole way down too.

## Why the Order Is Not Optional

The order is a dependency chain, not a preference. Each control assumes the one before it, and built out of turn it evaluates something it cannot trust.

Microsegment before you have clean identity and you have drawn careful boundaries around traffic you cannot attribute to a person or a workload. Score device posture before identity and you have graded the laptop without knowing whose hands are on it. Stand up a real-time risk engine first, the most expensive build of the four, and it scores a stream of signals with no trusted identity to anchor them to. In each case the control is real and the money is spent, and it floats free of the thing that would make it mean something.

![Two builds of the same controls. Built in order, identity enables device, which enables least privilege, which enables continuous evaluation, each stage a precondition for the next. Built out of order, each control floats free: microsegmentation before identity segments the network around requests it cannot attribute; device posture before identity grades the machine but not whose hands are on it; a risk engine built first scores signals in real time with no trusted identity to anchor them](diagram-out-of-order.png)

This is why identity comes first. It is the rung the rest of the sequence stands on, and the one that makes every later control mean something.

## Where to Start

The common mistake is starting at the expensive, visible end. Teams buy a microsegmentation product or a fancy risk engine before they have clean identity, and they end up with a sophisticated control evaluating requests it cannot reliably attribute. Start with identity, because every later control depends on it. The order is structural: each stage is the precondition for the next.

In practice, the identity-first work is a short, unglamorous list. Consolidate to one identity provider so there is a single place to reason about who can log in. Turn on [phishing-resistant MFA, FIDO2 keys or passkeys](/posts/mfa-that-survives-phishing/) rather than SMS, starting with admins and the crown-jewel apps. Retire the standing local accounts and shared logins that bypass all of it. Put conditional access in front of the systems whose compromise would hurt most before you try to cover everything. None of that needs a zero-trust product. All of it is the precondition for one.

## Find the Implicit Trust You're Still Extending

Because the whole model is the removal of implicit trust, the practical first move is to go find where you are still extending it. It hides in specific, boring places.

The flat VPN that drops a connected laptop onto a network where it can reach everything, the way one compromised endpoint becomes lateral movement. The service account with a [standing API key in a config file](/posts/non-human-identities/) that never rotates and never gets challenged. The SaaS app reached over the internet with a password and a push, with [no check on the device behind the login](/posts/trust-the-user-then-the-machine/). The shared admin account three people use because rotating it is annoying. The CI runner holding long-lived production credentials so a merge can deploy. The internal dashboard that trusts any request from inside the corporate IP range. The session that authenticated strongly at 9am and is [never re-evaluated for the next ten hours](/posts/logging-out-is-harder-than-logging-in/) while the laptop's posture quietly changes underneath it.

None of those is exotic. Each is a place where the network, the location, or a one-time check is standing in for a verified identity, and each is a candidate for the next control in the sequence. The work of zero trust is finding them and closing them in priority order, not reaching a label.

## Not Everything Needs the Optimal End

Here is the part the maturity model implies but rarely says out loud. Optimal is not the goal for everyone.

![Zero Trust as a Sequence: Identity Is the Foundation, Then Device, Then Least Privilege, Each a Precondition for the Next. Most Companies Right-Size at Solid Advanced Through Least Privilege, While Continuous Real-Time Scoring at the Top Is for Banks and Governments](diagram-sequence.png)

Continuous risk-based authentication across every pillar is the right target for a bank, a government agency, a company whose compromise would be catastrophic. For a mid-size company with a modest threat model, reaching solid Advanced on identity and access and stopping there is a defensible and often correct decision. Zero trust is a sequence, and you are allowed to stop climbing when the next rung costs more than the risk it removes. The same right-sizing that applies to IAM applies here: the destination is set by your risk, not by the vendor's diagram.

Concretely, a three-hundred-person SaaS company with no mandate beyond SOC 2 lands well at SSO everywhere with phishing-resistant MFA, just-in-time elevation for production through a broker, device posture on managed laptops, and per-application access in place of a flat VPN. That is solid Advanced on the identity and access pillars, and it removes most of the blast radius. The continuous, risk-based scoring at the top of CISA's model, real-time signal correlation adjusting access mid-session, is a large build that for this company catches a marginal slice of risk the earlier rungs already covered. Stopping there is the right call, and the next dollar of security budget buys more spent somewhere else.

## Verify Identity, Then Earn the Rest

Zero trust is the steady removal of implicit trust, in an order: start with identity, and earn each next control on the back of the one before it.

Stop asking whether you "are" zero trust. Ask which implicit trust you are still extending, whether it is the one that would hurt most, and whether the next control in the sequence is worth its cost yet. That question has an answer. "Are we zero trust" never did.
