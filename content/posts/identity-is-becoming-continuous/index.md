+++
date = '2026-07-02T00:01:00-07:00'
draft = false
title = 'Identity Is Becoming Continuous'
aliases = []
description = "For decades, access has been decided once: you authenticate, you get a token, and the system trusts it until it expires, whatever changes in between. That model is ending. The Shared Signals Framework and CAEP move identity to a continuous decision, where a revoked session, a compromised device, or a risk spike reaches every app in near-real-time. Here's the shift, the standard behind it, and how far along it really is."
categories = ['Security', 'Engineering', 'Leadership']
tags = ['Security', 'IAM', 'Identity', 'Shared Signals', 'CAEP', 'Continuous Access Evaluation', 'Zero Trust', 'Session Management', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

For most of the history of access control, logging in was a one-time decision. The user authenticates, the system issues a token, and from that moment until the token expires, access is granted on the strength of that one check. Nothing looks again. The token is a standing bet that nothing important changed between the login and the expiry, and for a long time the bet paid off often enough to build an industry on.

That bet is getting worse, because more changes between login and expiry now, and it changes faster. A device that was compliant at nine is jailbroken by ten. A session that was the real user at noon is a stolen cookie by one. An account that was an employee on Monday is a terminated one whose [session is still running on Friday](/posts/logging-out-is-harder-than-logging-in/). The static token cannot see any of it. It was issued before the change and it expires after, and in between it is a promise made on stale information.

## Decide Once, Trust Until Expiry

This is the point-in-time model, and it is the default identity has lived inside for decades. Authentication happens at a moment. Authorization is decided at that moment. The result is written into a token with a lifetime, and that lifetime is a guess about how long the decision stays valid.

Every lever you have in that model is the lifetime. Short tokens re-check sooner and annoy users more. Long tokens are convenient and stale. There is no good answer, because you are choosing how often to re-decide on a fixed schedule, when the thing you want is to re-decide when something changes. A calendar is a poor substitute for an event.

Guess the schedule wrong and the cost is the entire lifetime. A one-hour access token is up to an hour of access after the moment that should have ended it, and the thirty-day refresh token behind it is up to a month. Shorten both and people re-authenticate all day; lengthen them and stale decisions ride for weeks. It is the only lever the model gives you, and it is the wrong one.

![Point-in-Time vs Continuous: in the Top Track a Standing Token Issued at Login Rides Its Trust Window to Expiry While Signals Like a Jailbroken Device, a Revoked Session, or a Risk-Score Jump Land Nowhere; in the Bottom Track Those Same Signals Arrive as Events That Drive a Live Decision Loop and Adjust Access in Seconds](diagram-point-in-time-vs-continuous.png)

## Continuous Means Re-Deciding on Every Signal

Continuous access evaluation flips the trigger. Instead of re-deciding on a schedule, you re-decide when a relevant fact changes, and access is adjusted in near-real-time. The session that was fine a second ago is cut the instant the thing that made it fine stops being true.

The facts worth reacting to are concrete. The user's session was revoked, because they were terminated or signed out everywhere. Their device fell out of compliance, because it was jailbroken or its disk encryption was switched off. Their risk score jumped, because the login is suddenly coming from an impossible location. Their credentials changed, because a password reset or an MFA re-enrollment just happened. Each of these is an event that should move access, and in the point-in-time model none of them does until the next token refresh, if then.

Wired up, the chain is short. The HR system marks a termination, the IdP turns it into a session-revoked event, the receiving apps drop the session, and access that used to outlive the offboarding by hours ends in seconds. A device works the same way: the MDM reports it fell out of compliance, a device-compliance event goes out, and the apps trusting that device stop honoring it.

## Shared Signals Is the Plumbing

The reason this is shipping in production is that the plumbing got standardized. The OpenID Foundation's [Shared Signals Framework](https://openid.net/specs/openid-sharedsignals-framework-1_0-final.html) reached final status, and it defines how cooperating systems exchange security events: a transmitter publishes signed event tokens, a receiver subscribes to a stream and acts on them. It is webhooks for identity, with the security and privacy properties written down. The unit on the wire is a security event token: a signed statement naming a subject and what happened to it, delivered over the stream the receiver subscribed to. The receiver validates the signature, reads the event, and applies its own policy, which might be to end the session, force a fresh authentication, or step up to a stronger factor.

![Shared Signals Framework Anatomy: Transmitters Like an IdP, MDM, or HR System Publish Signed Event Tokens to a Stream the Receiving App Has Subscribed to, the App Validates Each Token and Reads the Event, and Local Policy Decides Whether to End the Session, Step Up to a Stronger Factor, or Force Re-Authentication](diagram-shared-signals-flow.png)

Two profiles ride on top of it. [CAEP](https://openid.net/specs/openid-caep-1_0-final.html), the Continuous Access Evaluation Profile, carries the access events: session revoked, device compliance changed, assurance level changed, token claims changed. RISC, Risk Incident Sharing and Coordination, carries account-level risk events, like an account being disabled or a credential turning up in a breach, and it is built to be shared across providers, so the signal that your Google account was compromised can reach the other services that trust it. The [Shared Signals working group](https://openid.net/wg/sharedsignals/) shepherds both.

## Where It's Real Today

This is further along than most of the identity discourse assumes. Microsoft ships it in production as [Continuous Access Evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation): a termination, a disabled account, or a risky sign-in can end active Microsoft 365 sessions in about a minute instead of waiting out the token. [Okta](https://help.okta.com/oie/en-us/content/topics/itp/shared-signals.htm) and [Google](https://developers.google.com/workspace/shared-signals/api/ssf-api) are building Shared Signals support so the major providers can transmit and receive each other's events. And if you want to try it yourself, [caep.dev](https://caep.dev/) gives you a free transmitter to test against and an open-source receiver library to start from. Beyond the IdPs, [SGNL](https://sgnl.ai/) builds a dedicated CAEP platform and runs caep.dev, and the ITDR vendors are moving the same way, with Cisco folding the former Oort into its identity stack to act on these signals.

Concretely, terminate an employee in Entra at noon with Continuous Access Evaluation turned on, and their open Outlook and Teams sessions stop working within about a minute. Without it, those sessions ride the access token for up to an hour and the refresh token far longer, which is the gap that lets a just-fired employee keep reading mail through the afternoon.

The gap is the long tail. The large providers are wiring up; the thousands of smaller apps in any enterprise are not, and a signal only does something if there is a receiver listening for it.

## Compliance Already Asks for This

Read the control language already on the books and the static token is the awkward part. PCI DSS 4.0 requirement 8.2.5 says access for terminated users must be revoked "immediately." HIPAA's Security Rule calls for automatic logoff after a predetermined period of inactivity at §164.312(a)(2)(iii). SOC 2's common criteria for logical access expect changes to follow termination and role changes in a timely way, with "timely" defined by your own policy and judged against it. None of these were written with shared signals in mind, and all of them are easier to satisfy with continuous evaluation than without. "Immediately" inside a one-hour access token is a contradiction the auditor lets you carry only because the alternative is usually worse.

It is starting to show up in procurement. Regulated buyers — financial services, healthcare, public sector — are putting "CAEP receiver support" and "SSF transmitter support" into the security questionnaires they send to SaaS vendors, on the same line as SSO and SCIM. SGNL's market pitch is largely that they sell the receiver side to enterprises whose apps do not have it, and the ITDR vendors detecting identity threats need this plumbing on the other end of their detections so the alert can do something other than page a human. None of this is regulated mandate yet, but the path from "asked about in due diligence" to "required in the contract" to "table stakes" is the same one SAML traveled.

The asymmetry to watch is transmitter versus receiver. Emitting events is the easier half: a security checkbox a vendor can ship without rewriting their session model. Acting on events as a receiver is policy-engine work, and most of the SaaS long tail is not going to do it on their own timeline. Expect transmitter support to become table stakes in regulated verticals on a two- to three-year horizon, and receiver support to stay a differentiator for the identity-adjacent platforms (ITDR, PAM, access gateways, app security middleware) that already think in terms of policy rather than tokens. The shape of the rollout will be familiar: the big platforms get there first, the regulated middle gets there next because the contracts force it, and the rest gets there when standing tokens stop being defensible at all.

## This Is How Zero Trust Was Supposed to End

Continuous evaluation is where the other pillars were always heading. [Zero trust's maturity models put continuous, risk-based, real-time access at the top](/posts/zero-trust-is-a-sequence/), the Optimal stage everyone draws and almost nobody reaches, and a big part of why almost nobody reaches it is that until recently there was no standard way to deliver the signals that make it work. Shared Signals is that delivery mechanism. The [device-posture checks](/posts/trust-the-user-then-the-machine/) you built become signals a CAEP transmitter can emit. The session revocation the [logout problem](/posts/logging-out-is-harder-than-logging-in/) needed is a single CAEP event. The continuous re-evaluation zero trust promised is what you get once those signals have somewhere to go.

It reaches the newest identities too. The hardest case in [workload and agent identity](/posts/workload-identity-that-crosses-boundaries/) is a non-deterministic agent whose behavior changes mid-run, and the answer there is the same shape: a provable chain of custody and the ability to revoke in real time when the agent does something it should not. That is what a continuous, signal-driven model provides.

## It Only Works When Both Ends Listen

For all of that, continuous is a direction you move toward, and the honest limits are real. Shared Signals needs a transmitter and a receiver, and the receiver side is where most of the ecosystem is missing. Your IdP can emit a session-revoked event all day; if the app it concerns has no receiver, the event lands nowhere and the session lives on, exactly as it does today.

It is also real infrastructure. A signals pipeline is streams to manage, events to deliver and de-duplicate and replay, and policies to decide what each event should do, because not every signal should cut access, and a system that overreacts to noisy ones teaches people to route around it. None of that is free, and most companies do not need it everywhere. The move is the same as everywhere else in identity: start where it matters most, the crown-jewel apps and the highest-risk signals, get continuous evaluation working there, and leave the long tail on short token lifetimes until the receivers catch up.

## The Standing Token Is Ending

The standing token, issued once and trusted until it expires, is the assumption the whole field was built on, and it is the assumption coming undone. Access is becoming something a system re-decides continuously, as the facts move, instead of something it stamps once and forgets.

I argued in the [logout post](/posts/logging-out-is-harder-than-logging-in/) that a disabled account leaves a live session running because nothing tells the app to end it. Continuous evaluation is the general answer to that specific complaint: the app is told the moment it is true, and it acts. Identity is becoming continuous because the world it secures never stopped moving, and a decision made once was always a snapshot of a moment that had already passed.
