+++
date = '2026-06-15T12:00:00-07:00'
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

**Then the device.** Once you trust the identity, you start asking about the thing it is coming from: is it managed, patched, posture-checked. This is where most programs slow down, because device trust touches every endpoint you have.

**Then least privilege and segmentation.** With trusted identity and device, you can shrink what each one reaches: per-application access instead of network access, microsegmentation, just-in-time elevation. This is where the blast-radius reduction actually happens.

**Then continuous, risk-based evaluation.** The Optimal end state, where every request is scored in real time against context and access is adjusted dynamically. This is genuinely valuable and genuinely expensive, and it is the last thing you build, not the first.

## Where to Start

The common mistake is starting at the expensive, visible end. Teams buy a microsegmentation product or a fancy risk engine before they have clean identity, and they end up with a sophisticated control evaluating requests it cannot reliably attribute. Start with identity, because every later control depends on it. The order is structural: each stage is the precondition for the next.

## Not Everything Needs the Optimal End

Here is the part the maturity model implies but rarely says out loud. Optimal is not the goal for everyone.

Continuous risk-based authentication across every pillar is the right target for a bank, a government agency, a company whose compromise would be catastrophic. For a mid-size company with a modest threat model, reaching solid Advanced on identity and access and stopping there is a defensible and often correct decision. Zero trust is a sequence, and you are allowed to stop climbing when the next rung costs more than the risk it removes. The same right-sizing that applies to IAM applies here: the destination is set by your risk, not by the vendor's diagram.

## Verify Identity, Then Earn the Rest

Zero trust is the steady removal of implicit trust, in an order: start with identity, and earn each next control on the back of the one before it.

Stop asking whether you "are" zero trust. Ask which implicit trust you are still extending, whether it is the one that would hurt most, and whether the next control in the sequence is worth its cost yet. That question has an answer. "Are we zero trust" never did.
