+++
date = '2026-06-10T12:00:00-07:00'
draft = false
title = 'The Broker Is the Choke Point'
aliases = []
description = "Getting rid of standing access sounds simple until you ask how anyone gets in when they need to. An authorization broker is the answer: a choke point that issues short-lived, scoped, audited access. Here's when a broker earns its keep and when native IAM is already enough."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Access Management', 'Teleport', 'Just-in-Time Access', 'Least Privilege', 'PAM', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

"No standing access" is the goal everyone agrees on and almost nobody can explain the mechanics of. If the on-call engineer does not have permanent production access, how do they get in at 3am when the database is down? If the deploy pipeline does not hold long-lived cloud keys, what does it present? The honest answer is that "no standing access" is something you build, and the thing you build is a broker.

## What a Broker Actually Does

An authorization broker sits between the people and workloads that need access and the resources they need it to. Instead of granting standing access to the resource, you grant access to the broker, and the broker issues short-lived, scoped, audited credentials on demand. [Teleport](https://goteleport.com/), [HashiCorp Boundary](https://github.com/hashicorp/boundary), [StrongDM](https://www.strongdm.com/), and at the cloud-native end [AWS IAM Identity Center](https://aws.amazon.com/iam/identity-center/) are all variations on this. Several of them are open source or free to self-host: Teleport ships an open-source community edition; Boundary and [HashiCorp Vault](https://github.com/hashicorp/vault) are free and self-hostable, with Boundary brokering the sessions and Vault the short-lived credentials behind them; and [JumpServer](https://github.com/jumpserver/jumpserver) is a fully open-source bastion and PAM.

The shape is always the same: request, policy check, short-lived grant, full audit, automatic expiry. The engineer asks for production database access. The broker checks policy (are they on call, is there an incident, is there approval), issues a credential good for an hour, records the session, and expires the grant when the window closes. The resource never had a standing door for that engineer. The broker opened one, watched it, and closed it.

![The Broker Access Lifecycle With Approval: a Requester Asks With Justification, the Broker Runs a Policy Check and, When a Request Needs Human Approval, Routes It to an Approver in Slack or Email, Then Issues a Short-Lived Scoped Credential That Is Logged, Used Within a Recorded Session, and Expires With No Standing Door](diagram-broker-lifecycle.png)

## Why the Broker Earns Its Keep

The value is concentration. Audit, policy, session recording, credential lifetime, and revocation all live in one place instead of being reimplemented at every resource. Without a broker, "expire this access" means doing it correctly in your database, your Kubernetes cluster, your cloud console, and your internal tools, each with its own model. With a broker, expiry is the broker's job, applied uniformly across all of them.

This is the precondition the [telemetry-driven access-review model](/posts/telemetry-driven-access-reviews/) depends on. You cannot run on short-lived access unless something issues and expires it, and the broker is that something. It is also where you get the one thing standing access can never give you: a clean answer to "who had access to this, when, and why." Because every grant flowed through the broker, the answer is a query, not an archaeology project.

## When You Don't Need One

A broker is infrastructure, and infrastructure has a cost. There are cases where it is overhead.

If you are entirely in one cloud, that cloud's native tools may already give you most of a broker. AWS IAM Identity Center with short-session roles, GCP IAM with short-lived credentials, Azure PIM for just-in-time elevation: inside a single provider you can get request, scope, and expiry without a separate product. The broker earns its keep when you span things native IAM does not cover together: databases, Kubernetes, SSH, internal apps, more than one cloud. The more heterogeneous the resources, the more a single choke point is worth. In a homogeneous single-cloud shop, a dedicated broker can be a box you run for benefits you already had.

There is also a case the broker should not touch at all: workloads. The pattern is built around an interactive request, where a person asks, a policy check runs, and a short-lived credential comes back. Service-to-service access does not work that way. A workload that needs to reach a database should present its own identity and get short-lived credentials directly, which is [workload identity](/posts/when-you-can-use-workload-identity/), not a brokered session. Routing machine-to-machine traffic through a human-shaped broker adds latency, a runtime dependency, and a queue in front of something that should be a direct, identity-based call. Brokers mediate human access to systems. Workload identity mediates system access to systems. Keep the two apart.

Scale is the other limit. At small scale the broker is the expensive rung: a few engineers, a couple of systems, and a password manager with MFA and careful IAM will out-deliver a broker you have to run, patch, and integrate. The broker earns its place when the number of operators times the number of heterogeneous systems makes per-system access management the real cost. Below that line it is infrastructure looking for a problem.

## The Broker Is Also a Risk

The choke point cuts both ways. A broker that every access flows through is a single point of failure and a high-value target.

If it is down, nobody gets in, so it needs its own carefully designed break-glass path. If it is compromised, the attacker is standing at the one place that can mint access to everything, so it has to be the most hardened system you run. The broker does not remove the risk of standing access. It concentrates that risk into one well-watched place, which is a far better posture than risk smeared across every resource. But it is a concentration, and you have to treat it like one: hardened, monitored, and never the thing you forgot to patch.

## Build the Door, Then Remove the Others

"No standing access" is a property of a system that has somewhere to route access through. You do not get there by deleting permissions and hoping. You get there by building the broker first, proving people can still do their jobs through it, and then removing the standing doors one resource at a time.

The goal is zero standing access: people can still get in, but every grant is requested, scoped, and gone on a timer. Build the door that does that, and you can finally close the rest.
