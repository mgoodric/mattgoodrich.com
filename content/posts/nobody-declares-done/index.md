+++
date = '2026-09-23T00:01:00-07:00'
draft = true
title = 'Nobody Declares Done'
aliases = []
description = "In the last post I argued that a design decision survives only if it turns into something that fails on its own. I've been running a work system built entirely on that rule: every claim names its own falsifier, a probe decides whether it holds, and no human and no agent can write done. Here is what the rule costs, and the places it broke."
categories = ['Engineering', 'AI']
tags = ['AI', 'Agents', 'Verification', 'Technical Debt', 'Architecture', 'Testing']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

In the [previous post](https://mattgoodrich.com/posts/where-review-comments-go-to-die/) I argued that a decision made in a design review survives the build only if you can get it out of prose and into something that fails on its own. That is easy to write down and hard to do, and the honest version of the advice is that most decisions don't convert.

I've spent the last month running a system built on the assumption that all of them can.

It's a work system for AI agents, and the property it's organized around is that nobody declares work finished. Its predecessor asked a human to decide, and that one property produced every symptom it had: a park queue where 89% of the items needed no human at all, agent self-reports that were wrong in both directions on the same day, and no level anywhere at which the question "is this feature done?" had an answer.

The replacement works differently. Work is specified as claims, each claim names the thing that would prove it false, and a terminal state is written only by the computation that reads probe results. Agents satisfy claims. They cannot tick a box.

What I want to write about is what that rule costs, because the rule itself is one sentence and the interesting part is all the things that turned out to be load-bearing underneath it.

## A Claim Is a Sentence Plus the Thing That Would Break It

Here's a real one, verbatim from the system's own spec:

```
ISC-1: No agent-writable path can set an item to a terminal state.
       Falsifier: a fire that attempts the transition is rejected and
       the item remains in its prior state.
       Probe: probes/isc1_9_10_11_guards.sh
```

Three parts. The claim, the falsifier in English, and the script that decides it. A claim without all three isn't finished being written.

The first thing that happened when I started working this way had nothing to do with automation. Writing the falsifier is what makes you notice you don't know what you meant. "The system should handle failures gracefully" has no falsifier, which is the actual finding about that sentence. You cannot write the test until you make the claim narrow enough to be wrong, and most of the arguing happens right there, before any code exists.

That's the same work a good design review comment does. The difference is that a review comment can survive in a vague state, and a claim can't be filed in one.

## Pass, Fail, and the Third Answer

A probe returns one of three results: pass, fail, or unrunnable. Unrunnable is never coerced into fail.

That sounds like pedantry until you see what collapsing it does. In one week the old system recorded 25 precondition failures as false claims, because a checker that couldn't run looked exactly like a checker that ran and found the thing broken. You end up with a system that reports a fault when it has actually reported that it doesn't know.

The same shape came up again with pull request status, and got the same answer: green, red, or unknown, and unknown never blocks by reading as red. If it did, an unreachable forge would look like a failing build forever, and it would look that way silently, because a red build is a normal thing to see.

The general form is worth stealing even if you never automate anything. A verification system needs a way to say "I don't know," and the failure mode of not having one is that absence of evidence quietly becomes evidence of failure.

## The Rule That Catches a Hollow Check

This is the one I'd keep if I could keep only one.

A claim closes only after its probe has been recorded failing at some point and passing at close. A probe that has only ever passed cannot close anything.

The reasoning is that a check written after the code already works passes on its first run, and that run tells you nothing about whether the check can detect the absence of what it's checking. Every test suite has some number of assertions that would pass against an empty implementation. Nobody knows which ones, because they've never been seen red.

Making the red mandatory turns that from a thing you hope about into a thing the system observed. It costs almost nothing. Break the thing, watch the probe fail, fix the thing, watch it pass, and now the probe has a demonstrated ability to discriminate.

It also found four real defects in this codebase while it was being written: a false `unrunnable` on shell builtins, model-derived data sitting in the trusted half of a handoff, idle and walltime kills collapsed into one failure class, and a closed claim that existed only in the database and not in git. All four would have been invisible to a suite that checked happy paths.

## The Exception, and the 62 Attempts It Cost

Fail-then-pass has an exception, and finding it was expensive.

Some claims describe something that must *become* true: the feature doesn't exist, work makes it exist. Others describe something that must *stay* true. `ISC-1` is one of those. No agent-writable path can set a terminal state, and that has been true since the first commit. Its natural state is passing.

Demanding that it fail first demands introducing the exact defect it exists to prevent. The system spent 62 attempts on a single item discovering this, each one dutifully refusing to close a claim that could not fail on request.

So standing invariants are a separate kind, marked as guards, and they close on a single pass. The price of the exemption is a note in the claim itself stating how its falsifier was proven red, because with fail-then-pass gone, a probe that cannot fail would close on a lie. A claim that can't say how it was seen to fail isn't a guard. It's a wish.

Two categories, one rule each. I don't think I would have found the distinction by reasoning about it. It arrived as a bill.

## Who Gets to Write the Check

There's one more piece, and it's the one that generalizes furthest past software.

Writing the probe that decides a claim is more authority than the system grants anywhere else. An agent can't tick a checkbox, on purpose. But a probe that always passes closes everything, so an agent that writes its own probe has quietly been handed the thing the checkbox rule was protecting.

The answer was to make authoring a falsifier its own kind of work, with its own completion rule: that work closes when the probe *fails*. The system watches the red itself rather than accepting the author's report that the check works.

And even that shipped with a hole. One run wrote a probe script, executed it, watched it fail, and committed only the spec row naming the script. The system observed a genuine red and closed the claim. The script itself existed only in a temporary worktree, which was then deleted. The check was in the system of record and nowhere else.

The fix was to change what durable meant. A commit in a worktree that's about to be deleted isn't durable, so the test became the push rather than the commit. Which is a small thing, and also exactly the failure the whole design is about: a record that describes something that isn't there.

## The Reviewer Doesn't Get the Story

One more piece transfers directly to how humans review, and it took three separate corrections to get right.

Review is its own unit of work, not a step inside the work being reviewed. It started as a step, and a step gets skipped whenever the run around it errors out. Four pull requests were orphaned that way before it moved.

The review carries its own claim, too, rather than the claim it's reviewing. Sharing them meant the review closed the moment the implementation's probe passed, which it already had, so the review closed on the fact that created it and carried no information at all.

And the reviewer is handed the trusted half of the record and never the author's narrative. This is the part I keep thinking about. An author's reasoning is persuasive by construction, because it's the reasoning that convinced the author. Give a reviewer the story and you get agreement. Give them the diff, the file list, and the claim, and you get a review.

The question the reviewer answers is deliberately narrow: does the claim hold, and does this diff contain anything the claim did not require. That second half is a scope check, and it's the machine version of the most useful thing a human says in a design review. It's also checkable in a way that "looks good to me" never is, because the verdict has to account for every file in the list, one at a time. Whether each judgment is right is unknowable. Whether the reviewer looked at all of it is not.

## What the Machinery Can't Do

The spec carries a section called anti-claims, which are the things the system explicitly does not promise. Two of them matter here.

The first: it doesn't guarantee an item is *correct*, only that its claims hold. A wrong claim that passes is a spec defect. All this machinery moves the failure rather than removing it. Before, you could build the wrong thing and also not know whether you'd built it. Now you can only build the wrong thing. That's a real improvement, and it's a much smaller one than the apparatus implies.

The second: it doesn't promise faster throughput. It promises less of my attention per unit of work. Writing falsifiers is slow. The spec for this system has more than forty claims and a changelog longer than the code's README, written in conjecture-and-refutation form, one entry per thing I believed that turned out to be false. If you want velocity, this is not the trade. If you want to stop being the bottleneck on the question of whether something is finished, it is.

There's a version of this that goes wrong, and it's the same one that goes wrong with a compliance program: enough machinery around verification that the machinery becomes the work. I don't have a clean rule for where that line is. The best I've got is that every claim in this spec was written because something specific broke, and the changelog is the proof, because each entry names the belief and the thing that refuted it.

## Back to the Room

One line from that changelog is the whole reason I'm writing this as a follow-up. Asked where a discovered defect should go, the answer that stuck was that a defect with no claim is a missing falsifier rather than a missing document. You don't write it up. You write down what would have caught it, and then it's a thing the system re-checks forever instead of a thing you remembered once.

That's the closest I've come to a real answer for design review. Not a register of decided debt, which decays. A claim with a falsifier attached, which re-runs.

The machinery only ever answers the second question. Whether what got built matches what was described is something a probe settles in seconds and re-settles every day afterward. Whether it should have been described that way is still four people in a room, and it still ends in one of the four ways.
