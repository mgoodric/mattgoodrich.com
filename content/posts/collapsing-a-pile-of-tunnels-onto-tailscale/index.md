+++
date = '2026-07-13T00:01:00-07:00'
draft = false
title = 'One Overlay Instead of a Pile of Tunnels'
aliases = []
description = "My remote access had grown into three overlapping tools: SSH tunnels from the Mac Studio to Unraid, UniFi's Teleport VPN to get a MacBook onto the network, and Cloudflare tunnels for a quick SSH in or for networks that block the VPN, like a cruise ship. All three worked, and all three needed maintaining. Tailscale collapsed them into one overlay for private device access with zero trust by default, and left Cloudflare only the job it's actually for: public ingress."
categories = ['Engineering', 'Software', 'Tools']
tags = ['Tailscale', 'Networking', 'WireGuard', 'Homelab', 'SSH', 'Cloudflare', 'Zero Trust', 'UniFi', 'Self-Hosting', 'Developer Tools']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

I did not set out to build a patchwork. Each piece went in because I needed it that day, and every one worked. What I ended up with was three different tools doing the same job, reaching my own machines from wherever I happened to be, each with its own config, its own failure mode, and its own maintenance. The pile was the problem, and no single tool in it was.

## Three Tools Doing One Job

The oldest piece was a stack of SSH tunnels from the Mac Studio to my Unraid server. The Studio runs the agents and the automations; Unraid runs the databases, the telemetry collector, the media stack, the message broker. Getting one to talk to the other meant a single SSH session forwarding a long list of ports, started by hand from a script. It existed for a specific and slightly stupid reason: macOS Sequoia's local-network privacy blocks apps from reaching LAN IPs like `192.168.1.x` directly, so a Python script on the Studio could not simply open a socket to Unraid. The tunnel dodged the restriction. It also grew a new forwarded port every time I stood up a service, and it was one process: if it died, everything on the Studio that depended on Unraid died with it.

The second piece was my UniFi gear's built-in VPN, Teleport, for the times I needed a laptop on the home network from somewhere else. Click a link, land on the LAN, do the thing. It is a clean feature and it worked. It was also a second, entirely separate way of solving "reach home," with its own client and its own idea of access.

The third piece was Cloudflare tunnels. I used those for a fast SSH into the Studio when I did not want to bring up the VPN, and for the networks where the VPN would not connect at all. A cruise ship is the honest example: locked-down Wi-Fi that blocks the ports a VPN wants, where an outbound-only tunnel to Cloudflare's edge is the thing that still gets through. Cloudflare was also carrying my genuinely public surface, the bridges that expose services to claude.ai and a handful of self-hosted apps I reach through it. So it was doing two unrelated jobs at once: personal remote access, and public ingress.

Three tools. An SSH-tunnel script, a router VPN, and a set of Cloudflare tunnels. Each one reasonable on its own. Together they were three configs to keep straight, three things to debug when a laptop could not reach home, and a footprint that grew every time I added something to the homelab. I was spending real time maintaining the connectivity rather than the things it connected.

## What I Actually Wanted

Three things, in order.

Scale, first. I kept building, and every new service made the pile bigger, another forwarded port, another thing to remember. I wanted connectivity that did not grow a new appendage every time the homelab did.

Less to maintain, second. One way to reach my machines, not three, each configured and debugged separately.

And a better security posture, third. A VPN that drops you onto the flat LAN gives you the whole network the moment you are on it. I wanted access that was scoped per device and per service, closer to zero trust by default, where being on the overlay does not mean being trusted for everything on it. This is the same argument I made for [an enterprise built on devices you don't own](/posts/secure-enterprise-on-devices-you-dont-own/), turned on my own house: identity does the work the network used to, and nothing is trusted just for being inside.

Those three wants pointed at one kind of answer: an identity-based overlay network. That is [Tailscale](https://tailscale.com/).

## One Overlay

Tailscale builds a private mesh across all your devices over WireGuard, where each machine authenticates to your identity provider and then reaches the others directly by name, wherever any of them are. I run the hosted version on the free plan, with Google SSO on my own domain as the identity, MagicDNS on so every device answers to a short name, and device approval and key expiry turned on so a new machine cannot silently join.

Unraid is the anchor. The official Community Apps Tailscale plugin runs it in the host network namespace, so the box gets one overlay address and a MagicDNS name, and every port it already published is reachable over the tailnet with no per-service setup. I also had it advertise the home subnet as a route, so the few pieces of gear that will never run a Tailscale client, the LAN-only boxes, are still reachable through it without installing anything on each one.

The macOS privacy problem that the SSH tunnel existed to dodge just evaporates. Tailscale traffic rides its own network interface in the carrier-grade NAT range, which macOS does not treat as "local network," so an app on the Studio reaches Unraid by its MagicDNS name with no prompt and no tunnel. The long forwarded-port list collapses into "talk to `unraid-server` by name." The Studio and the laptop reach the same machine the same way whether I am in the office or on the far side of the country.

There is a nice symmetry I did not plan. UniFi's Teleport is WireGuard underneath, and so is Tailscale. I was not switching VPN technology so much as consolidating two WireGuard setups and a pile of SSH forwards into one managed mesh, with an identity model and access rules on top that neither of the old pieces had.

![Before and After the Migration: the Before State Has Three Separate Tools to Maintain, the MacBook Reaching the Flat-Trust Home LAN Over UniFi Teleport VPN, the Mac Studio Reaching Unraid Services Over a Hand-Started 20-Port SSH Tunnel, and the Laptop or Studio Reaching a Remote Shell and Public Ingress Over Cloudflare Tunnels; the After State Is One Tailscale Overlay Where the MacBook, Mac Studio, and iPhone or iPad All Reach a WireGuard Mesh With MagicDNS From Anywhere, Unraid Is the Anchor and Subnet Router to LAN-Only Gear, and Cloudflare Is Kept for Public Ingress Only](diagram-before-after-topology.png)

## Two Planes: Private Access and Public Ingress

Sorting out Cloudflare's double duty was the part that made the whole thing click. Two different jobs had been living in one tool, and separating them is the model I would keep no matter what software filled each slot.

**The private plane** is device-to-device access: my laptop reaching Unraid, the Studio reaching the collector, an SSH session into either. That is all Tailscale now. It is private by construction, nothing on it is exposed to the internet, and every connection is between two devices I own and have authenticated.

**The public plane** is the surface that genuinely has to face the outside world: the bridges that serve claude.ai, the public-facing apps. A private mesh cannot do that job, because the caller is not on my tailnet. That stays on Cloudflare, which is what it is actually for.

Before, Cloudflare was doing both, and my SSH-into-the-Studio habit was quietly riding the public plane for a private job. Now the two are clean. Tailscale owns private access; Cloudflare owns public ingress; they are complementary planes, not competitors, and I stopped using a public-ingress tool to reach my own Mac Studio.

![Two Planes: the Private Plane Is Tailscale, a Device-to-Device Mesh Between the MacBook, Mac Studio, Unraid, and iPhone or iPad That Is Never Internet-Exposed; the Public Plane Is Cloudflare, the Only Outside-Facing Surface, Where the Internet and claude.ai Reach the MCP Bridges and Public Apps Through It; a Dashed Arrow Shows That Personal SSH Used to Ride the Public Plane and Has Moved to the Private Plane](diagram-two-planes.png)

## Zero Trust by Default

The posture change is the part I care about most, and it is worth being precise about what it does and does not buy.

The old VPN was network-level trust. Connect, and you are on the LAN with whatever the LAN allows, which is usually everything. The overlay is identity-level. Every device authenticates to my identity provider before it can join. Access between devices is governed by ACLs I write, default-deny, so the telemetry ports are reachable only from my own machines and not from the whole tailnet, and the infrastructure node is tagged so its access does not silently lapse when a personal device's key expires. Being on the overlay is not being trusted for everything on it. That is the actual definition of the thing, applied at the scale of one person's house.

I will not oversell it. This is more zero trust than a flat VPN, not a finished zero-trust architecture, and calling a homelab "zero trust" with a straight face requires some humility. There is no per-request re-verification, no device-posture checks, none of the machinery a real enterprise deployment carries. What I have is the load-bearing piece: identity instead of network location as the thing that grants access, and rules that scope it per device. For a house, that is the right amount, and it is a real step up from "you're on the wifi, you're in."

![Network Trust Versus Identity Trust: With a Flat VPN a Device Connects, Lands on the LAN, and Reaches Everything the Network Allows; With the Overlay a Device Must Authenticate to Identity via Google SSO, Be an Approved Device With a Key That Has Not Expired, and Pass a Default-Deny ACL Check That Either Allows Access to Only the Scoped Device or Service or Denies It Entirely](diagram-zero-trust-access.png)

## Docker on Colima Needed Its Own Key

Everything so far is the overlay removing moving parts. One corner went the other way, and it is the honest exception. My Docker containers run inside a Colima VM on the Mac Studio, and they cannot borrow the host's Tailscale. The macOS build carries the host's own traffic onto the tailnet but will not route packets that originate inside the VM, and `host.docker.internal` only reaches the Mac host, not the tailnet peers behind it. So a container that needs Unraid by its MagicDNS name has no path there, even though the machine it runs on is sitting on the tailnet.

The fix is to give the VM its own presence on the network: a small Tailscale sidecar container running inside Colima, joined to the tailnet in its own right, with the app containers sharing its network namespace so they inherit its addresses. A headless container cannot sit through a browser login, so it authenticates with a pre-generated auth key, and the detail that matters is that the key is tagged. A tagged auth key gives the node an ACL tag instead of tying it to me as a user, which does two useful things: it does not expire on the personal-device clock, so the sidecar does not silently drop off the tailnet in six months, and it is governed by the same ACLs as the rest of the infrastructure instead of inheriting my full access. It is a real secret to generate, store, and rotate. It is also the one piece of plumbing the migration added rather than removed. I would still take the trade, one managed key against a pile of hand-started tunnels, but that is the place where the tidy story has a loose end.

## What the Overlay Bought

The pile is one overlay now. My machines answer to their names from anywhere, over a single mesh, with access scoped by identity instead of by which network I happen to be on. Cloudflare went back to the one job it should have had all along, and the SSH-tunnel script and the router VPN are both retired.

The real test of a change like this is whether the things built on top get simpler, and that is the next post. There is one small automation I use constantly, getting a screenshot from the laptop in front of me into a Claude Code session running on the Studio, and it used to need two of these three connectivity methods to work from anywhere. On the overlay it needs one name and no fallback at all. That is the shape of a good consolidation: the thing underneath gets boring, and the things on top get shorter.
