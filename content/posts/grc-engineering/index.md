+++
date = '2026-02-23T10:00:00-08:00'
draft = false
title = 'GRC Engineering: Stop Collecting Frameworks and Start Building a Program'
description = "GRC engineering isn't about making spreadsheets fancier. It's about recognizing that compliance at scale is an engineering problem, and it deserves an engineering solution."
categories = ['Security']
tags = ['security', 'automation', 'AI', 'Artificial Intelligence', 'risk management', 'security architecture', 'devsecops', 'CI/CD', 'process improvement', 'grc engineering']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

The first time I heard the term "GRC engineering," I'll be honest — I didn't get it. Governance, risk, and compliance has always been a discipline built on spreadsheets, document repositories, and a lot of manual effort. Calling it engineering felt like putting a new label on the same work to make it sound more technical than it was.

Then I lived through managing evidence collection across multiple concurrent audits with a small team and a tight timeline. Different frameworks, overlapping controls, redundant requests from different auditors — all pulling from the same systems but requiring separately packaged evidence. I watched capable people spend their days hunting down screenshots, reformatting the same data for different audiences, and context-switching between audit workstreams that were asking fundamentally the same questions.

That's when it clicked. The problem wasn't the people or the effort. The problem was the architecture — or more accurately, the lack of it. We were treating each compliance obligation as its own standalone project instead of engineering a system that could serve all of them. GRC engineering isn't about making spreadsheets fancier. It's about recognizing that compliance at scale is an engineering problem, and it deserves an engineering solution.

Every year, the list gets longer. SOC 2. PCI DSS. ISO 27001. NIST CSF. HITRUST. Whatever your customers or regulators require next. And every year, most organizations respond the same way — they bolt on another set of controls, hire another analyst, and white-knuckle their way through another audit cycle.

This doesn't scale. At some point, and most companies hit it sooner than they think, the compliance burden becomes so heavy that it actively works against the security outcomes it's supposed to support. Teams spend more time collecting screenshots and chasing evidence than they do actually improving controls. Engineering gets fatigued by redundant requests from three different audit workstreams asking for the same data in slightly different formats. The business starts treating compliance as a tax instead of a function that enables growth.

GRC engineering is the answer to this problem. Not as a buzzword or a job title, but as a discipline — an intentional decision to treat your compliance program the way you'd treat any other engineering challenge: with architecture, automation, and a focus on sustainability.

## The Accumulation Problem

Here's what typically happens. A company achieves SOC 2 because its first enterprise customers require it. A year or two later, a major prospect in financial services needs PCI DSS. Then a healthcare opportunity surfaces and suddenly HITRUST is on the roadmap. Each framework gets its own project plan, its own control mapping, its own evidence repository, and often its own analyst or consultant.

The problem isn't that companies pursue multiple frameworks. The problem is that they pursue them independently. SOC 2's Change Management criteria and PCI DSS Requirement 6 are asking fundamentally similar questions about how you manage changes to your environment. But if those frameworks live in separate spreadsheets with separate owners collecting separate evidence, you've just doubled your work for a single control objective.

Multiply that across dozens of overlapping controls and you start to understand why compliance teams feel like they're drowning despite doing good work. The effort isn't wasted — it's duplicated. And duplication, left unchecked, compounds with every framework you add.

## Unify the Controls, Then Automate the Evidence

The first step in GRC engineering is also the most important: build a unified control framework. This means taking every control across every framework your organization is subject to and mapping them to a single, canonical set of controls that your teams actually operate against.

Take access reviews as an example. SOC 2 requires you to demonstrate that access to systems is reviewed and appropriate. PCI DSS Requirement 7 requires you to restrict access to cardholder data on a need-to-know basis and periodically validate that access. If you run those as two separate review processes, you've created twice the work for control owners and twice the friction for the business. If you run one well-designed access review process and map it to both frameworks, you've reduced the burden while actually improving the quality of the control — because now it gets the attention and rigor of a unified process instead of being one of dozens of checklist items.

There's a layer of complexity here that's easy to underestimate: scope. Different frameworks often cover different parts of your environment. Your PCI DSS assessment might scope a specific set of products and infrastructure that handle cardholder data, while your SOC 2 Type II covers a broader set of services and systems. The controls might overlap conceptually, but the populations they apply to are different.

The simplest approach is to treat everything as in-scope across all frameworks. That eliminates the complexity of maintaining separate scope boundaries, and for many organizations it's the right starting point. But there's real value in being more precise. If you can enrich your control data with information from your CMDB — mapping assets to products, products to frameworks, and frameworks to specific control requirements — you gain the ability to scope evidence collection accurately and demonstrate to auditors exactly which systems are covered and why. That enrichment turns your unified control framework from a flat mapping into something with real dimensional depth, and it pays off every time scope questions come up during an assessment.

Once your controls are unified, the next investment is automation. Every piece of evidence you collect manually is a piece of evidence that's only as current as the last time someone remembered to collect it. Automated evidence collection — pulling configuration data from your cloud provider, extracting access logs from your identity platform, capturing change records from your CI/CD pipeline — gives you evidence that's current, consistent, and doesn't depend on someone's calendar reminder.

This isn't about buying a GRC platform and calling it done. In fact, you don't need any specialized software to get started. The framework for collecting evidence can be built with Python scripts and bash. It can be scheduled using your existing CI/CD pipelines. The data can land in your enterprise data warehouse if you have one, giving you the ability to query, trend, and report on control effectiveness using tools your organization already owns.

At Alteryx, we drink our own champagne — we use Alteryx Designer workflows to automate our evidence collection and data enrichment. But the principle applies regardless of your stack. You could use Tines to orchestrate collection workflows. You could use purpose-built platforms like Drata that offer prebuilt integrations and support custom ones. You could wire it together with cron jobs and API calls if that's what you have.

The point is this: you don't need budget to get a GRC engineering program off the ground. You need time invested and an engineering mindset. The barrier isn't tooling — it's the decision to stop treating compliance as a series of manual tasks and start treating it as a system you design, build, and maintain.

The real work is in the design itself. Which systems are authoritative for which controls? What does "good" look like for each piece of evidence? How do you handle exceptions? These are engineering questions, and they deserve engineering rigor.

## The Hidden Benefit: Finding Problems Before Auditors Do

Here's where GRC engineering pays dividends that most people don't talk about.

When you collect evidence continuously rather than scrambling before an audit, you don't just make audit prep easier. You create a detection mechanism for control failures. If your automated evidence collection shows that an access review didn't happen last quarter, you know about it in near-real-time — not six months later when an auditor flags it. If a configuration drifts out of compliance with your baseline, continuous collection surfaces that drift while there's still time to remediate it and understand why it happened.

This fundamentally changes what GRC does for your organization. It stops being a backward-looking exercise in proving what you did and becomes a forward-looking function that identifies gaps in your security posture before they become findings — or worse, incidents.

Think about it from a risk perspective. A control that fails silently for nine months and gets discovered during an annual audit has been a gap in your security posture for nine months. A control that fails and gets flagged within days through automated monitoring is a momentary gap that gets addressed. The security outcome difference between those two scenarios is enormous, and it has nothing to do with compliance. It has everything to do with how you've engineered your evidence collection.

## Proving Effectiveness Over Time

There's another dimension to this that matters increasingly to auditors, customers, and regulators: demonstrating that controls are effective over a sustained period, not just on the day someone checked.

PCI DSS is explicit about this. The standard doesn't just want to know that your firewall rules are correct today — it wants evidence that they've been maintained appropriately throughout the assessment period. SOC 2 Type II examinations cover a period of time specifically to evaluate whether controls operated effectively across that window, not just at a point in time.

If your evidence collection is manual and periodic, you're essentially asking auditors to trust that the control was operating between collection points. If your evidence collection is automated and continuous, you're showing them. That's a fundamentally different conversation with your auditors, and it's a fundamentally stronger position when a customer asks how you can demonstrate that your security program actually works.

The organizations that invest in this capability now are building a competitive advantage. As customer security reviews become more sophisticated and frameworks increasingly emphasize continuous monitoring over point-in-time assessments, the gap between companies that have engineered their GRC programs and those that are still stitching together spreadsheets will only widen.

## What This Looks Like in Practice

We recently made the decision to invest in GRC engineering as a formal discipline. The driver was straightforward: we looked at our framework obligations, projected how they'd grow over the next two to three years, and realized that our current approach — capable people doing good work, mostly manually — wasn't going to scale without either significant headcount growth or significant quality degradation.

So we're building a unified control framework that maps our obligations across SOC 2, PCI DSS, and our internal security requirements into a single control set. We're investing in automated evidence collection that ties directly into the systems we already operate. And we're designing the program so that adding a new framework is an exercise in mapping, not an exercise in building from scratch.

It's early, and there's real work ahead. But the direction is clear: treat GRC like the engineering problem it is, and the program becomes something that scales with the business instead of something that scales against it.

## "But You Didn't Even Mention AI?!"

You're right, I saved it for the end on purpose. Because here's the thing — AI doesn't replace any of what I've described above. It accelerates it.

The hardest, most time-consuming part of building a GRC engineering program isn't the automation. It's the upfront work: reading through framework requirements, identifying where controls overlap across standards, mapping those overlaps into a unified structure, and documenting the rationale for why control X satisfies requirements from both SOC 2 and PCI DSS. That work is tedious, detail-intensive, and has historically required someone with deep knowledge of multiple frameworks to sit in a room with spreadsheets for weeks.

LLMs are already good at this. Today, you can feed a model your SOC 2 control matrix alongside PCI DSS requirements and get a credible first pass at a cross-framework mapping with rationale in hours instead of weeks. It's not perfect — you still need a human who understands your environment to validate the output, refine the mappings, and make judgment calls about where the overlap is real versus superficial. But the difference between starting from a blank spreadsheet and starting from an 80% complete draft is enormous. It compresses the timeline to stand up a unified control framework from months to weeks.

Evidence analysis is another area where AI is practical right now. Once you've built the automated collection pipelines, you end up with a large volume of evidence data. Reviewing that data for anomalies, summarizing it for audit packages, and identifying patterns that might indicate control degradation — that's analytical work that AI handles well. Instead of an analyst manually reviewing access logs to confirm that terminated employees were deprovisioned within your SLA, an AI agent can parse the evidence, flag exceptions, and draft the summary. The analyst's job shifts from data processing to exception review and judgment.

The near-term evolution that I think will have the biggest impact is AI agents as continuous evidence collectors. We're already automating collection with scripts and scheduled pipelines, but those are static — they do exactly what you programmed them to do and nothing more. An agent that can interpret a control requirement, determine what evidence is needed, query the appropriate systems, evaluate whether the collected evidence actually satisfies the requirement, and flag gaps — that's a fundamentally different capability. It's not science fiction. The building blocks exist today in tool-using AI agents, and the trajectory over the next twelve months makes this increasingly practical.

What stays human is the architecture. Deciding what your control framework looks like, determining acceptable risk thresholds, designing the scoping model, and interpreting whether a control is truly effective in your specific operating context — those are judgment calls that require understanding of your business, your customers, and your threat landscape. AI is an accelerant for the execution. The engineering mindset and the program design still come from you.

## The Business Case

If you're trying to make this argument internally, here's the framing that resonates: every hour your engineering team spends responding to redundant audit requests is an hour they're not building product. Every control that fails silently until an audit catches it is a period of elevated risk you didn't know about. Every new framework that requires a six-month implementation project because nothing from your existing program is reusable is a cost that didn't have to be that high.

GRC engineering isn't about making compliance easier for the compliance team. It's about making compliance sustainable for the business. When frameworks are unified and evidence is automated, the incremental cost of the next framework drops dramatically. When evidence collection is continuous, your security posture improves as a byproduct of your compliance work, not in spite of it. When your program is engineered rather than assembled, you can actually demonstrate to customers and auditors that your controls work — not just that they exist.

That's the shift. Compliance isn't something that happens to the business. It's something the business engineers.
