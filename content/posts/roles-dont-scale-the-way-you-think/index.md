+++
date = '2026-06-19T12:00:00-07:00'
draft = true
title = "Roles Don't Scale the Way You Think"
aliases = []
description = "Role-based access ends the per-hire negotiation over who gets what, and then it collapses under its own weight: a role for every exception, thousands of roles nobody can audit. The model that survives is a few coarse birthright roles plus requested access for the rest, with attributes doing the work roles can't. Here's how to design for the hybrid you'll actually run."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'RBAC', 'ABAC', 'Access Management', 'Least Privilege', 'Authorization', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

The pitch for role-based access control is clean and convincing. Define what a back-end engineer gets once, attach it to a role, and every back-end engineer inherits it. No more negotiating access per hire, no more guessing what the last person in this job had. You model the org once and access follows the model.

Then reality adds an exception, and another, and the model starts to fracture. The back-end engineer who also needs production read access. The one on the on-call rotation. The one on the payments team who needs the extra system. Each exception becomes a new role, because a role is the only tool the model gives you, and a few years later you have more roles than employees and no one who can say what half of them are for. Roles do scale. They just scale in the wrong direction.

## What Roles Were Supposed to Do

The problem RBAC solves is real, and worth keeping in view while we talk about where it breaks. Before roles, access is negotiated per person: a new hire gets whatever someone remembered to grant, usually by copying the access of whoever sat near them, which copies the last person's mistakes along with it. There is no definition of correct, so there is no way to be correct.

A role gives you that definition. [NIST formalized RBAC](https://csrc.nist.gov/projects/role-based-access-control) decades ago around a simple idea: put permissions on roles, put people in roles, and you can finally answer what a given job is supposed to have. For the stable core of an organization, this works exactly as advertised. Everyone in customer support gets the support tools. Everyone in finance gets the finance suite. Define it once, attach it by job, done.

The model holds as long as access is a function of the job. It breaks where access is a function of anything else.

## Role Explosion

Access is rarely a clean function of the job title, and every dimension that the title does not capture becomes a source of new roles.

Start with one role: `engineer`. Some engineers need production read, so now there is `engineer` and `engineer-prod-read`. Production access varies by team, so each of those splits per team. On-call engineers need elevation, so each team's set doubles again. Add a contractor variant that excludes a few systems, add a region for data-residency reasons, and the single role has become dozens. Repeat across every department and the count runs into the thousands.

This is **role explosion**, and its signature is an organization with more roles than people. When that happens, the model has stopped doing its job. The point of roles was to make access legible, to let someone look at a role and know what it means. Ten thousand roles are not legible. Nobody audits them, nobody prunes them, and access certifications turn into rubber-stamping lists of role names whose meaning no one remembers. You have recreated the per-person mess you started with, dressed up as governance.

The mistake underneath role explosion is treating every distinct combination of access as something that needs its own role. Most of those combinations are not jobs. They are the intersection of a job with an attribute, and attributes are a different tool.

## Role-Based vs Attribute-Based

Two models answer the access question in different ways, and the design skill is knowing which to use for which dimension.

**Role-based** access derives permissions from role membership, decided ahead of time. You are in the `finance-analyst` role, so you get the finance-analyst permissions. It is static, readable, and easy to audit, because the grant is a fact you can look up.

**Attribute-based** access derives permissions from attributes evaluated at the moment of the request. [NIST's model for ABAC](https://csrc.nist.gov/pubs/sp/800/162/final) describes it as a policy that considers attributes of the user, the resource, and the context together: grant access when the user's department equals the resource's owning department, when the request comes from a managed device, when the data's region matches the user's. The decision is computed, not pre-assigned.

The power of attributes is that they collapse the combinations that explode roles. Instead of `engineer-team-payments-prod-read` as a named role, you write one policy: an engineer may read production for the team they belong to. The team is an attribute, not a role, so one rule covers every team at once. [AWS calls this tag-based access control](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html): tag the resource with its team, tag the principal with theirs, and a single policy grants access when the tags match, no matter how many teams exist. The roles that would have exploded become attribute values that cost nothing to add. If you are enforcing this in your own services rather than a cloud IAM, [Casbin](https://casbin.org/) is an open-source library that implements both RBAC and ABAC, and [OPA](https://www.openpolicyagent.org/) evaluates attribute policies as a standalone engine.

## The Model That Survives Is Hybrid

The workable design is not all roles or all attributes. It is a small number of coarse roles carrying the stable, everyone-in-this-job baseline, with attributes handling the dimensions that vary and would otherwise multiply the roles.

Keep the roles broad and few. `engineer`, `support`, `finance-analyst`, the dozen or so real jobs your company has. These define [birthright access](/posts/automate-the-leaver-before-the-joiner/), the baseline everyone in the role gets automatically. Resist the urge to encode every variation as a sub-role.

Push the variation into attributes. Team, region, device posture, environment, data sensitivity: these are the things that made roles explode, and they are exactly what attribute policies handle in one rule each. The combinatorial mess becomes a handful of policies that read like sentences.

And leave the genuinely individual, high-sensitivity access to the **requested** path: asked for, approved by an owner, granted for a reason, and reviewed. Not everything should be automatic. The production admin grant should cost a human decision, not fall out of a role or a policy.

| Dimension | Right tool | Why |
|---|---|---|
| The stable job baseline | A coarse role | Same for everyone in the job, easy to read and audit |
| Team, region, environment, device | An attribute policy | Varies per person; one rule beats one role per value |
| High-sensitivity, individual access | A request with approval | Deserves a human decision and a reason, not a default |

That table is the whole design. Most teams get it wrong by forcing all three rows into the first one, modeling every team and every variation as another role, until the role catalog is the problem it was meant to solve.

## Attributes Move the Complexity, They Do Not Delete It

It would be tidy to say attributes fix everything, and they do not. ABAC trades one hard problem for another, and you should choose it with the trade in view.

Roles are easy to audit and hard to scale. A role grant is a static fact, so you can list who has a role and reason about it directly, which is why auditors like them. They just multiply badly.

Attributes scale well and are hard to audit. One policy covers a thousand teams, but answering who can actually reach a given resource now means evaluating a policy against every user's attributes, not reading a list. The complexity did not disappear when you moved it off the roles. It moved into the policies and into the attribute data those policies depend on, and that data has to be clean, current, and trustworthy or the whole thing grants wrong. An ABAC policy keyed on department is only as correct as the department field in your HR system. Garbage attributes produce garbage access, computed confidently.

So the dimensions you move to attributes should be the ones whose data you actually trust and keep current, usually the things sourced from the HRIS and the cloud resource tags. The dimensions you cannot keep clean are better left as explicit roles or requests, where the grant is at least visible. This is the same reason access has to be watched after it is granted regardless of model: [usage telemetry](/posts/telemetry-driven-access-reviews/), not the role catalog, is what tells you whether the access any of these mechanisms produced is actually right.

## Stop Modeling Exceptions as Roles

Roles are a good tool for the part of access that is a clean function of the job, and a bad tool for everything else. The failure mode is using them for everything else anyway, one new role per exception, until the catalog is larger than the company and means nothing.

Keep a few coarse roles for the baseline. Move the variation to attribute policies you can trust. Send the sensitive, individual grants through a request with a human on the other end. The same discipline applies whether you are scoping a person or [scoping an agent to capabilities](/posts/agents-need-capabilities-not-roles/): the unit of access should match the shape of the decision, and most decisions are not a job title. The role catalog should stay small enough to read. The moment it is larger than your headcount, the model is no longer describing your company. It is hiding it.
