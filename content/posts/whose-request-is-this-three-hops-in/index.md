+++
date = '2026-07-09T00:01:00-07:00'
draft = false
title = 'Whose Request Is This, Three Hops In?'
aliases = []
description = "A service mesh gives you mTLS and proves one service is talking to another. It does nothing to carry the original user's identity through the downstream calls, so authorization deep in the call graph falls back to trusting that the request came from inside. In multi-tenant SaaS, that dropped identity becomes a class of tenant-isolation and broken-authorization bugs. Here's how to carry the caller's identity through the call graph and enforce it on every hop, and where the chain legitimately breaks."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'Authorization', 'Kubernetes', 'Service Mesh', 'mTLS', 'Multi-Tenancy', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

A request comes into your product carrying a real, authenticated user. By the third internal service it touches, that user is gone. The service writing to the database does not know who made the request or which tenant they belong to. It knows only that the call came from another service inside the cluster, and inside the cluster, services trust each other. The user authenticated once, at the front door, and their identity quietly fell off the request somewhere in the hallway.

## The Front Door Checks the User. The Hallway Doesn't.

Most products authenticate the user hard at the edge. The API gateway validates the session or the JWT, confirms who they are, and decides whether they may call this endpoint at all. From there, handling the request fans out into internal calls: the API service calls the orders service, which calls billing, which calls the ledger. The question "is this user allowed to do this" was answered once, at the edge, for the entry point. It rarely gets asked again on the way down.

The fan-out is easy to underestimate. Eight or nine years ago, on a consulting engagement, we traced a single inbound API call and counted 22 service calls behind it. The write-up was mostly about latency and instability, because 22 hops is 22 timeouts, retries, and partial failures, but the part that stayed with me was that somewhere in those calls, the user was gone. Nobody had decided to drop identity. It just was not any one service's job to carry it.

In Kubernetes this is the default shape, not a mistake someone made. A pod calls another pod's service over the network, and there is no user in that call unless you deliberately put one there. The orders pod has a service account, the billing pod has a service account, and the cluster lets them talk. Whoever the human was that started the request is not part of the picture by the time billing is doing its work. The internal calls run on implicit trust: they came from inside, so they are allowed.

## Channel Identity vs Caller Identity

Two different identities are in play on any internal call, and teams routinely secure one and forget the other.

**Channel identity** is which service is talking to which. mTLS answers it: this connection is between the orders service and the billing service, both proven by certificates, encrypted end to end. A service mesh automates that across the whole cluster, so every pair of services gets a proven, encrypted channel with no application code involved.

**Caller identity** is who the request is ultimately for. The human or external client that authenticated at the front door, on whose behalf every downstream call is being made. mTLS says nothing about this. The billing service can know with certainty that the orders service called it and have no idea which of ten thousand customers the call is about.

The mesh secures the channel. The caller is a separate fact, and it has to be carried deliberately, because nothing in the transport carries it for you.

## What a Service Mesh Actually Gives You

Be precise about what the mesh does, because it does real things and they are easy to mistake for the whole job. [Istio](https://istio.io/), [Linkerd](https://linkerd.io/), and the like give you three. mTLS between every pair of services, so traffic is encrypted and each peer proves its workload identity, usually a [SPIFFE](https://spiffe.io/) identity baked into the certificate. Authorization policies on that workload identity, so you can say the orders service may call billing while the reporting service may not. And reduced routes, so a service can reach only the specific services it declares, which shrinks the blast radius of a compromised pod. [Cilium](https://cilium.io/) does the same job at the network layer with eBPF instead of sidecars, and [Consul](https://www.consul.io/) covers the same ground outside Kubernetes; the pattern holds whichever one you run.

Every one of those is about the workload. Which service, reaching which service, over an encrypted channel. That is the channel-identity half done well, and it is worth having. It is also silent on the caller. An attacker who lands in the orders pod, or a bug in the orders code, calls billing as the orders service, which is exactly what the mesh exists to allow. The mesh will faithfully encrypt and authorize a request to move money for the wrong customer.

## The Dropped Passenger

So where does the user go? One of two places, and both are common.

The first is that the edge drops the user entirely. The gateway authenticates them, then the first internal service makes its downstream calls using its own service identity and a set of parameters. The user's token never leaves the edge. Everything downstream runs on ambient authority: the orders service is powerful, it can write any order, and it decides what to do from the IDs passed in the call. This is the confused deputy in its natural habitat. The downstream service holds the authority, the caller supplies the target, and nobody checks that the caller was entitled to that target.

The second is subtler and more dangerous. The user's token is passed downstream, sitting in a header, technically present at every hop, and no service downstream actually validates it or makes a decision with it. The ledger service sees a JWT, does not check it, trusts that someone upstream already did, and acts on the account ID in the request body. Carried but not enforced is worse than dropped, because it looks like the work is done. There is a user identity right there in the request. It just is not load-bearing.

![The Dropped Caller: a User in Tenant A Sends a Request With a Token, the API Gateway Validates It and Is the Only Hop That Knows the Caller, Then Each Internal Call From Gateway to Orders to Billing to Ledger Proves the Channel With mTLS While the Caller Is Dropped, Until the Ledger Writes an Entry Using a tenant_id From the Request Body With No User Check Because the Call Came From Inside](diagram-dropped-caller.png)

## Logical Segregation Is Where This Bites

This stays theoretical until multiple tenants share the same services, which is most SaaS. Multi-tenant products almost always run on logical segregation: one set of services, one or a few databases, and the boundary between tenant A and tenant B enforced in code, by a `tenant_id` on every row and a `WHERE tenant_id = ?` on every query. There is no physical wall. The isolation is an invariant the application has to maintain on every single data access.

Now combine that with a call graph that does not carry the caller. A downstream service that trusts its caller and acts on the IDs it is handed cannot enforce the tenant boundary, because it does not know whose request this is. If the tenant scoping is derived from a value the caller controls instead of from a verified user identity, then a request originating in tenant A that reaches a service willing to act on `tenant_id = B` has crossed the boundary. The bug might be an [object reference the gateway never saw](/posts/the-gateway-cant-see-the-object/), an internal endpoint that takes an account ID and trusts it, a cache keyed without the tenant, a queue message that lost its tenant context. Each is a tenant-isolation failure, and each lives below the front door where the user check happened, in the part of the system that assumed everything internal was safe.

This is a whole category, not a single finding: every internal call that touches tenant-scoped data and does not re-derive the tenant from a verified caller is a candidate. In a logically-segregated system, that is most of them.

## Carry the Caller, Then Enforce It

The fix is two moves, and you need both. Carry the caller's identity through the call graph, and make a decision with it at every hop that touches user- or tenant-scoped data.

Carrying it: the user identity established at the edge becomes a credential that travels. [OAuth token exchange](https://datatracker.ietf.org/doc/html/rfc8693) is the baseline mechanism. The edge exchanges the user's token for a downstream token that still asserts the user, scoped down to what the next call needs, the on-behalf-of pattern. The newer and more purpose-built answer is [Transaction Tokens](https://datatracker.ietf.org/doc/draft-ietf-oauth-transaction-tokens/), an IETF OAuth working group draft built for exactly this. The edge mints an immutable token asserting the original caller and the request context, and that token is carried and verified through the whole internal call chain, so the ledger service three hops in can still prove who the original user was. Either way, the call now carries two identities: the workload identity from mTLS for the channel, and the caller identity in the token for the user.

Enforcing it: carrying the token does nothing until a service makes a decision with it. This is the [object-level authorization](/posts/the-gateway-cant-see-the-object/) problem repeated at every hop, and the same tools answer it. The mesh can do part of the job. Istio [RequestAuthentication](https://istio.io/latest/docs/reference/config/security/request_authentication/) validates the user JWT, and [AuthorizationPolicy](https://istio.io/latest/docs/reference/config/security/authorization-policy/) can allow or deny on its claims, so you enforce user-aware rules at the mesh layer instead of only service-identity rules. For real object- and tenant-level decisions, the service asks a policy engine, [OPA](https://openpolicyagent.org/), [OpenFGA](https://openfga.dev/), or [Cedar](https://cedarpolicy.com/), the same way the [authorization model](/posts/your-authorization-model-is-never-done/) does at the edge, and the decision is made against the verified caller.

The one rule that closes the tenant hole: derive the tenant from the verified caller identity, never from a value the caller passes in. The `tenant_id` in a verified transaction token is trustworthy. The `tenant_id` in the request body is a suggestion.

![Carry and Enforce the Caller: the API Gateway Validates the User's Token, Exchanges It via RFC 8693 at a Token Service for an Immutable Transaction Token Asserting the Caller, Tenant, and Context, and Every Downstream Hop From Orders to Billing to Ledger Verifies That Token and Authorizes the Caller, So mTLS Proves the Channel While the Token Proves the Caller at Every Hop, and the tenant_id Comes From the Verified Token, Never From the Request Body](diagram-carry-enforce.png)

## Not Every Call Has a Caller

Here is where the model argues with itself. Not every internal call is made on behalf of a user, and forcing a user identity onto the ones that are not is both wrong and impossible. The nightly batch job that recomputes balances has no user. The reconciliation process, the cron that expires sessions, the queue worker draining events, the service warming a cache: these are system-initiated, and for them the [workload identity is the right authority](/posts/when-you-can-use-workload-identity/). Demanding a caller token there is a category error, and teams that try it end up minting fake "system user" tokens that are worse than honest workload identity.

So the real skill is sorting the call graph. Which calls are user-initiated, where carrying and enforcing the caller is mandatory, and which are system-initiated, where the workload identity is the whole answer. The expensive mistake is treating them the same in either direction: putting user-aware authZ on a batch job, or letting a user-initiated call run on pure workload trust.

There is a real cost even where it belongs. Token exchange and per-hop validation add latency and moving parts, and every service that enforces caller authZ needs the policy and the data to make the decision. You will not do this on every call, and you should not. Do it where the call touches user- or tenant-scoped data, which is where the isolation guarantee actually lives, and leave the rest on workload identity.

## Don't Ask Developers to Remember

The weak spot in all of this is memory. A control that exists only when a developer remembers to add it will be missing from some fraction of endpoints, and in a multi-tenant system that fraction is your tenant-isolation bug rate. The sorting from the last section, this call has a caller and this one does not, has to live somewhere more durable than convention. There are four places to put it.

**Declare it on the route, and fail closed.** I have seen systems do this with an attribute or decorator per endpoint: `[UserInitiated]` on the routes that must enforce a caller, `[SystemOnly]` on the ones that run on workload identity. The annotation is not the control; the fail-closed default is. The framework refuses to serve a route that declares neither, so forgetting shows up as a failed startup or a failed CI run instead of a silent hole. The default matters too: undeclared must never mean system. If anything gets to be implicit, it is "user-initiated, caller required," because that failure mode is a 401, not a cross-tenant write. The residual risk is the wrong annotation, which is one code review away. Better than the check being absent, but still a per-endpoint human decision.

**Let one endpoint serve both, carefully.** Some endpoints genuinely take both kinds of traffic: a user triggers a recalculation from the UI, and the nightly batch triggers the same recalculation for every account. The honest version branches on the credential. A transaction token present means caller authorization runs. Workload identity alone means the system policy runs, and the system policy must be narrower, not wider: an enumerated set of operations, not "everything, since there is no user to check." The failure mode to design against is "no caller" quietly becoming "no check." Make system a first-class principal with its own policy, never an absence. If the branch gets complicated, that is the signal to split the endpoint, which is the network-path option in miniature.

**Push it into the service chassis.** If every service is built on a shared platform layer, the chassis, then the chassis validates the transaction token before any handler runs and injects a verified caller context into the request. The handler does not verify anything, and more important, it cannot get a caller or a tenant any other way, because the only tenant accessor reads from the verified context. Pair it with the data layer and the guarantee gets teeth: [Postgres row-level security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html) keyed to a session tenant that only the chassis sets, so even a handler that forgot everything cannot read another tenant's rows. The mesh can take the first slice of this, RequestAuthentication rejecting invalid tokens before they ever reach the app. This is the best return on effort of the four: the check is written once, by the platform team, reviewed hard, and every service inherits it. The precondition is real, though. A chassis has to exist, and the org has to hold the line that services are built on it.

![Chassis Enforcement: an Incoming Internal Call With a Transaction Token Passes Through Platform-Owned Layers, the Mesh Sidecar Rejects Invalid Tokens Before the App Sees Them and the Chassis Middleware Returns 401 Before Any Handler Runs if the Token Is Missing or Unauthorized, Then Injects a Verified Caller Context, So the Developer-Owned Handler Contains Business Logic Only and Reads Caller and Tenant From the Verified Context, Backstopped by Platform-Owned Postgres Row-Level Security Keyed to a Session Tenant Only the Chassis Sets](diagram-chassis-enforcement.png)

**Separate the network paths.** The strongest version makes the user/system sort physical instead of conventional. User-initiated traffic reaches a service on one listener, where the chassis demands and verifies a transaction token, no exceptions. System traffic arrives on a different listener, or a different service entirely, with workload-only authorization and a deliberately smaller API surface. Mesh policy pins the topology: only the gateway's path may reach the user listener, only the batch and cron identities may reach the system listener. Now a batch job physically cannot call the user surface without a caller token, and a user request cannot wander onto the path that never checks one. The cost is real, two surfaces to build, document, and keep from drifting, and it forces the dual-mode question early. It is the right spend at the boundary where the money moves, and overkill applied everywhere.

![Separate Network Paths: the API Gateway Carries User-Initiated Traffic With a Transaction Token Minted at the Edge Over mTLS to the Service's User Listener, Which Requires the Token With No Exceptions and Serves the Full API With the Caller Enforced Per Hop, While Batch, Cron, and Queue Workers With Workload Identity Only Reach a Separate System Listener Over mTLS Serving an Enumerated System Surface, and Mesh Policy Pins the Topology So Only the Gateway's Path May Reach the User Listener and Only Batch and Cron Identities May Reach the System Listener](diagram-separate-paths.png)

None of this requires exotic tooling. The declaration and chassis options map onto things the mainstream stacks already ship, either as language primitives or as boring, well-worn libraries:

| Stack | Declare on the route | Chassis-level enforcement | Carrying the caller in-process |
|---|---|---|---|
| Java / Spring | [`@PreAuthorize`](https://docs.spring.io/spring-security/reference/servlet/authorization/method-security.html) method security | [OAuth2 resource server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/index.html) validates the JWT before any controller runs | `SecurityContextHolder`; [MicroProfile JWT](https://microprofile.io/specifications/microprofile-jwt-auth/) on Quarkus and Liberty was designed for cross-service propagation |
| .NET | `[Authorize(Policy = ...)]` attributes | JWT bearer middleware plus a [`FallbackPolicy`](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.authorization.authorizationoptions.fallbackpolicy) | `HttpContext.User`; [Microsoft.Identity.Web](https://learn.microsoft.com/en-us/entra/msal/dotnet/microsoft-identity-web/) handles on-behalf-of exchange |
| Node / TypeScript | [NestJS guards](https://docs.nestjs.com/guards) with custom decorators | a global `APP_GUARD`, or `express-jwt` / `@fastify/jwt` mounted at the app level | [`AsyncLocalStorage`](https://nodejs.org/api/async_context.html) |
| Python | [FastAPI dependencies](https://fastapi.tiangolo.com/tutorial/security/) per route; DRF permission classes | FastAPI app-level dependencies; DRF `DEFAULT_PERMISSION_CLASSES` | [`contextvars`](https://docs.python.org/3/library/contextvars.html) |
| Go | no annotations in the language; middleware on a router group is the declaration | [`go-oidc`](https://github.com/coreos/go-oidc) verification in chi, echo, or gin middleware; gRPC interceptors | [`context.Context`](https://pkg.go.dev/context) |

Three of those stacks ship the fail-closed switch as a one-liner. ASP.NET's `FallbackPolicy` applies to every endpoint that declared nothing, DRF's `DEFAULT_PERMISSION_CLASSES` does the same for Django, and a NestJS global guard runs on every route unless one explicitly opts out. Turn those on and "forgot the attribute" fails safe out of the box. Go is the honest outlier: with no annotations, the router group *is* the declaration, so the discipline is in where a route gets registered. One caveat across all of them: Transaction Tokens are still an IETF draft, so no library ships support for them yet. What teams run today is a standard JWT library (jose, jjwt, golang-jwt, PyJWT) verifying tokens the gateway mints through RFC 8693 token exchange, which IdPs like [Keycloak](https://www.keycloak.org/securing-apps/token-exchange) already implement.

These are layers, not alternatives. The chassis is the floor, because it is the one that removes the per-developer failure mode. Route declarations sit on top as the explicit, reviewable record of which calls have a caller, with fail-closed as the rule. Row-level security backstops the data. Separate paths are reserved for the one or two boundaries that justify them. The shape to aim for is the same in every layer: the safe behavior is the default that requires no thought, and the unsafe behavior is a visible declaration someone had to write down and a reviewer got to see.

## Whose Request, at Every Hop

The front door is the easy part, and most teams do it well. The work that gets skipped is everything after it, where the request fans out into a dozen internal calls that trust each other because they are inside. A service mesh makes that interior safer, and it is worth running, but it secures the channel, and the channel was never the question. The question is whose request this is, and it needs an answer at every hop that touches someone's data.

Carry the caller. Enforce the caller. Derive the tenant from the caller and never from the call. Do that on the hops that touch tenant-scoped data, and "whose request is this, three hops in" stops being a question your ledger service cannot answer.
