+++
date = '2026-06-30T12:00:00-07:00'
draft = true
title = 'The Other Half of Identity Security'
aliases = []
description = "The IAM controls in this series prevent bad access; the SOC's job is to catch what gets through. A handful of identity detections do most of the work, chosen to be rare and meaningful enough not to drown the team, starting with the one every break-glass account needs: an alert the moment it is used."
categories = ['Security', 'Engineering']
tags = ['Security', 'SOC', 'Detection Engineering', 'IAM', 'Identity', 'Threat Detection', 'Incident Response', 'Break-Glass', 'SIEM', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

I was most of the way through writing about break-glass access when I realized I had only written the prevention half. Build a break-glass account that stays inert until used, expires fast, and gets reviewed every time, and the prevention is solid. But the entire point of break-glass is that someone breaks it in an emergency. If no alarm fires when they do, you have built a careful emergency exit that nobody is watching.

That gap is not specific to break-glass. Almost every preventive control this series has covered has a detection that belongs next to it, and most teams build the control and skip the alarm. The control is the IAM team's job. The alarm is the SOC's. Identity security is both, and so far this series has only done one half.

## Prevention Is Half a Control

Identity belongs in the SOC now for the same reason it belongs in this series at all. Identity is where the attacks land. The perimeter moved to the login, the most valuable thing an attacker can steal is a credential or a session, and the most damaging thing they can do with it is quiet, because a valid identity doing valid-looking things does not trip a network alarm.

Preventive controls assume they will hold. Least privilege assumes the grant is right. A broker assumes nobody routes around it. Workload identity assumes the secret is gone. Every one of those is a good assumption that is sometimes wrong, and the SOC exists for the times it is wrong. A control you cannot see being bypassed is a control you are trusting on faith.

So the pairing is the whole idea: for each control you build, name the event that means it failed, and alarm on that event. Not every event. The specific one that says prevention did not hold this time.

## The Detections Worth the Noise

A handful of identity detections catch most of what matters, and they share a property: a single hit is worth a person's attention. That is the bar.

**Break-glass used.** The one that started this. Any authentication with a break-glass account pages immediately, every time, no exceptions. It is rare by design and meaningful by definition, which makes it the cleanest detection you will ever write. If your [break-glass accounts](/posts/break-glass-without-the-backdoor/) do not alarm on use, start here.

**A new path to privilege.** Someone added to an admin group, a role's policy widened to a wildcard, a fresh cross-account trust, an assume-role or pass-role into a high-privilege role. This is the [granted-versus-reachable](/posts/you-can-reach-more-than-you-were-granted/) problem caught while the edge is being built. The grant looks administrative and routine, which is exactly why a human should look at it.

**A dormant identity waking up.** An account or key that has not authenticated in months suddenly does: a departed employee's login, a forgotten service-account credential, a stale token from a project that ended. [Telemetry](/posts/telemetry-driven-access-reviews/) already tells you which identities are dormant; the detection is the alarm when one of them comes back to life, because the most common explanation is that someone other than the original owner found it.

**A service account acting out of character.** A machine identity authenticating from a new network, calling an API it has never called, or writing where it has only ever read. [Service accounts are predictable](/posts/non-human-identities/) in a way humans are not, and that predictability is the gift. Deviation from a tight baseline is a clean, low-noise signal, where the same logic on a human would drown you in false positives.

**Someone changing the locks.** MFA turned off on an account, a new MFA device registered, a new federated identity provider added, an OAuth application granted broad consent. These are how an attacker makes stolen access durable, and they stay quiet unless you watch for them specifically. The illicit-consent and rogue-MFA-enrollment patterns are common precisely because so few teams alarm on them.

**The logs going dark.** Audit logging disabled, a trail stopped, a log bucket's retention quietly shortened. An attacker turning off the thing that would catch them is itself the thing to catch, and it is close to the highest-confidence signal on this list, because there is almost no legitimate reason for it to happen without a change ticket attached.

These travel as code, not console clicks. [Sigma](https://github.com/SigmaHQ/sigma) lets you write each rule once in a vendor-neutral format and run it across SIEMs, and if you are not on a commercial platform, an open-source stack like [Wazuh](https://wazuh.com/) for log-based detection and [Falco](https://falco.org/) for runtime behavior can carry the same logic.

## Few Alarms, All of Them Real

The temptation, once you start, is to alert on everything identity-related, and that is how you bury the SOC. Every failed login, every new IP, every off-hours access, alarmed, becomes a wall of noise that trains the on-call to ignore it, and the one real alert dies in the same inbox as ten thousand false ones.

The discipline is restraint. The detections above earn their place because a single occurrence is genuinely worth waking someone up. High-volume, low-meaning events, failed authentications, geo-velocity on a sales team that travels, belong in a dashboard you review, not a page that interrupts a person. Break-glass use is the gold standard not because it is clever but because it is rare and unambiguous, and the closer a detection sits to that bar, the more it is worth building.

There is a real cost here that prevention does not have. A detection only fires after something has already happened, so it is a backstop, not a wall, and a team that leans on detection to excuse weak prevention has the balance wrong. Put an alarm on each control so you find out the day it is bypassed instead of the quarter, and keep building the controls anyway.

## You Built the Controls. Now Watch Them.

The IAM work in this series and the SOC work in this post are the same problem from two ends. One side builds the door, scopes the access, kills the standing privilege, and owns the identity. The other side watches all of it and tells you the moment any of it gives way. Neither half is identity security on its own.

Treat a control as unfinished until something is watching for its bypass and will wake you when it comes. Build the door well, then put an alarm on it.
