+++
date = '2026-06-25T12:00:00-07:00'
draft = false
title = 'Per-App Access Ends the Flat Network'
aliases = []
description = "A VPN authenticates you to a network and then trusts you on all of it, which is how one phished laptop reaches the whole subnet. The network pillar of zero trust replaces that with identity-aware, per-application access: you reach the one app you are entitled to and never see the rest. Here's what replaces the VPN, and what the migration actually costs."
categories = ['Security', 'Engineering']
tags = ['Security', 'Zero Trust', 'IAM', 'Identity', 'ZTNA', 'Network Security', 'Microsegmentation', 'VPN', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

A VPN does one thing well and one thing badly. It authenticates you to a network, which is the thing it does well. Then it trusts you on all of that network, which is the thing it does badly. Once you are connected, you can route to every system on the subnet, and the only thing standing between you and any given box is whatever authentication that box happens to enforce on its own. The network itself has already said yes.

That is how a single phished laptop turns into a breach. The attacker who gets onto the VPN is not on one machine. They are on the network, with line of sight to everything on it, free to scan, probe, and move sideways until they find something soft. The login was the only gate, and it was at the edge. This is the [device pillar's blind spot](/posts/trust-the-user-then-the-machine/) made structural: a trusted connection from a machine you cannot vouch for, granted reach over everything at once.

## The VPN Grants the Network, Not the App

The flaw is not the VPN's encryption or its authentication. It is the unit of access. A VPN grants **network reachability**: once connected, your packets can reach any address on the subnet, and reaching is most of the battle. Whether you are authorized for a given service is a separate question that each service answers for itself, often weakly, sometimes not at all. The internal admin panel with no auth because "it is only on the internal network." The database listening on the LAN with a shared password. The forgotten server two patch cycles behind. None of those were supposed to be exposed, and all of them are, to anyone who reaches the network.

This is the perimeter model: a hard edge around a soft interior, where getting inside is the whole game because the inside is flat. It worked when the inside was an office and the edge was a building. It stopped working when the edge became a VPN concentrator any phished credential could cross.

## Network Access vs Application Access

The shift the network pillar of zero trust asks for is a change in what you hand out.

**Network access** is what the VPN gives: a route to a range of addresses, after which you are on your own to find what is there. The grant is coarse, the interior is visible, and lateral movement is the default capability.

**Application access** is what replaces it: a connection to one specific application you are authorized for, brokered per request, with the rest of the network invisible rather than merely guarded. You do not get a route to the subnet. You get a tunnel to the one app, and you cannot scan or reach anything else because there is no network adjacency to abuse. [NIST's 800-207](https://csrc.nist.gov/pubs/sp/800/207/final) describes this as resource-level access decisions, each request to each resource evaluated on its own, with no implicit trust granted by location on the network.

The difference shows up most in what an attacker gets from a single compromise. On the VPN, one foothold sees the whole interior. With per-application access, one foothold sees one application, the one that identity was entitled to, and the lateral movement that turns a foothold into a breach has nothing to traverse.

![The same five internal resources under two access models. Under a VPN, a phished laptop authenticates to the network and the concentrator hands it a route to every box, App A, App B, the database, an admin panel with no auth, and a legacy server, all reachable from one foothold. Under per-app access, the user and device authenticate to an identity-aware broker that tunnels only to the one app they are entitled to, while App B, the database, the admin panel, and the legacy server stay dark and unreachable](diagram-vpn-vs-perapp.png)

## What Replaces the VPN

The replacement is a broker that sits between users and applications and grants access one app at a time. The category name is zero trust network access, ZTNA, and the shape is an identity-aware proxy: the user connects to the broker, the broker checks who they are and what device they are on, and only then does it proxy the connection through to the specific application, while every other application stays dark.

[Google's BeyondCorp](https://cloud.google.com/beyondcorp) is the reference design, built after Google decided the corporate network would get no special trust and every request would be evaluated on identity and device instead. The commercial versions of the pattern, Cloudflare Access, Zscaler Private Access, Tailscale, Google's own Identity-Aware Proxy, and identity-aware access through an [authorization broker](/posts/authorization-broker-models/) like Teleport, all do the same core job: replace "you are on the network" with "you are allowed to reach this one thing." On the open-source side, [OpenZiti](https://openziti.io/) and [Pomerium](https://www.pomerium.com/) build the identity-aware access layer, and overlay-mesh projects like [Nebula](https://github.com/slackhq/nebula), [Netbird](https://netbird.io/), and [Headscale](https://github.com/juanfont/headscale) handle the segmented machine-to-machine side without a vendor.

Two pieces complete the picture. **Microsegmentation** handles the traffic the user broker does not see: the east-west, server-to-server connections inside the data center, divided so a workload can talk only to the specific workloads it needs rather than to its whole subnet. And **mutual TLS** between services means each connection proves both ends cryptographically, so a machine that lands on the segment still cannot talk to a service without the right identity. Per-app access for people, microsegmentation and mTLS for machines, and the flat interior is gone from both directions.

![Closing the flat interior from both directions. North-south, a user and device reach an application only through an identity-aware broker that tunnels to one app. East-west, Service A reaches Service B over mTLS because they share a segment, but its attempt to reach Service C is blocked, because Service C is in a different segment and Service A has no mTLS identity for it](diagram-both-directions.png)

## The Perimeter Moves to Identity

The perimeter does not disappear when the VPN does. It moves. The old perimeter was a place, the network edge you defended with a firewall and crossed with a VPN, and everything inside it was trusted by default. Per-app access takes that boundary off the network and rebuilds it around the identity and the device, checked at every request instead of once at the edge. The firewall guarded a location that an attacker only had to get inside of once. The new perimeter travels with the person, because it is the person, and the device in their hands, re-proven on every connection.

When the network grants nothing by itself, the access decision moves entirely onto identity and device. Every per-app connection is gated on two questions answered live: is this the user they claim to be, proven with a [phishing-resistant factor](/posts/mfa-that-survives-phishing/), and is this a device I trust right now, proven with a [hardware-bound certificate and current posture](/posts/trust-the-user-then-the-machine/). The network is no longer part of the trust calculation, which is the entire point. Location stops being evidence.

This is why the [zero-trust sequence](/posts/zero-trust-is-a-sequence/) puts identity and device first and the network pillar after. Per-app access is only as good as the identity and device signals it runs on. Brokering connections by identity while the identity is a reused password and the device is unknown just moves the weak gate from the VPN to the proxy. Build the first two pillars, and the network pillar is what finally cashes them in.

## The App That Assumes the Network

The honest part is that not everything moves to per-app access cleanly, and the migration is where the cost lives. A surprising amount of enterprise software was written assuming flat network adjacency, and it fights the model.

The legacy app with hardcoded server IPs that expect to reach each other directly. The fat client that opens half a dozen ports back to its server. The discovery and broadcast protocols that assume everything is on one segment. The backup agent, the monitoring system, the directory replication that all assume they can reach broad ranges. Putting these behind per-app tunnels ranges from configuration work to a rewrite, and some of them will never fully fit. For that tail, microsegmentation is the realistic control: you cannot broker every legacy connection through an identity-aware proxy, but you can wall each legacy system into a segment that reaches only what it must, which contains the blast radius even when you cannot eliminate the adjacency.

There is a second cost worth naming. Per-app access concentrates trust in the broker, the way [any broker becomes a choke point](/posts/authorization-broker-models/). The proxy that grants every application connection is now critical infrastructure, and when it is down, access is down, which means the network pillar inherits the same [break-glass problem](/posts/break-glass-without-the-backdoor/) as the rest of your identity plane. That is a real operational weight, and it is still a better trade than a flat interior, because a broker you can monitor and harden beats an implicit trust you cannot see.

The migration is measured in years for a large estate, not a quarter. You do it the way you do the rest of zero trust: highest-value applications first, the crown jewels off the flat network and behind per-app access before everything else, and the long tail of legacy systems contained by segmentation while you work through what can actually move.

## Grant the App, Not the Subnet

The VPN's promise was access to the network. That promise is the vulnerability, because the network was never supposed to be the unit of access. The unit is the application, and a single identity on a single device should reach the one it is entitled to and have no path to the rest.

Stop handing out the subnet. Put a broker in front of your applications, gate every connection on identity and device instead of location, segment the machine-to-machine traffic the user broker cannot see, and move the crown jewels first. When one compromised laptop can reach one application instead of the whole interior, the network has stopped being the soft middle an attacker counts on.
