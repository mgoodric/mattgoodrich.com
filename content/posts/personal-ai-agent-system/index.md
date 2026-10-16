+++
date = '2026-12-31T12:00:00-07:00'
draft = true
title = 'My Personal AI Agent System: LangGraph, Local Models, Discord, and a Web UI'
aliases = []
description = "I've been building a personal AI agent system on infrastructure I own. It now runs 22 use cases through a Discord bot and a web UI, prefers local models, and only escalates to the cloud when it has to. This is the architecture and a tour of the use cases that have actually paid back."
categories = ['AI', 'Automation', 'Productivity', 'Tools', 'Software']
tags = ['AI', 'LangGraph', 'Personal AI', 'Local LLMs', 'Ollama', 'Discord', 'Automation', 'Self-Hosted']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

I've been building a personal AI agent system for a while. It now runs 22 use cases, has a Discord bot as the primary interface, a web UI for the things Discord can't do well, and a model router that prefers local models and only escalates to the cloud when it has to.

The point isn't the count. The point is that personal AI is going to be a thing whether or not the industry settles on what it means, and the question is whether your version runs on infrastructure you own or infrastructure you rent. I've been quietly arguing for the first one — to myself, mostly, by building it.

## What "Personal AI" Means Here

Not Siri. Not ChatGPT. Not Copilot. A system that runs on hardware I own, performs jobs I actually care about, and talks to me through interfaces I already use.

The principle: the agent works for me, not for a vendor. Local-first inference. Data stays on my machines. The cloud is a fallback, not a default.

That's the design constraint. Everything else falls out of it.

## The Stack

- **Orchestration:** LangGraph — state-machine agents with durable checkpoints
- **Memory & RAG:** PostgreSQL + pgvector
- **Inference:** Ollama on a Mac Studio M3 Ultra (96GB unified memory) — GPT-OSS 120B (MoE, 5.1B active) plus Qwen3 30B-A3B (MoE, 3.3B active) plus nomic-embed-text
- **Cloud fallback:** Groq → Gemini Flash → Gemini Pro / Claude
- **Observability:** Langfuse for traces and evals; Loki + Grafana for logs and dashboards
- **Interfaces:** Discord bot (primary HITL), web UI dashboard, CLI
- **Hosting:** Mac Studio (inference) + Unraid (Postgres, agents, observability stack)

Most of these choices were "what's boring, well-supported, and lets me ship the agent?" The answer was usually the obvious one.

## The Model Router

The model router is the heart of the local-first architecture. It's also the part most likely to surprise you if you assume "AI workloads need cloud GPUs."

### The Routing Tiers

- **Tier 1 — Local fast.** Qwen3 30B-A3B for short, classification-style tasks. ~132 tokens/sec on the Mac Studio.
- **Tier 2 — Local smart.** GPT-OSS 120B for reasoning-heavy tasks. Slower but still on-device.
- **Tier 3 — Cloud fast.** Groq Llama for when local is unavailable or rate-limited.
- **Tier 4 — Cloud smart.** Gemini Flash → Gemini Pro / Claude for the hardest tasks or when judge calls require known-good behavior.

The MoE architecture is what makes Tier 1 + Tier 2 work simultaneously on one box. Both models stay loaded with reasonable VRAM. The router picks based on task complexity, not on what happens to be loaded.

### Health-Aware Fallback

Before each call, the router runs a health check: is Ollama reachable, is the Mac Studio awake (yes, that's a real concern), is the model loaded or do we need a cold-start, has the cloud provider been rate-limited recently. A `router --status` command shows which tier is healthy and what's degraded. When local is degraded, traffic flows to cloud automatically — but it's the exception, not the default.

### Cost-Aware Defaults

Local handles everything that can run locally — embeddings, classification, summarization, routine reasoning. Cloud is reserved for pairwise judges, high-stakes reasoning, or when local is degraded. The result: roughly $0–$5/month in cloud LLM spend for a system running 22 use cases on a 24/7 cadence. The Mac Studio paid for itself in inference cost alone within a few months.

### Why Two Local Models, Not One

The smaller model handles the high-frequency stuff — classification, simple extraction, short summarization. The larger model handles the rare hard tasks — long-context reasoning, multi-step planning. Routing by task complexity, not by what happens to be loaded.

If I were starting today with less RAM, I'd probably run only Qwen3 and accept the trade-off on the harder tasks. With 96GB, I can keep both warm and let the router pick.

## The Discord Bot

Discord is the primary HITL interface for everything in the system.

I picked it because I'm already in it. Slash commands are a natural fit for "ask the agent to do a thing." Buttons and selects make HITL approval flows easy. The DM channel handles private agent output; server channels handle shared family stuff. Push notifications on phone and desktop come for free.

The patterns the bot uses, in roughly the order I added them:

- **Slash commands** for explicit invocations: `/journal`, `/digest`, `/award-search`
- **Approval cards** for HITL: agent proposes, I approve/reject/edit, then it acts
- **Scheduled posts** for digests: morning briefing, daily journal prompt, weekly report
- **Alert routing** for monitoring: low-noise channel for normal status, high-priority channel for actionable

Building HITL on top of Discord buttons sounds janky. In practice it's the part of the system I'm happiest with. It's the path of least friction for the agent to ask me a question and the path of least friction for me to answer.

## The Web UI

Discord is great for ephemeral interaction. It's terrible for surfaces that need persistence — tables, dashboards, reviewing 191 correspondents and tweaking their priors.

So there's a web UI dashboard. It's the management plane. Discord is the conversation plane.

What's on it:

- Agent run history with filters and search
- Model router status — which tier is serving requests right now
- Use case status panels — cruise prices, award flights, HSA balance, weather, air quality
- Document pipeline review queue
- Auto-generated architecture diagrams
- Embedded Loki/Grafana panels for the agents I'm actively watching

The UI is intentionally boring. Server-rendered, no SPA, dense layout. If it ever earns the investment to migrate to a Next.js front end I'll do that. So far it doesn't.

## The Use Cases (a Selected Tour)

I'm not going to walk through all 22. Five of the more interesting ones, picked because they each illustrate something different about the architecture.

### Document Pipeline

The largest agent in the system. Classifies incoming documents, routes them through three confidence tiers, and files them via 27+ rules. Built on Paperless-ngx with a local-AI layer on top. Discord HITL for the ambiguous documents.

This one is its own [post](/posts/local-ai-on-paperless-document-pipeline/) — short version: the agent does what would otherwise be hours of manual filing every week, and it gets smarter as I review the edge cases.

### Daily Journal

A Discord prompt at the end of each day. I type a few lines about what happened. The agent expands, tags, and saves to Postgres. The Obsidian daily note gets a synthesized summary the next morning.

The interesting part is the RAG layer. The agent uses prior journal entries to ask better follow-up questions over time. "You mentioned the Bonanza annual last month — how's that progressing?" That kind of continuity isn't possible without persistent memory, and a stateless chatbot can't do it.

### Email Digest

Reads inbox, classifies messages, summarizes the threads worth my attention, and posts a single morning digest in Discord. Most email becomes one bullet. The 5% that needs my eyes gets surfaced explicitly.

This was the use case that paid back fastest. The amount of email triage time it saved in the first month justified everything the system has cost.

### Infrastructure Health

Watches the home lab — Unraid, the Mac Studio, Ollama, Postgres, the agents themselves. Alerts on Discord when something is degraded. Daily summary when everything is fine.

The thing this enabled that surprised me: I now know within minutes when something is degraded, instead of finding out hours later when an agent fails to do its job. Self-monitoring infrastructure is one of those things you don't appreciate until you have it.

### Cruise Price + Award Flight Tracking

Two separate agents that share a pattern. Tracks prices or availability for things I'm watching, alerts on changes that meet a threshold I configured.

Cruise prices via a daily snapshot, alerts when fares drop on routes I'm tracking. Award flights via the Seats.aero API, alerts only when route + cabin + date hits availability above the threshold. The threshold matters — without it, you get pinged constantly and stop noticing the alerts.

These are not glamorous use cases. They are exactly the kind of "small thing that would be tedious to do by hand" that makes a personal AI system actually pay back.

## Observability (Because Otherwise You're Flying Blind)

Every LLM call is traced through Langfuse. Model, token count, latency, prompt version. This is how I caught the Ollama default 32k context issue — a 35% latency hit on classification I would have shrugged off without the data to see it clearly.

Loki + Grafana cover the rest of the stack — agent runs, errors, restart events, scheduled job outcomes.

An agent that runs daily for a year is 365 chances to fail silently. Observability is what turns "silently failing" into "noticed and fixed within hours."

## What's Next

The roadmap, in priority order:

- More agents in the pipeline — Gmail-to-PDF for the doc pipeline, formal eval harness on Langfuse, an HSA tracker that auto-reconciles against the document pipeline output
- Memory layer improvements — cross-agent shared context so an answer in one agent's session can inform another's
- Migrating the dashboard from server-rendered to a Next.js front end if/when it earns the investment

## Why This Project Matters to Me

Personal AI is going to be a thing. The question is whether it runs on infrastructure you own or infrastructure you rent.

Local-first isn't a purity argument. It's a pragmatic one. You get availability that doesn't depend on someone else's API status page. You get cost that doesn't compound with usage. You get privacy by default rather than by negotiation. You get to keep working when the network is bad, when the SaaS goes down, when a model gets deprecated by a vendor decision you weren't consulted on.

Building this in public — or at least documenting it in public — is also a form of leverage. Every pattern that works at home probably works at work. The model router pattern, the three-tier confidence pattern from the doc pipeline, the Discord HITL pattern — all of those are shapes I'd argue for in a production AI deployment, and the reason I trust them is that I run them on my own data first.
