+++
date = '2026-07-06T00:01:00-07:00'
draft = false
title = 'Your Authorization Model Is Never Done'
aliases = []
description = "Fine-grained authorization in a product starts clean: a Zanzibar-style relationship model answering who can touch which object. Then it grows new object types, new permissions, and the urge to layer in roles and groups, and the access graph never stops changing. The hard part was never the model; it's migrating it while it's live. Here's the problem, how to model it, and the open-source engines that help."
categories = ['Security', 'Engineering']
tags = ['Security', 'Authorization', 'Product Security', 'ReBAC', 'Zanzibar', 'OpenFGA', 'Fine-Grained Authorization', 'IAM', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Every time we came back to authorization in the product, the model had grown. Another object type that needed sharing. Another permission that had to be finer than read and write. Another request to manage it all with roles or groups instead of one-off grants. We had reached for a Zanzibar-style model in the first place because the permissions had outgrown a role column, and then the model itself refused to hold still. The access graph kept changing under us, and the lesson took a while to land: designing the model was the easy part. Keeping it correct as it grew was the work.

## Why the Object Needs Relationships

Product authorization ends up here for the same reason [a gateway cannot make the decision](/posts/the-gateway-cant-see-the-object/): whether Alice can open this document is a fact about the relationship between Alice and the document, and that fact lives in the data. Google wrote [Zanzibar](https://research.google/pubs/zanzibar-googles-consistent-global-authorization-system/) to answer questions of exactly that shape at scale, and the model is simple to state. Permissions are stored as relationship tuples: Alice is an editor of document 12, the engineering group is a viewer of folder 4, document 12 lives in folder 4. A check is a graph traversal: can Alice view document 12, through any path of those relationships? Access can be inherited, shared, and nested, which is what real products do and what a flat list of roles cannot express.

![Relationship Tuples and a Check Traversal: Alice Is a Member of the Engineering Group, the Engineering Group Is a Viewer of Folder 4, and Document 12 Has Folder 4 as Its Parent; the Check "Can Alice View Document 12?" Resolves to YES by Traversing Alice Through the Group Through the Folder to the Document](diagram-relationship-graph.png)

## The Model Grows Three Ways

What the demos never show is what happens next, because in a demo the schema is fixed. In a product it grows, and it grows along three axes at once.

**New object types.** Every feature that ships something users can share, a document, a dashboard, a project, a folder, a comment, adds an object type the model has to know about, with its own relations and its own inheritance rules.

**New permissions.** Read and write stop being enough. Now there is comment-but-not-edit, share-but-not-delete, workspace-admin-but-not-billing. Each is a new relation or a new computed permission layered onto objects that already exist.

**New ways to manage it.** The moment there are more than a handful of users, someone asks to manage access with groups and roles instead of granting people one object at a time. That is a reasonable request, and it reshapes the model, because now groups and roles are objects in the graph too.

Three axes, all moving, on a graph that is already in production with real tuples in it. The schema you designed last quarter is not the schema you are running today.

## Roles and Groups Are Just More Relationships

The good news about the third axis is that you do not abandon the relationship model to get roles and groups. You express them inside it. A group is an object, membership is a relation, and "the engineering group is a viewer of this folder" is one tuple that grants every current and future member access through the group. A role is a named set of relations, a userset in Zanzibar's terms, that other relations point at. [OpenFGA](https://openfga.dev/) and [SpiceDB](https://authzed.com/) both give you a schema language for exactly this: you define the object types, the relations between them, and the permissions computed from those relations, and roles and groups fall out as patterns in that schema rather than a separate system running alongside it.

The discipline it asks for is real. Every one of those modeling choices, what inherits from what, whether a role is per-object or global, how a group nests inside another group, is a decision encoded into a schema that is hard to change later. Which is the actual problem.

## The Migration Is the Hard Part

Designing a relationship schema is straightforward. Migrating a live one is the hard part.

![Schema Migration With Dual-Write and Background Backfill: Application Writes Are Dual-Written to Both the OLD and NEW Schema Stores, Checks Are Routed by Schema Version to Either Store, and a Background Process Copies and Reshapes OLD Tuples Into the NEW Shape Until Cutover; Both Schemas Must Return Correct Answers Throughout the Transition](diagram-schema-migration.png)

Adding a new relation is usually safe: nothing referenced it before, so nothing breaks. The hard changes alter the meaning of an existing relation, restructure inheritance, or split one object type into two. Those require backfilling tuples across every existing object, sometimes millions of them, while the old model and the new model both have to return correct answers during the transition. You dual-write, you migrate the graph in the background, you version the schema, and you do all of it without a window where a check returns the wrong answer, because a wrong answer here is either a user locked out of their own data or a user reading someone else's.

This is the modeling-versus-migrating split, and it is where the cost actually lives. OpenFGA and SpiceDB help, with schema versioning and tooling to write and validate models, but the migration logic and the tuple backfill are yours to build, the same way a database migration is yours even though the database hands you the tools. The teams that struggle are the ones that treated the first schema as the design, when the first schema is only the first of many.

## The Consistency Problem You Inherit

A central authorization service brings a second cost, and Zanzibar's paper is mostly about it. The check is now a call in the request path, so it has to be fast, and it has to be consistent. The consistency part is the subtle one. If you remove someone's access and then immediately check it, you must not get a stale yes, because a stale yes is a leak. Zanzibar solves this with a consistency token, the zookie, that pins a check to a point in time at least as fresh as the change you care about. Whatever engine you pick, you inherit this problem, and engines handle it differently: [SpiceDB](https://authzed.com/) is built around strong consistency tokens in the Zanzibar tradition, while others trade some consistency for latency. Know which trade your engine made before you find out the hard way.

## The OSS That Helps

The open-source landscape here is genuinely good now, which was not true a few years ago.

For relationship-based authorization in the Zanzibar shape, the two leading engines are [OpenFGA](https://openfga.dev/), a CNCF project backed by Okta, and [SpiceDB](https://authzed.com/) from AuthZed. Both give you a schema language, a tuple store, and a fast check API. [Ory Keto](https://www.ory.sh/keto/) is another Zanzibar-inspired option that fits the Ory stack.

If your authorization is more about policy and attributes than a relationship graph, [AWS's Cedar](https://www.cedarpolicy.com/) is a policy language built for per-object decisions, available managed as [Amazon Verified Permissions](https://aws.amazon.com/verified-permissions/), and [Oso](https://www.osohq.com/) embeds a policy engine directly in your application. [Topaz](https://www.topaz.sh/) pairs an OPA policy engine with a Zanzibar-style data model and runs locally beside your service. And if you would rather not operate the engine yourself, [Permit.io](https://www.permit.io/) is a managed layer over OpenFGA and OPA.

The right engine follows the shape of your problem. A graph of who-can-reach-what through sharing and nesting wants OpenFGA or SpiceDB. A pile of conditional rules over attributes wants Cedar or OPA. Most products end up wanting some of both, and the engines are converging toward supporting that.

![Authorization Engine Landscape: Graph-Shaped Engines (OpenFGA, SpiceDB, Ory Keto) for Sharing and Nesting Sit Above Policy-Shaped Engines (Cedar / Amazon Verified Permissions, OPA, Oso, Topaz) for Rules Over Attributes; Permit.io Sits Below Both as a Managed Layer Over OpenFGA and OPA for Teams That Do Not Want to Operate the Engine](diagram-authz-engines-landscape.png)

## Most Products Don't Need This Yet

For all of it, the most common mistake with fine-grained authorization is adopting it too early. A relationship engine is real infrastructure: a new service in the critical path, a consistency model to understand, a schema to own and migrate. If your product's access model is "users belong to a tenant, and within a tenant there are a few roles," you do not need Zanzibar. RBAC and a tenant check carry you a long way, and reaching for a relationship graph before your access is one is the same over-engineering as [minting a role for every exception](/posts/roles-dont-scale-the-way-you-think/), pointed the other direction.

Reach for fine-grained authorization when the product genuinely has the shape that demands it: per-object sharing, nesting and inheritance, permissions that vary by resource rather than by role. And when you do, design for the migration from the first day, because the schema you ship is the first of many and the second one arrives sooner than you expect.

## Build for the Second Schema

Authorization in a growing product is not a model you finish. It is a surface that keeps changing as the product adds objects, permissions, and ways to manage them, and the teams that handle it well are the ones that planned for change instead of for a clean first design.

Pick an engine that fits the shape of your access. Model roles and groups as the relationships they already are. And treat the first schema as a draft, because the access graph will not hold still, and the work that matters is keeping it correct while it moves.
