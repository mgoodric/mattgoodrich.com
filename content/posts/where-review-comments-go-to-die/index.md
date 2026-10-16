+++
date = '2026-09-22T00:01:00-07:00'
draft = true
title = 'Where Review Comments Go to Die'
aliases = []
description = "At Black Hat this year I ended up in a rare group of architects, all circling the same problem: what happens to the comment you make in a design review. Every comment ends in one of four states, and only one of them is a real outcome. The other three are how decided debt goes invisible, whether your team has a merge button or not."
categories = ['Security', 'Engineering']
tags = ['Security', 'Architecture', 'Technical Debt', 'Risk Management', 'Governance', 'AppSec']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

At Black Hat this year I ended up standing in a hallway with four other architects, which almost never happens. Black Hat is a vendor floor, a briefing track, and thirty thousand people, and the ones who go tend to be operators, researchers, and buyers. Architects travel in smaller numbers. Finding four of them in one place, all with the same job and none of us from the same company, felt like an accident worth staying for.

Nobody wanted to talk about AI. What we talked about for most of an hour was what happens to a comment after you make it in a design review.

I've written before about [decided debt](https://mattgoodrich.com/posts/hardest-part-of-security/): the conscious choices made in design discussions and architecture reviews to do the less secure thing now and come back later. Discovered debt lives in a scanner and a ticket queue. Decided debt lives in the heads of the four people who were in the room, and when two of them leave, it's gone. I called it organizational dark matter and left it there.

The hallway conversation was about the mechanism. Decided debt doesn't get created by bad decisions. It gets created by comments that never ended.

## Four Ways a Comment Ends

Say you're in a design review and you raise something. The service is multi-tenant and isolation is being done in application code with no enforcement at the data layer. You say so. What happens next has exactly four shapes.

**Changed.** The design changes. Someone adds the scoping at the database, or the team picks a different pattern. This is the outcome everyone imagines when they think about design review, and it's the rarest of the four.

**Accepted.** The team decides to ship it the way it is, and that decision gets written down with a name attached and a condition that would bring it back. This is decided debt with the lights on. It's still debt. It's just debt somebody can find.

**Declined.** You're wrong, or the risk isn't real in this context, or a compensating control you didn't know about already handles it, and someone says so. This is a legitimate ending and security people are bad at treating it like one. A comment that gets argued down and closed is a better result than one that gets politely absorbed.

**Expired.** Nobody said no. Nobody said yes. The meeting ran long, the comment got a nod, and the room emptied out.

Expired is the default, because it's the only one of the four that requires no work from anybody.

## The Expired Comment Is the Production Mechanism

Here's the shape of it in practice. A design review for a new service. Someone raises tenant isolation. The lead says something reasonable, like "we're doing row-level scoping in the service layer for launch, we'll look at database-level isolation next quarter." Everybody agrees that's fine, because for launch it probably is. No ADR. No ticket. It was a hallway-grade agreement inside a meeting.

Eighteen months later a customer security questionnaire asks whether tenant data is isolated at the database. It isn't. Two of the four people from that review have left. The remaining two remember that it came up and don't remember what was decided. Nobody can say whether the current design is a deliberate tradeoff or an oversight, which means nobody can say what it would take to change it or whether anything else was built on top of the assumption.

The risk didn't get worse in those eighteen months. The information about it did.

That's what a comment costs when it expires: not the vulnerability, which you might have accepted anyway, but everything the organization knew about why.

## The Only Thing You Can Actually Require

This is where the hallway split. Two of us worked somewhere with a gate. An architecture review board with a real veto, security sign-off that blocks a release, a documented SDLC where the design phase has an exit criterion. The other three, me included, work in places where security advises. We get invited, we get listened to more often than not, and we have no button that stops anything.

The consultative model gets described as the weaker one, and on the question of whether the design changes, it is. But that framing hides something useful, because "the design changes" was never the only outcome worth having.

Requiring a change is authority over someone else's engineering. Requiring a disposition is authority over your own process. Those are very different asks, and consultative security teams routinely fail to notice they're allowed to make the second one.

I don't get to decide whether the team fixes the isolation model. I do get to decide what "I reviewed this" means when I say it. And I can say: this review isn't closed until every comment I raised has an ending, and I don't care which ending it is. Change it, accept it in writing, or tell me I'm wrong. Three of those are fine. The fourth isn't available.

That's a much smaller ask than it sounds like, because you're not asking for a decision to go your way. You're asking for a decision to exist. In years of doing this I've never had someone refuse that framing, and I've had plenty of people refuse the change.

The obvious objection is that a team with no gate over it will simply accept everything, and you'll have traded a program that changes designs for a program that produces a tidy list of things nobody fixed. That happens. It's still better than the alternative, for two reasons. An accepted risk with a name on it behaves differently from an unrecorded one, because the person who signed it has to keep signing it, and people get tired of signing. And a list of forty accepted risks across six teams is something you can put in front of a CTO in a way that forty hallway conversations never were. What the organization does with that list is genuinely its call. It might add a gate for one narrow class of decision. It might read the whole list and say the exposure is acceptable, which is a real answer, and a much better one when it's made on purpose than when it's made by forgetting.


## Make the Record the Cheap Path

The disposition only happens if writing it is easier than not writing it. A few things that move it in that direction.

**Write the disposition yourself.** The reviewer should draft the record and ask the team to confirm it in one line, rather than asking the team to go document a decision. You care more than they do, you already have the context, and the whole cost of the record is the writing. Reverse who carries it. A Slack reply of "yep that's right" is a ratified decision, and you can attach it to something durable afterward.

**Put it where the work lives.** An ADR in the repo, a comment on the PR, a linked issue in the team's own tracker. A security-owned register of accepted risks that engineers never open is a fiction that will look complete and describe nothing. If your record and their record are different systems, yours is the one that goes stale.

**Three fields, not a template.** What we're doing instead, who owns it, and what would bring this back. That last one is more useful than a date. Dates get silently renewed. A condition like "when we onboard a customer with a data residency requirement" or "when this service starts holding payment data" is a trigger someone can actually notice.

**Expire the acceptance, not the reminder.** If an accepted risk carries a review date, the date should force a re-decision, not generate a notification. A risk that's been quietly re-accepted six times without anyone looking at it is worse than one that was never written down, because now it has documentation implying somebody checked.

## Strict Programs Have the Opposite Problem

Everything above is the consultative failure mode. If you work at a bank, a hospital system, or a defense contractor, none of it is your problem. Your gates are real. The design phase has an exit criterion, the ARB adjudicates every comment, and nothing expires because a gate can't close with an open item on it. The record of decisions is complete.

Then it stops describing the system.

The review happens at design. The build happens over the next nine months. Somewhere in month four the team hits a constraint nobody predicted, solves it a different way, and ships something the ARB never saw. The approval is real, the artifact is real, and the correspondence between them decays from the day it's signed.

So the two models fail at opposite ends. Consultative programs lose the decision. Strict programs lose the drift. If you've worked in both, you've probably noticed that the strict one feels more rigorous and produces a similar amount of surprise, which is a genuinely uncomfortable thing to sit with.

## Checking That Built Matches Documented

This was the third question in the hallway and the one nobody had a clean answer for. You reviewed a design. Something got built. How do you know they're the same thing?

Prose can't verify a system. So the goal is to get as many decisions as possible out of prose and into something that fails on its own.

The best case is that the decision has a machine-checkable form. "Tenant isolation is enforced in application code, not at the data layer" is a sentence. "No service role has unscoped read on the tenants table" is a policy check that runs in CI and breaks the build when it stops being true. Not every decision converts, but more of them do than most teams try. When it converts, the decision stops needing an audit, because the drift shows up as a failure.

For everything that doesn't convert, attach the decision to the artifact. The ADR ID goes in the PR description and the service registry entry. That gives you a search: when someone touches this service, what did we decide about it? A record you can only find if you already know it exists isn't a record.

Then sample. Once a quarter, take five accepted risks from the last year and check the current system against them. You're measuring the decay rate of your own record. If two of five are wrong, the record is decorative and the process needs the fix, not the sample. This is the same instinct as [standardizing the gates rather than the steps](https://mattgoodrich.com/posts/standardize-the-gates-not-the-steps/): you don't need to see every path, you need a small number of checks that tell you when the map and the ground have separated.

## The Reason Nobody Does This

There's an argument against everything I've just written, and it isn't laziness.

A written, dated, attributed record that your organization knew about a risk and shipped anyway is discoverable. In an incident, in litigation, in a regulatory exam, "we identified this exposure in March 2024 and accepted it" reads worse than silence. Plenty of counsel would rather the decision lived in nobody's notes. Some of the resistance to tracking decided debt is legal advice, and the people giving it are not being unreasonable.

I think the argument is wrong, but only barely, and for a specific reason. The alternative is the same risk with no record of it, and the risk is the part that hurts you. What the record changes is which story is available afterward.

There are two records you can end up with. One shows a risk raised, evaluated, accepted by a named person with a compensating control and a revisit condition. The other shows a risk raised in a meeting and never mentioned again. The first is a defensible decision. The second is the one that reads badly, and it's the one you get by default when comments expire. The exposure people are afraid of comes from the expired comments, not the accepted ones.

There's also a reason to write it down that has nothing to do with defending yourself, and it belongs to a different team. Every accepted risk I've described is a local decision, made by the people in one review, and each is usually reasonable where it was made. The aggregate is not local. Ten teams each accepting a modest amount of tenant-isolation debt is one large problem, and nobody sitting in any of those ten reviews was positioned to see it.

Risk management does that arithmetic, and it can only add up what someone wrote down. Get your ADRs and accepted-risk records somewhere a risk function can read them and decided debt joins the register, gets scored against everything else, and reaches the C-suite and the board through a reporting line that already exists. Leave them in review notes and the register describes discovered debt only, which means the board's picture of security risk is assembled entirely from what a scanner can see. That gap is worth naming out loud to whoever owns your register, because from their side it doesn't look like a gap. It looks like a complete report.

This is also why the record belongs in the repo rather than in a security tool. The risk team reads from where the decisions already are. Standing up a separate system for them to write into recreates the same problem one layer up, and the version the engineers don't maintain is the one that goes stale.


The real cost is smaller and more practical: ceremony. If every nit in a review needs a disposition, reviews get slower and people stop raising the small stuff, which is where a lot of the value is. So the bar has to be explicit. A disposition is for a comment that changes the risk of the system, and the reviewer says at the time which of their comments crossed that line. Four dispositions from a review is a good review. Twenty is a process nobody will survive.

## What I Measure Now

I've stopped counting how many of my design review comments turned into changes. That number depends on somebody else's roadmap, their headcount, and what quarter it is, and I don't control any of it.

The number I control is how many comments left the room with an ending. Changed, accepted in writing, or argued down. All three of those are wins, and the difference between a program with a gate and a program without one turns out to be much smaller than the difference between a comment that ended and one that didn't.
