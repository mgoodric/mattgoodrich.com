+++
date = '2026-02-24T11:29:52-08:00'
draft = false
title = 'Designing for Complexity: Why Security (and AI) Need a New Playbook'
description = "Most security programs are designed for complicated problems. But the threat landscape — especially with AI — is complex. It's time for a different playbook."
categories = ['Security', 'Leadership']
tags = ['security', 'cybersecurity', 'AI', 'complexity', 'systems-thinking', 'engineering', 'leadership', 'strategy', 'resilience', 'threat-modeling']
image = ''
[params]
  author = 'Matt Goodrich'
+++

I recently picked up *Team of Teams* by General Stanley McChrystal, and one concept from the book has been rattling around in my head ever since — the distinction between complicated and complex. It's one of those frameworks that, once you see it, changes how you evaluate almost everything. It's reshaped how I think about engineering, security, and especially the current moment we're in with AI.

## Complicated vs. Complex: A Primer

These two words get used interchangeably in casual conversation, but they describe fundamentally different types of problems.

A complicated system has many moving parts, but it's ultimately knowable. Given enough expertise and time, you can map every component, understand every interaction, and predict outcomes. An airplane engine is the classic example — thousands of parts, incredibly intricate, but a skilled mechanic can fully diagnose it. The relationship between cause and effect is linear, even when it's hard to trace. Expertise is the key to solving complicated problems. If something breaks, you can find the root cause. If you need to build one, you can follow the blueprint.

A complex system is fundamentally different. It's made up of many interacting components whose relationships produce unexpected behavior — outcomes that can't be predicted by understanding the individual parts alone. Cause and effect aren't linear. They're entangled, delayed, and often only visible in retrospect. Weather is complex. Economies are complex. A city's traffic patterns are complex — you can understand every road and every traffic light and still not predict the jam that forms on a random Tuesday afternoon for no apparent reason.

The critical distinction isn't difficulty. Complicated problems can be incredibly hard. The distinction is predictability. Complicated problems are solvable with enough expertise. Complex problems aren't solvable in the same way — they're managed, navigated, and adapted to. You don't engineer your way out of complexity. You build systems that can sense and respond.

This distinction is at the heart of systems thinking — the discipline of understanding how components interact to produce behavior that can't be explained by looking at any single part. Systems thinking was developed precisely because traditional analytical approaches, which work by breaking things down into pieces, fall short when the interactions between those pieces matter more than the pieces themselves. If you've encountered concepts like feedback loops, emergent behavior, or unintended consequences, you've been in systems thinking territory. The complicated vs. complex distinction gives us a lens for knowing when those dynamics are in play — and when our usual problem-solving tools are going to let us down.

This matters because most organizations and most disciplines default to treating problems as complicated. We decompose, we plan, we build expertise, we implement solutions. That approach works brilliantly right up until the moment it doesn't — and the failure mode is almost always the same. Something happens that nobody predicted, and the response is to pile more complicated solutions on top rather than recognizing that the nature of the problem has changed.

## Engineering Is Built for Complicated

Most of software engineering is fundamentally about taming complicated problems. The entire discipline is built around decomposition — take a large, difficult problem, break it into smaller pieces that are individually understandable, build each piece to behave predictably, and compose them back together.

This is what we teach engineers from day one. Microservices, modular design, separation of concerns, well-defined interfaces — these are all strategies for managing complicated systems by making them knowable. A single service with clear inputs and outputs is testable, debuggable, and predictable. You can reason about it. You can hand it to another engineer and they can understand it. The entire practice of engineering rigor — code reviews, unit tests, CI/CD pipelines — is built on the assumption that if you understand and control the pieces, you can control the whole.

And that assumption holds. For a remarkably long time, it holds.

## Complexity Emerges at Scale

But something changes at scale. You go from one service to ten to a hundred, and at some point the system starts exhibiting behaviors that none of the individual components were designed to produce. A latency spike in one service cascades into queue backups in another, which triggers retry storms in a third, and suddenly you have an outage that no single team owns and no architecture diagram predicted.

This is the shift from complicated to complex. The individual services are still complicated — knowable, predictable, well-engineered. But the system of systems is complex. The interactions between components create unpredictable behavior. Cause and effect become difficult to trace in real time. You can't fully predict outcomes from inputs anymore.

This is why engineering at scale requires a fundamentally different set of tools and thinking. You shift from unit tests to observability. From preventing failures to building resilience. From designing the perfect architecture to accepting that things will break and optimizing for detection and recovery. The entire SRE discipline exists because someone recognized that large-scale systems are complex, not just complicated, and need to be managed accordingly. Chaos engineering — intentionally breaking your systems to see what happens — is the ultimate admission that you can't predict how your system will behave, so you'd better learn by experimenting.

The engineering world went through this reckoning. It wasn't painless, but the result was a set of disciplines and practices specifically designed for complexity rather than just complication. Observability, resilience engineering, chaos engineering, SRE — these all exist because the field recognized that the nature of the problem had changed, and the old tools weren't enough.

## Security Is Still Designing for Complicated

Now bring this lens to security.

Most security programs are engineered the way we engineer complicated systems. We build control frameworks with defined categories and requirements. We implement tools that each serve a specific purpose — endpoint detection, vulnerability scanning, identity management, SIEM. We create architecture diagrams that show how data flows and where protections sit (that are probably already incorrect or out of date). We map our controls against compliance frameworks and check the boxes.

And just like in engineering, this approach works beautifully for the individual pieces. Encryption is a complicated problem with knowable, well-defined solutions. Access control is complicated. Network segmentation is complicated. Implement them correctly and they behave predictably, every time.

But the actual security posture of an organization? That's complex. It's the product of hundreds of tools, thousands of configurations, tens of thousands of human decisions every day, constantly evolving threat actors, and business processes that nobody in the security team fully understands. The breach doesn't come through the control you designed for — it comes through the gap between three controls that each work perfectly in isolation but create a blind spot where they intersect.

This is why you can be fully compliant with a framework and still get breached. Frameworks are designed for complicated problems. They give you a blueprint, you implement it, and every piece works as specified. But the threat landscape is complex. Attackers aren't following your architecture diagram. They're finding the gaps — the places where your complicated solutions don't account for real-world interactions.

You can see this playing out in how organizations evaluate their vendors' security. A customer sends over a spreadsheet with hundreds of control questions. Do you encrypt data at rest? Do you have a vulnerability management program? Do you perform annual penetration tests? Each question is perfectly reasonable in isolation. But the customer has no context into your actual environment — how those controls interact, what your threat model looks like, where the real risks live in practice. They're decomposing "is this vendor secure?" into individually knowable checks, which is complicated thinking applied to a complex problem. The box gets checked. The audit passes. And neither side is meaningfully more informed about actual security posture, because the risk lives in the spaces between those questions, not in the answers themselves.

The engineering world already learned this lesson. Engineers discovered that you can't just build perfect components and expect a perfect system. Security, broadly speaking, is still operating as if you can. We're still defaulting to the complicated playbook — more tools, more frameworks, more controls, more questionnaires — when the nature of the problem is asking for something different.

## AI Changes the Nature of the Problem

If the case for rethinking security through a complexity lens was already strong, AI makes it unavoidable.

Traditional software is complicated. For a given input, you get a deterministic output. You can test it. You can audit it. You can predict its behavior under known conditions. You can write a spec, build to it, and verify that the implementation matches. The entire model of software quality, from testing to deployment to monitoring, is built on this deterministic foundation.

AI breaks that contract. The same prompt, submitted twice to the same model, can produce different results. Model behavior isn't static — it shifts as training data, fine-tuning, and alignment techniques evolve. The interactions between AI systems and the infrastructure they're embedded in produce behaviors that no one fully predicted during development. This isn't a bug, it's a feature. AI doesn't just add more complicated parts to your system. It introduces genuine complexity into environments that were previously just complicated.

But here's what I think makes AI truly unprecedented from a complexity standpoint — and I haven't seen many people talking about this.

Think about how we've always managed technology risk. When you update a library, you test for regressions. When you swap out a database, you validate that your queries still work. When you change a component, you can reason about the blast radius because the interfaces are defined and the behavior is specified. The complicated parts might shift, but you can trace the impact.

With AI, organizations are building entire product ecosystems, workflows, and security controls on top of foundational models — and when that underlying model gets updated or swapped, everything built on top of it can behave differently. More capable in some areas, less capable in others, differently capable in ways that only surface through real usage over time. The prompts that worked reliably last month might produce subtly different outputs today. The guardrails you tested might not hold the same way. The workflows your team depends on might shift in ways that are invisible until something goes wrong.

There is almost no precedent in technology for swapping out an underlying black box and having everything built on top of it change behavior with no real visibility into the impact beforehand. We don't have a playbook for this because we've never needed one. Every previous technology abstraction gave us defined interfaces and predictable behavior. Foundational models give us neither, and they're updating on cycles measured in months.

That's not a complicated problem. You can't decompose your way through it. You can't draw an architecture diagram that accounts for it. It's complexity in one of its purest forms — and it's happening continuously, across every organization that has built on top of these models.

## Designing for Complexity

So what does it actually look like to design security programs — and engineering practices — for complexity rather than complication?

The engineering world offers a roadmap, because it's already been through this transition.

First, observability over checklists. In a complicated world, you can define what "good" looks like in advance and check whether you've achieved it. In a complex world, you need the ability to see what's actually happening in real time and detect patterns you didn't predict. This means investing in sensing capabilities — not just logging and alerting on known-bad signatures, but building the capacity to notice the unexpected.

Second, resilience over prevention. Complicated thinking says: prevent the failure. Complex thinking says: assume failures will happen in ways you can't predict, and build the capacity to detect, respond, and recover quickly. This doesn't mean abandoning preventive controls. It means recognizing that they're necessary but not sufficient, and investing proportionally in your ability to adapt when they don't hold.

Third, distributed decision-making over centralized control. Complicated problems can be solved by a central team of experts. Complex problems can't — they move too fast and emerge in too many places. Security awareness and decision-making capability need to be distributed throughout the organization, not concentrated in a security team that reviews everything. The people closest to the complexity need the context and authority to act on it.

Fourth, adaptive strategy over fixed architecture. A security strategy designed for a complicated world can be built once and maintained. A security strategy designed for a complex world needs to be continuously revisited as the landscape shifts. This is especially true in the current AI moment, where the capabilities and risks of the underlying technology are changing faster than annual planning cycles can account for.

And here's where the narrative comes full circle — because AI isn't just the source of new complexity. It might also be the first tool we've had that can actually operate at the speed and scale that complexity demands.

Take threat modeling. Today, most organizations do this manually. A security architect sits down with engineering teams, maps out data flows and trust boundaries, and works through attack scenarios. It's valuable work, but it's fundamentally limited by human throughput. A skilled architect might model a handful of scenarios for a single system in a session. Meanwhile, the actual environment is shifting — new deployments, configuration changes, evolving integrations — faster than any human can keep up with. And if we're being honest, the system that got deployed never fully matched what was planned, documented, or discussed in the first place. It never does. The architecture diagram is the complicated view — clean, logical, knowable. Production is the complex reality — shaped by deadline compromises, undocumented workarounds, and decisions made at 2 AM during an incident that nobody went back to revisit.

Now imagine an agentic approach. You feed the agent the static information that comes from building the complicated pieces — architecture diagrams, control mappings, data flow documentation. Then you layer in the observability data generated when those systems start interacting in the real world — the actual traffic patterns, the unexpected dependencies, the behavioral anomalies. With that combination of complicated knowledge and complex reality, an agent could model thousands of threat scenarios in the time it would take a human to work through a few. It could continuously re-evaluate as the environment changes. It could surface risks that a human would never think to look for because they only become visible when you model interactions at scale.

This is what designing for complexity looks like in practice — using the tools that introduced the complexity to help you navigate it. Not replacing human judgment, but augmenting it to operate at the speed and scale the problem actually demands.

None of this means throwing away what we've built for complicated problems. Encryption still works. Access controls still matter. Compliance frameworks still provide useful structure. But these are the foundation, not the complete answer. The organizations that will navigate this moment well are the ones that recognize the nature of the problem has changed — and start designing accordingly.
