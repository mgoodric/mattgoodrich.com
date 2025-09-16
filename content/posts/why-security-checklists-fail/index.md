+++
date = '2025-09-16T00:00:00-07:00'
draft = false
title = 'Why Security Checklists Fail (And What Aviation Gets Right)'
aliases = []
summary = "As a pilot who's also guilty of creating monster security checklists, I finally realized the perfect example was right under my nose at 10,000 feet. Turns out aviation has been solving the 'comprehensive vs. actually useful' checklist problem for decades—and we can steal their homework."
genres = ['Security', 'Development']
tags = ['security', 'checklists', 'aviation', 'development', 'process improvement', 'security practices', 'SSDLC', 'developer experience', 'best practices', 'CI/CD']
[params]
  author = 'Matt Goodrich'
+++

Building a good checklist is hard. Honestly I hadn’t given checklists much of a second thought until I read *The Checklist Manifesto: How to Get Things Right* by Atul Gawande.

I use checklists everywhere in my daily life. I keep notes about every day in Obsidian, creating checklists of things that I need to do across work, personal life, and some organizations I am involved with. At work, teams ask for checklists to be produced by us - ranging from things that need to be done for the compliance framework of the month, something related to our SSDLC, or something else. Before going on a family vacation, my wife and I often use a shared Apple Notes checklist to ensure we remember to bring everything. I am also a pilot, and checklists are a core part of any good pilot’s routine. They’re everywhere.

As a pilot, I realize aviation checklists were the perfect example right under my nose this whole time. They’re context-centered, short, and concise by necessity. Emergency checklists contain just the critical items you need when seconds matter. Pre-flight checklists are more comprehensive because you have time and aren’t task-saturated. A climb-out checklist when you’re single pilot—maybe in clouds, without autopilot—must be short and sweet. You need to maintain your instrument scan, stay on course, monitor altitude, check climb gradient, and more. There’s no room for verbose instructions.

I now realize I am usually too verbose in my checklists. For a checklist to be effective it needs to be the correct length for the context it’s being used in. If you are running a checklist as part of a twice annual software release, and that checklist only needs to be run once to make sure everything has been accomplished over the last 6 months, it can be longer, more verbose, and take some time to get through.

What about a list that developers run through on each PR/MR (depending on your preference of GitHub vs GitLab)? Should probably be short enough that it can be done in a few minutes, and contains mostly relevant items that would be needed on a majority of the requests. That can be hard… the MR (you caught me, I am a GitLab fanboy) could be fixing a typo, or a roll up of a bunch of functionality that needs to move into a different branch. How do you design a checklist that can be useful in both of those cases?

Here’s what I’ve learned: having a single static checklist for diverse circumstances that actually provides value is either extremely difficult or impossible. This is where I got caught before. I of course added stuff I thought was applicable to most things, and broke down my checklist to big types of changes; Infrastructure as Code (IaC), configuration, software, etc. The checklist still proved to be long, and often sat outside of our CI/CD systems, or IDEs where the code was being written, reviewed, and merged.

## The Real Lesson

I learned that the best checklists aren’t comprehensive—they’re contextual. Just like aviation, different situations demand different approaches. Now when I create checklists, I ask myself: What’s the cognitive load of the person using this? How much time do they have? What are the real failure points we’re trying to catch? Where will they be when this checklist is run?

I’ve started creating multiple, shorter checklists rather than one monster list. A quick checklist for simple changes. A more detailed checklist for major updates. An emergency “hotfix” checklist that covers just the essentials when the site is down and every second counts. This idea can be further supplemented by using automation or AI to show the relevant checklist items for the situation, and remove items that can be automatically verified (pipeline steps for SAST, secrets detection, etc).

The goal isn’t to capture everything—it’s to capture the right things for the right moment. Sometimes that means accepting that a typo fix doesn’t need the same rigor as a database migration. And that’s okay. Better checklists aren’t perfect checklists; they’re checklists that actually get used when they’re needed most.