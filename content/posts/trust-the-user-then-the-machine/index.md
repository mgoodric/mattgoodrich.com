+++
date = '2026-06-23T12:00:00-07:00'
draft = true
title = 'Trust the User, Then Trust the Machine'
aliases = []
description = "User authentication answers who is making a request and says nothing about the machine it comes from. Device-based authentication, a hardware-bound certificate plus live posture, makes the machine part of the decision: is this one of ours, and is it healthy right now. Here's how to build it, and where the friction stops being worth it."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'Device Trust', 'Certificates', 'mTLS', 'Zero Trust', 'Conditional Access', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

You can prove exactly who is making a request and still have no idea what they are making it from. A user signs in with a phishing-resistant passkey, the strongest factor you can give them, and the login is genuinely theirs. It tells you nothing about whether the laptop behind that login is a managed, encrypted, patched company machine or a personal one riddled with malware, or a contractor's box you have never seen. The user factor answers one question. The machine asking the question is a second one, and most access decisions never ask it.

Device-based authentication is how you ask it. The request carries proof of the machine as well as the person: a certificate that says this is a device you issued, and a set of signals that say the device is healthy right now. Used as an enterprise control, it is the second half of "verify the request," and the half most programs skip because the user half is the one with all the marketing behind it.

## What the User Factor Can't See

Even a perfect user factor has a blind spot the size of the endpoint. [Phishing-resistant authentication](/posts/mfa-that-survives-phishing/) stops an attacker from logging in as your user from the attacker's own machine. It does nothing about an attacker operating *on* your user's machine. Malware on a legitimate, signed-in laptop rides the user's valid session. Stolen session cookies replay from anywhere with no second login at all. A developer's personal laptop with no disk encryption and a three-year-old OS authenticates exactly as cleanly as the hardened fleet machine next to it, because the user behind both is the same trusted person.

The pattern underneath all three is the same. User identity tells you whose request it is. It is silent on the trustworthiness of the thing the request came from. The device factor exists to make that thing speak for itself.

## Device Identity vs Device Posture

This is the distinction the whole topic turns on, and the one most "device trust" pitches blur. A device makes two separate claims, and you need both.

**Device identity** is the claim "I am a machine you know." It is answered by a certificate the device holds, issued by you, proving this specific endpoint is one you enrolled. It is binary and durable: the machine either presents a valid, non-revoked certificate or it does not.

**Device posture** is the claim "I am a machine in good shape right now." It is answered by live signals: disk encryption on, OS patched to a current level, screen lock enforced, EDR agent running, firewall up. It is graded and perishable. A device that was compliant this morning can fail posture this afternoon when someone disables FileVault.

A certificate proves identity and says nothing about health. Posture proves health and says nothing about identity, because an attacker's fully-patched, encrypted laptop has excellent posture and no business on your network. The control you actually want is both at once: this is one of our machines, *and* it is healthy at the moment it is asking. Conflating the two is how you end up trusting a well-maintained device you do not own, or a genuinely-yours device that has quietly rotted.

| | Device identity | Device posture |
|---|---|---|
| The claim | "I am a machine you enrolled" | "I am a healthy machine right now" |
| Proven by | A hardware-bound X.509 certificate | Live signals from MDM and EDR |
| Nature | Binary and durable | Graded and perishable |
| Fails when | The cert is revoked, expired, or absent | Encryption off, OS stale, EDR killed |
| The claim alone gives you | A known machine that may be unhealthy | A healthy machine that may be a stranger's |

## A Certificate Is Only as Good as Where Its Key Lives

Device identity rests entirely on the certificate being hard to copy, and that is where most implementations are weaker than they look.

A device certificate is an X.509 cert with a private key, usually pushed to managed devices through your MDM with [SCEP or a similar enrollment protocol](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure). The question that decides whether it is a real control is where that private key sits. A **soft certificate** lives in the OS user or machine keystore as exportable key material. It is convenient, and it is copyable: malware running on the device, or a user who wants to, can export the key and present your "device identity" from a completely different machine. You have authenticated a file, not a device.

A **hardware-bound certificate** generates and stores its private key in the device's secure hardware, the TPM on a Windows or Linux machine, the Secure Enclave on a Mac, and marks it non-exportable. The key never leaves the chip; signing happens inside it. Now the certificate is bound to one physical machine, and presenting that device identity requires possession of that machine rather than a copied file. This is the same principle that separates a [synced passkey from a device-bound hardware key](/posts/mfa-that-survives-phishing/): the security is in where the private key physically lives. Apple's Secure Enclave and managed device attestation, and the equivalent TPM attestation on Windows, let you go one step further and verify at enrollment that the key really is hardware-protected before you trust the cert at all.

For the highest-assurance paths, the device certificate does real work in [mutual TLS](https://cloud.google.com/beyondcorp): the client and the server both present certs, and the connection only completes if the device's hardware-bound cert checks out. That is how you gate an admin plane or a service-to-service call on the machine itself, so a valid user on an unrecognized box cannot complete the connection at all.

Whatever you issue, plan for its lifecycle on day one: device certs should be short-lived and auto-renewed, with a working revocation path through CRL or OCSP, so a lost or decommissioned machine loses its identity fast instead of holding a valid cert for a year. [step-ca](https://smallstep.com/), Smallstep's open-source certificate authority, is a practical way to issue and rotate these device certs without standing up a commercial PKI.

## Posture Is a Live Signal, Not a Stamp

The most common posture mistake is checking it once. A device passes an enrollment check, gets marked compliant, and that verdict sticks while the machine drifts: encryption gets turned off, the OS falls behind, the EDR agent is killed. A posture stamp from three weeks ago is not a health check. It is a memory of one.

Real device posture is evaluated at access time and re-evaluated continuously. The signal usually comes from your MDM and EDR, which report a compliance state per device, and your IdP consumes it. If you are not buying that signal, open-source [osquery](https://www.osquery.io/) with [Fleet](https://fleetdm.com/) can collect posture across the fleet, and [Wazuh](https://wazuh.com/) covers the EDR-style telemetry. In practice that is a [conditional access policy that requires a compliant or managed device](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-grant#require-device-to-be-marked-as-compliant): the user authenticates, the policy checks the device's current compliance signal, and access is granted, stepped up, or blocked based on the machine's state at that moment. Google's [BeyondCorp](https://cloud.google.com/beyondcorp) model is the same idea taken to its conclusion: every request is evaluated against device and user context, and there is no trusted network to hide a bad device inside.

Concretely, a policy for a managed laptop reaching a sensitive app might require, all evaluated live at sign-in: a valid hardware-bound device certificate, disk encryption on through FileVault or BitLocker, the OS within one major version and 30 days of patches, a screen lock at five minutes or less, and an EDR agent that has checked in within the last 24 hours. The certificate is the hard gate, miss it and you are blocked. The patch window is soft, miss it and you are allowed through but pushed straight into remediation. Wiring those signals up is the actual work, and it is why device posture is a program rather than a setting.

The grading matters as much as the gate. Posture does not have to be pass or fail. A fully compliant managed laptop reaches everything its user is entitled to; a managed laptop that is healthy except for a pending OS update reaches most things but gets pushed to remediate; an unknown device is held at the door or routed to a constrained path. The point is that the device's *current* state, not its enrollment history, decides what it reaches.

## Build It at the Choke Point

As an enterprise control, device authentication goes in at the same choke points as the rest of your access, in the same blast-radius order the zero-trust sequence uses for everything else.

Start by giving managed devices a real identity: enroll them in MDM, issue hardware-bound certificates, and register them in the IdP so "managed device" is a fact the access layer can check. Then put a device condition in front of the systems whose compromise would hurt most, the production consoles, the financial systems, the IdP admin itself, requiring a managed, compliant device to reach them while you leave lower-risk apps alone. Use [certificate-based authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication) or mTLS where you want the machine proven cryptographically, and the MDM compliance signal where you want the machine's health checked. For SaaS that sits outside your network entirely, browser-level device trust tools like [1Password's Device Trust](https://www.1password.com/product/device-trust) (formerly Kolide) can block authentication from a device that fails posture, which is often the most practical way to extend the control to apps you do not host.

The shape is the same every time: the user proves who they are, the device proves what it is and how healthy it is, and the policy at the choke point reads both before it decides.

## The Unmanaged Device Is the Whole Problem

Here is where device authentication argues with itself, and the part worth being honest about. The clean version, every device is enrolled, every cert is hardware-bound, every endpoint reports posture, describes a fleet that does not fully exist in any real company. The contractor on their own laptop, the developer who needs to check something from a personal machine, the vendor's engineer, the phone that is genuinely personal: these are not edge cases you can wave off. They are a standing share of who needs access, and a hard "managed devices only" rule does not make them go away. It makes them find a path you cannot see, which is worse than the problem you were solving.

So the realistic control is scoped, not absolute. Require managed, healthy devices for the high-value systems where the assurance is worth the friction, and offer the unmanaged population a path that does not require enrolling their personal hardware: a virtual desktop or a managed browser that keeps company data off the endpoint, mobile application management that containers the corporate apps without claiming the whole phone, or a constrained, read-mostly tier of access at a lower assurance level. The goal is to match the device requirement to the sensitivity of what is being reached, and to give the people you cannot hand a managed laptop a real way in, rather than pretending they will not need one.

There is a cost ceiling here too. MDM and EDR coverage is never total, certificate lifecycle is real operational work, and some machines, old Linux boxes, lab equipment, appliances, will never carry a hardware-bound cert or report posture cleanly. Those get the same treatment as every other long tail in this series: an inventory, a compensating control, and a place on the list to retire, named out loud instead of quietly assumed into your coverage.

## Verify the Person, Then the Machine

User authentication and device authentication answer different questions, and a serious access decision needs both answered. Who is this, proven with a phishing-resistant factor. And what are they on, proven with a hardware-bound certificate for identity and a live posture signal for health. Skip the second question and a trusted user on a compromised machine looks identical to a trusted user on a clean one, right up until it does not.

Verify the person, then verify the machine they brought. The access decision needs both answers, and only one of them is about the user.
