+++
date = '2026-06-26T00:01:00-07:00'
draft = false
title = "The Gateway Can't See the Object"
aliases = []
description = "An API gateway can check whether you may call an endpoint. It cannot see whether this row, this document, this tenant is yours, because the object lives inside the application. Fine-grained authorization, policy engines like OPA and Cedar and relationship models like Google's Zanzibar, moves the decision next to the data. Here's when you need it and what it costs to run."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'Authorization', 'OPA', 'Cedar', 'ReBAC', 'Fine-Grained Authorization', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

A user calls `GET /invoices/4471` and gets back an invoice. The gateway in front of the service did its job: it checked that the request carried a valid token, that the user was authenticated, and that this user is allowed to call the invoices endpoint. Every check passed. The only problem is that invoice 4471 belongs to a different customer, and the user just read it by changing a number in the URL.

This is the most common serious flaw in modern applications, and it has a name: broken object-level authorization, the [number one risk on the OWASP API Security list](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/). It happens because the gateway authorizes the route and not the object. It can see that you are allowed to ask for invoices. It cannot see whose invoice 4471 is, because that fact lives inside the application, in the data, where the gateway never looks.

![The broken-object-level-authorization flow. A user in tenant A requests GET /invoices/4471. The API gateway checks the route, sees a valid token and that the user may call the invoices endpoint, and passes the request. The invoices service returns invoice 4471, which belongs to tenant B, and the user reads another tenant's invoice. The object question, whether 4471 is tenant A's, is something the gateway cannot see and nobody asked](diagram-route-vs-object.png)

## Two Questions, Answered in Two Places

Every access to a piece of data is really two questions stacked on top of each other, and they get answered in different places by different things.

The first is coarse: may this user use this capability at all? May they call the invoices API, reach the reports service, open the admin section? This is answered at the edge, by the gateway or the service's front door, against the user's role or token. It is the question [roles and the perimeter](/posts/roles-dont-scale-the-way-you-think/) are good at.

The second is fine: may this user act on this specific object? May they read invoice 4471, edit document 88, see the records for this one tenant? This cannot be answered at the edge, because the edge does not know that invoice 4471 belongs to tenant X. Only the application knows that, because the relationship between the user and the object lives in the data the application owns. The decision has to happen where the object is.

Most breaches of this kind come from answering the first question and assuming it covered the second. The user was allowed in the building, so the application handed over whatever room number they asked for.

## Coarse vs Fine-Grained

The distinction is worth naming because designs go wrong by using the coarse tool for the fine job.

**Coarse authorization** is about capabilities and endpoints. It is checked once, at the boundary, and it is the same for every object behind that boundary. A coarse check says you may read invoices. It says nothing about which ones.

**Fine-grained authorization** is about specific objects, and often specific fields and specific context. It is checked per object, at the moment of access, against the actual relationship between this user and this thing. A fine-grained check says you may read invoice 4471, because invoice 4471 belongs to your company and you are a billing admin there.

The coarse check is necessary and cheap, and it is not enough on its own for anything multi-tenant or anything where users own distinct records. The moment your data has owners, the authorization has to know about ownership, and ownership is fine-grained by nature.

## Where the Decision Has to Live

Since the fine-grained decision has to happen next to the data, the only question is how you implement it there, and the answers run from messy to engineered.

The default is **scattered in-app checks**: an `if user.org_id == invoice.org_id` buried in each handler. This works and is correct right up until it is not, because the rule is copied into hundreds of endpoints and the one place someone forgets it is the vulnerability. The logic is real authorization, but it is unauditable and impossible to change centrally.

The first real improvement is to **externalize the policy**. [Open Policy Agent](https://www.openpolicyagent.org/) lets you write authorization rules in a dedicated language and evaluate them as a service or a sidecar, so the rule lives in one place the application calls instead of being retyped in every handler. [AWS's Cedar](https://www.cedarpolicy.com/) is a policy language built for exactly this, expressing per-object permit and forbid rules that an application evaluates at the point of access. The decision still happens next to the data, but the rule is defined and audited centrally.

![The externalized policy-engine pattern. The request passes the gateway's route check and reaches the invoices service, which asks a policy engine, OPA or Cedar, the object-level question with the subject, action, and resource: user, read, invoice 4471. The engine checks whether the invoice's org matches the user's and whether the user is a billing admin. If not, because 4471 belongs to tenant B, it returns 403 Forbidden; if so it returns the invoice](diagram-policy-engine.png)

The rule itself is small. The same object-level check, that the invoice belongs to the caller's org and the caller is a billing admin, looks like this in OPA's Rego:

```rego
package invoices

default allow := false

# Read an invoice only if it belongs to the caller's org
# and the caller is a billing admin there.
allow if {
    input.action == "read"
    input.resource.type == "invoice"
    input.resource.org_id == input.subject.org_id
    "billing-admin" in input.subject.roles
}
```

And the same rule in Cedar, which leans on a typed schema of principals, actions, and resources:

```cedar
// Permit reading an invoice in the principal's own org,
// when the principal is a billing admin.
permit (
    principal,
    action == Action::"readInvoice",
    resource
)
when {
    resource.org_id == principal.org_id &&
    principal.roles.contains("billing-admin")
};
```

Either way the rule lives in one place, the service calls it at the point of access, and the decision is made against the actual object instead of the route. The same call carries invoice 4471 and the caller's identity, so the engine can see what the gateway could not.

For the hardest case, where access depends on relationships, the model is **relationship-based**. Google built [Zanzibar](https://research.google/pubs/zanzibar-googles-consistent-global-authorization-system/) to answer questions like "can Alice view this document," where the answer depends on a graph: Alice is in a group, the group has access to a folder, the document is in the folder. Permissions like that are not a role and not a simple attribute. They are a path through a relationship graph, and Zanzibar stores those relationships as tuples and answers the reachability question fast. The open implementations, [OpenFGA](https://openfga.dev/docs/authorization-concepts) and [SpiceDB](https://authzed.com/), put that model within reach without running Google's infrastructure. This is the right tool when your product has sharing, nesting, and inherited access, the document-and-folder shape, where neither roles nor attributes capture who can actually reach what.

![The relationship-based (Zanzibar) pattern. Three stored tuples form a graph: Alice is a member of the engineering group, the group is an editor of the design-docs folder, and the folder is the parent of the document spec.pdf. The check, can Alice view spec.pdf, is answered by walking that graph from member to editor to parent, so Alice is allowed through access inherited from the folder, with no role and no attribute rule, just a path through the relationships](diagram-relationship-graph.png)

| Shape of the decision | Tool | Example |
|---|---|---|
| Capability or endpoint | Role check at the gateway | May call the invoices API |
| Per-object, attribute-driven | Policy engine (OPA, Cedar) | May read records where `org` matches |
| Relationship or inheritance | Relationship model (Zanzibar, OpenFGA, SpiceDB) | May view a doc shared via a parent folder |

## Externalizing Authorization Has a Bill

It would be easy to read this as "always reach for a policy engine," and that is the wrong lesson. Externalized, fine-grained authorization has real costs, and you should take them on where the data owns the decision, not everywhere.

The first cost is in the request path. A central policy service means every object check is a call to that service, which adds latency and makes it a dependency that must be highly available, because if the authorization service is down, nothing is authorized and the application is down with it. Teams answer this with sidecars, local caches, and embedded evaluation, and all of those are more moving parts than an `if` statement.

The second cost is modeling. A relationship model is only as good as the relationships you load into it and keep current, and mapping your domain into tuples is genuine design work that does not pay off for a service with three endpoints and no sharing. Reaching for Zanzibar to gate a handful of routes is the mirror image of the [role explosion problem](/posts/roles-dont-scale-the-way-you-think/): the wrong tool, scaled past where it fit.

So the calibration is the same one that runs through all of this. Use the gateway's coarse check for capability, keep simple object checks simple, and bring in a policy engine or a relationship model when the data's ownership and sharing are complex enough that scattered in-app logic has become the bigger risk. The goal is to put the decision where the object is, with a mechanism matched to how hard the decision actually is.

## Authorize the Object Where the Object Lives

The gateway guards the door, and the door is worth guarding. It just cannot see inside the rooms, because the thing that decides whether this record is yours is the record, and the record is in the application. Coarse authorization at the edge plus the assumption that it covered the objects behind it is exactly how a user reads someone else's invoice by editing a URL.

Check the capability at the boundary. Check the object where the object lives, with a mechanism sized to the decision. The most expensive authorization bugs are the object-level ones: the user got into the building legitimately, and then found every interior door unlocked.
