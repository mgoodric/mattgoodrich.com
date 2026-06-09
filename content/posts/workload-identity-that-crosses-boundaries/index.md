+++
date = '2026-06-12T12:00:00-07:00'
draft = true
title = 'SPIFFE Is Workload Identity That Crosses Boundaries'
aliases = []
description = "Every cloud has its own workload identity, and none of them reach a service running in a different cloud, on-prem, or on bare metal. SPIFFE is the vendor-neutral standard that does, and SPIRE issues those identities by attestation, solving the secret-zero problem of proving a workload with nothing to start from. Here's how it works, and when it's worth the infrastructure."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'Workload Identity', 'SPIFFE', 'SPIRE', 'mTLS', 'Zero Trust', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Every plan to get the secrets out of your workloads runs into the same wall. To pull a credential from the vault, the workload has to authenticate to the vault, which means it needs a credential to do that. You did not remove the secret. You moved it down one level, and there is always another level beneath it.

This is the secret-zero problem, and it has a name borrowed from an old joke about what holds up the world: it is turtles all the way down. Somewhere the stack has to rest on something that is not one more secret. SPIFFE is a standard for making that bottom turtle stand on solid ground, and SPIRE is the implementation that puts it there.

## Native Workload Identity Stops at the Cloud's Edge

Inside a single cloud, this is already solved, and solved well. [When a workload can use the platform's native identity](/posts/when-you-can-use-workload-identity/), AWS, GCP, and Azure each attest it for you: an EC2 instance gets an instance profile, a Kubernetes pod gets a service account bound to a cloud role, and the credential is short-lived and injected automatically. There is no secret to place and no bottom turtle, because the cloud itself is the ground the stack rests on.

The catch is the words "inside a single cloud." That native identity is the cloud vouching for its own workloads to its own services. It does not cross the edge. A service in AWS calling a service in GCP, a workload on a bare-metal VM in your own data center, a container talking to a managed database on a different platform: the moment the caller and the callee do not share one cloud's identity plane, the native mechanism has nothing to say, and you are back to placing a secret by hand.

## SPIFFE Is a Name and a Document

SPIFFE, the Secure Production Identity Framework for Everyone, is a [specification](https://spiffe.io/), not a product. It defines two things, and they are simpler than the acronyms around them suggest.

A [SPIFFE ID](https://spiffe.io/docs/latest/spiffe-about/spiffe-concepts/) is a name for a workload, written as a URI: `spiffe://example.org/payments/api`. The first part is the trust domain, the rest identifies the specific workload. It is a stable name that means the same thing no matter which cloud or machine the workload runs on.

An SVID, a SPIFFE Verifiable Identity Document, is the credential that proves a workload holds that name. It comes in two forms: an X.509-SVID, a short-lived TLS certificate with the SPIFFE ID written into it, used for mutual TLS between services; and a JWT-SVID, a signed token for the cases where TLS is not the transport. Either form is short-lived and rotated automatically.

The workload gets its SVID from the Workload API, a local endpoint it calls to fetch and refresh its identity. The workload holds no long-lived key, stores no secret, and does not even need to know how it was identified. It asks the local API, and a fresh SVID comes back.

## Attestation Is How the Turtle Reaches the Ground

The question that matters is how the Workload API knows which SVID to hand back when the workload presented no secret. The answer is attestation, and it works in two layers.

[Node attestation](https://spiffe.io/docs/latest/spire-about/) proves the machine. When a SPIRE agent starts on a node, it proves what node it is using something the platform already vouches for: the signed instance identity document AWS gives every EC2 instance, the GCP or Azure equivalent, a Kubernetes projected service-account token, or a hardware TPM. The agent did not start with a secret. It started with a property of where it runs, signed by something able to sign it.

Workload attestation proves the process. When a workload calls the Workload API, the SPIRE agent inspects the caller through the operating system: its Unix UID and binary path, the Kubernetes service account and namespace of its pod, the labels on its container. These are selectors, and they are facts about the process that the kernel reports, not claims the process makes about itself.

The SPIRE server holds registration entries that map a set of selectors to a SPIFFE ID: this UID, in this Kubernetes service account, on an attested node of this kind, is issued `spiffe://example.org/payments/api`. When an agent's attestation matches an entry, the server mints the SVID. The workload proved nothing it had to be handed in advance. It proved what it is and where it runs, and that was enough. That is the bottom turtle standing on the ground: identity bootstrapped from attested properties instead of a planted secret.

## SPIRE Runs the Whole Thing

[SPIRE](https://github.com/spiffe/spire) is the reference implementation, and it is two components. The SPIRE server is the certificate authority and the registry: it holds the trust domain's signing key, stores the registration entries, and issues SVIDs. The SPIRE agent runs on every node, performs node and workload attestation, and serves the Workload API to the workloads beside it.

The part that crosses boundaries is federation. Two trust domains, say your AWS estate and your on-prem data center, each run their own SPIRE server and their own trust domain. They exchange trust bundles, the public keys each uses to sign its SVIDs. Once domain A trusts domain B's bundle, a workload in A can verify the X.509-SVID a workload in B presents, and mutual TLS between them works across the boundary with neither side holding a secret for the other. This is the thing the per-cloud mechanisms could not do.

## When the Estate Spans Boundaries

SPIFFE pays off where the estate does not fit one cloud. A company running services across AWS and GCP, on-prem VMs next to a Kubernetes cluster, bare metal alongside managed services, needs one identity scheme that spans all of it, and the per-cloud mechanisms cannot provide that, because each only speaks for its own ground. SPIFFE gives every workload, wherever it runs, a name and a verifiable document in the same format, and federation lets workloads on different ground authenticate across the seams.

It is also already under your feet if you run a service mesh. Istio issues SPIFFE IDs to its workloads and uses X.509-SVIDs for mesh mTLS, so the identity model you might adopt deliberately is one a mesh adopts on your behalf. And it is the clean way to give [the machine identities that outnumber your people](/posts/non-human-identities/) short-lived credentials instead of static keys, and to put the service-to-service authentication behind per-app access on attested identity rather than shared secrets.

## Do Not Run SPIRE for One Cloud

For all of that, SPIRE is heavy, and most companies should not run it. It is a certificate authority you operate, an agent on every node, and a server that is now critical infrastructure: it has to be highly available, because when it is down, no workload can get or refresh an identity, and your whole identity plane stalls with it. The registration entries are a real management surface that someone has to own.

If your estate is one cloud and the native workload identity covers it, run the native path and leave SPIRE alone. IRSA, GKE Workload Identity, or Azure managed identity solves secret-zero inside its cloud with none of this operational weight, because the cloud is already running the SPIRE-equivalent for you. SPIFFE is worth its complexity precisely when you have outgrown a single cloud's identity plane, when workloads that must trust each other live on different ground. Reach for it then. Reaching for it while everything still runs in one account is buying a cross-domain solution for a problem that has not yet crossed a domain.

## Identity That Rests on the Ground

The secret-zero problem never fully disappears. Something at the bottom has to be trusted with no secret beneath it, and the only honest options are a secret you placed by hand or a property the platform can attest. SPIFFE picks attestation, and SPIRE turns it into identity that means the same thing across clouds, data centers, and bare metal.

Inside one cloud, let the cloud be the ground. When your workloads no longer share one, SPIFFE is how you give them a name that crosses the wall, resting on attested fact instead of one more secret.
