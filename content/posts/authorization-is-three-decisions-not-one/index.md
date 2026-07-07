+++
date = '2026-07-10T00:01:00-07:00'
draft = false
title = 'Authorization Is Three Decisions, Not One'
aliases = []
description = "Where authorization decisions live, in one central service or in every service that owns its data, is an argument every platform team has and never settles. The policy, the evaluation, and the data a decision needs can each be centralized or not, independently. Here's the decomposition, what OPA, Cedar, and Zanzibar each centralize, and how to choose."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Authorization', 'Product Security', 'OPA', 'Cedar', 'Zanzibar', 'Architecture', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Every platform team has the same argument eventually, and it never ends the same way twice. One side wants a single authorization service: one place that answers "can this user do this" for every service, so the rules live in one spot and the audit is one query. The other side wants each service to decide for itself: no network hop on every check, no shared thing that can take the whole fleet down, no central team to wait on. Both sides are right, which is why the argument keeps coming back. They are also both answering the wrong question.

## The Two Poles

Set the two poles out plainly, because the real options are blends of them, and you cannot blend what you have not named.

**Centralized authorization** puts the decision in one service. Every other service, when it needs to know whether an action is allowed, calls that service with the subject, the action, and the resource, and gets back allow or deny. The rules live in one place. A permission change happens once. Every decision lands in one audit stream. When a regulator asks "who can access patient records," there is one system that can answer.

**Distributed authorization** puts the decision inside each service. The service that owns invoices decides invoice access; the service that owns documents decides document access, each against its own rules and its own data. No call leaves the service to authorize a request. Nothing outside the service has to be up for it to make a decision. Each team owns its authorization the way it owns its schema.

The trade between them is real and it is not subtle. Centralized buys consistency and a single source of truth, at the cost of a network hop on every check and a dependency that has to be more available than everything depending on it. If the authorization service is down, every service that calls it is either failing closed, where nothing is allowed and you are offline, or failing open, where everything is allowed and you are breached. Distributed buys latency and autonomy, at the cost of drift: ten services with their own copies of "an admin can do this" will, over time, disagree about what an admin can do, and the one that drifted is the [object-level bug](/posts/the-gateway-cant-see-the-object/) you ship.

Stated that way it sounds like a straight tradeoff with no winner, which is exactly why the meeting never resolves. The way out is to notice that "authorization" in that sentence is three different things wearing one word.

## Authorization Is Three Things, Not One

Pull the decision apart and it has three parts, and each can be centralized or distributed on its own.

The **policy** is the rules: an admin can delete, a billing user can read invoices in their own org, a document is visible to anyone the folder is shared with. The **evaluation** is the act of running those rules against a specific request to produce allow or deny. The **data** is the facts the rules need to run: which org this user is in, which folder this document lives under, who that folder is shared with.

The central-versus-distributed argument treats these as one switch. They are three. You can centralize the policy while distributing the evaluation. You can distribute both while centralizing the data. The combination that fits your system is almost never "all central" or "all local," and teams that argue it as a binary are fighting over a switch that does not exist.

![Authorization Split Into Three Decisions: the One Question of Centralized or Distributed Authorization Stands In for Three, the Policy (the Rules) Which You Centralize Almost Always as One Source of Truth Authored and Versioned Like Code, the Evaluation (Running the Rules Against a Request) Which You Usually Distribute by Evaluating the Central Bundle Locally in Process With No Shared Failure, and the Data (the Facts the Rules Need) Which You Decide Deliberately Because It Is the Genuinely Hard Part, Centralizing Relationships When Sharing Is a Graph](diagram-three-decisions.png)

## Centralize the Policy

Start with the part that has a clear answer. The policy almost always wants to be central.

Rules scattered across services are the drift problem in its purest form, and they make two questions unanswerable: what is the rule, and where is it enforced. Centralizing the policy means the rules are authored, versioned, reviewed, and audited in one place, as artifacts, the way code is. [Open Policy Agent](https://www.openpolicyagent.org/) is built around this split: you write policy in one repository, and OPA distributes it as bundles. [Cedar](https://www.cedarpolicy.com/) policies are similar artifacts you manage centrally. Centralizing the policy does not require a service to call a central thing at decision time. It means there is one source of truth for the rules, however they are evaluated. OPA and Cedar are the common choices, but the field is wider: [Cerbos](https://www.cerbos.dev/) takes the same author-once approach in YAML, [Oso](https://www.osohq.com/) embeds a policy language in the application itself, and managed services like [Permit.io](https://www.permit.io/) run the engine for you.

## Distribute the Evaluation

The evaluation is the part the central-service camp most wants to centralize and most often should not.

Running the rules is cheap and local. Calling a remote service to run them adds a network round trip to every authorization check, on a path that is already in the critical request path, and turns the authorization service into a dependency that must out-scale and out-uptime everything behind it. The common, and usually better, pattern is to centralize the policy and push it down: OPA runs as a [sidecar](/posts/whose-request-is-this-three-hops-in/) next to each service, evaluating the same central bundle locally; Cedar evaluates embedded in the application. The decision runs in microseconds, in process, with no shared point of failure, against rules that still came from one place.

There is a real case for central evaluation: when the decision needs data only the central service has, or when you want every decision in one stream you fully control. The [OpenID AuthZEN](https://openid.net/wg/authzen/) standard exists to make that call a standard interface rather than a proprietary one, so a central decision point is not a lock-in. But reaching for remote evaluation by default, when local evaluation of a central policy would do, is how teams build an availability dependency they never needed.

## The Data Is the Hard Part

Here is where the argument lives. Evaluating a policy needs facts, and the facts are the problem.

A rule like "a user can read invoices in their own org" needs the user's org and the invoice's org. Those facts live in the services that own users and invoices. If the decision runs locally, it has the data it owns and may be missing the data it does not. If the decision runs centrally, the central service needs that data, which means either the data is replicated to it and can be stale, or it calls back to the owning services at decision time and is chatty and slow. There is no arrangement that makes the data both local and consistent everywhere.

This is the whole reason [Zanzibar](https://research.google/pubs/zanzibar-googles-consistent-global-authorization-system/) exists. Google's answer to "can Alice view this document," where the answer is a path through a relationship graph, was to centralize the data: store every relationship as a tuple in one system, and meet the consistency problem head-on with zookies, tokens that let a caller demand a decision no staler than a known point. [OpenFGA](https://openfga.dev/) and [SpiceDB](https://authzed.com/) bring that model within reach. What they centralize is the [relationship data](/posts/your-authorization-model-is-never-done/), more than the policy or the evaluation, because that is the part that is genuinely hard to make both correct and fast once it is spread across services.

![The Blend That Usually Wins: a Central Policy Repository Authored, Versioned, and Reviewed Like Code Pushes Policy Bundles Down to Each Service, Where an OPA Sidecar or Embedded Cedar Decides in Process in Microseconds, and When Sharing Is a Graph the Services Make Relationship Checks Against a Central Tuple Store on the Zanzibar Model, OpenFGA or SpiceDB, With Consistency on Demand via Zookies](diagram-blend-architecture.png)

## When Each Choice Is the Wrong One

Each part has a cost, and the costs land differently depending on who you are.

Central evaluation is wrong when the dependency is worse than the drift. A service that every request waits on is a single point of failure for the entire product, and the team that owns it becomes the team every other team is blocked on. Plenty of outages are the thing in front of the database, the layer that decides who may call it, while the database itself is fine. For a fast-moving product with a few services and a small team, a central decision point is a bottleneck and an availability risk, bought to solve a consistency problem you did not have yet.

Distributing everything is wrong when you can no longer answer the questions that matter. When "who can access this kind of data" takes a week and a spreadsheet because the answer is spread across forty services with forty implementations, you have pushed autonomy past the point where anyone can reason about access at all. That is the shape that fails an audit and hides the [attack you cannot see](/posts/the-other-half-of-identity-security/), because no single place knows what is reachable.

So the inputs to the decision are how many services and teams you have, how badly you need one answer to "who can do what," how much latency and shared-failure risk you can tolerate, and how complex your data's ownership and sharing actually are. A three-service startup and a four-hundred-service bank should land in different places, and both can be right.

## Decide the Three, Not the One

The argument that never resolves is the wrong argument. "Centralized or distributed authorization" is one question standing in for three, and the three have different answers. Centralize the policy almost always, because one source of truth for the rules is cheap and worth it. Distribute the evaluation usually, because local decisions are fast and carry no shared failure. Decide the data deliberately, because that is the part that is actually hard, and the part Zanzibar and its descendants exist to handle.

The useful questions are narrower than the one the meeting keeps re-fighting: where should the policy live, where should the evaluation run, and where does the data have to be consistent. Answer those three for your constraints, and the binary turns out to have been three smaller decisions all along, each with an answer you can actually defend.
