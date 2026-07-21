# LinkedIn Post Schedule

Tracker for LinkedIn posts. Lives at repo root, outside `content/`, so Hugo never publishes it.

**Cadence:** 1 per week, Tuesday, 5:00 AM. (Was 2/week Tue+Thu. Cut on 2026-07-13, see below.)
**Last synced:** 2026-07-20
**Copy/paste:** each post's copy is in a fenced code block. Use the block's copy button (or select inside it) to paste clean text straight into LinkedIn, no `>` prefixes.
**Sync rule:** LinkedIn posts run *after* their blog post is live, so a blog post's pre-publish date moves don't usually touch this file. If a slot is ever at or before its blog post's publish date, move the slot later and note it in the Sync Log.

---

## What the data says (pulled 2026-07-13)

Read this before adding anything to the queue. It is the reason the queue looks the way it does.

### The number that matters most

**`I Was Wrong About AI`, posted ~Sept 2025, did 14,000+ impressions.**

The entire trailing 90 days — 26 posts — did **14,371 impressions combined.**

One confession, written once, matched a full quarter of everything else. That is not a rounding difference or a lucky week. It is a different category of post, and it is the benchmark this file exists to chase.

**The shape that wins is the public reversal.** "I was wrong." "I got this backwards." "The loop worked; my breakdown failed." It is the thing that costs Matt something to say, and it outperforms the architecture writing by roughly 40x per post.

**The constraint is supply, not selection.** The blog is full of excellent architecture and nearly empty of confessions. Filtering the existing backlog harder does not fix that: the winning shape barely exists in the pipeline. **Write more of it.** That is the whole strategy.

### Trailing 90 days (Apr 15 → Jul 13)

| Metric | Value |
|---|---|
| Impressions | 14,371 (+18% vs prior 90 days) |
| Members reached | 6,465 |
| Followers | 2,520 |
| In-network / out-of-network | 39% / 61% |
| Social engagements | 243 (192 reactions, 20 comments, 30 saves, **0 reposts**) |
| **Clicks through to mattgoodrich.com** | **18** |

**14,371 impressions produced 18 blog visits.** A 0.125% click-through rate, roughly one click per 1.5 posts. As a funnel to the blog, this channel does not work, and no amount of copy tuning fixes a number that shape. As a *visibility* channel it does work: reach is up 18% and 61% of impressions are out-of-network, so the algorithm is pushing the posts past Matt's own connections.

Two different goals. Optimize for the second. Stop measuring the first.

### Per-post (exact, read off the activity feed 2026-07-13)

| Post | Impressions | Shape |
|---|---|---|
| Stop Putting Secrets in .env Files (1Password) | **2,764** | Recipe |
| Agents Don't Travel Well (workspace) | **2,228** | Stake + Recipe |
| The First Security Hire Is a Unicorn Hire | **1,719** | Career |
| Agents Need Capabilities, Not Roles | 1,129 | Architecture |
| AI Governance, Calibrated | 994 | Architecture |
| *(repost — Sean Goodpasture job ad)* | 759 | — |
| MCP Authorization When the User Isn't Clicking | 588 | Architecture |
| Every Agent Protocol Earns Its Keep at a Boundary | 535 | Architecture |
| Agent Identities Are Service Accounts That Improvise | 490 | Architecture |
| Your Access Review Is Already Stale | 423 | Architecture |
| **IAM for the Company You Have** (identity hub, Featured #1) | **354** | Architecture |
| Security Is an Overlay, Not a Column | 339 | Architecture |
| MCP Earns Its Keep at the Boundary | 319 | Architecture |
| The Org Chart Is Not the Value Stream | 305 | Architecture |
| What Compliance Work Belongs to the Agent | 253 | Architecture |

The top 3 are **47% of all impressions.** Every post below 600 is an architecture post. Every post above 1,700 is a recipe, a confession, or a career piece. The correlation is not subtle.

`iam-for-the-company-you-have` — the identity-series anchor and the #1 Featured pin — landed at **354**.

Posting ~20 low-engagement pieces a quarter also trains the algorithm down: LinkedIn weights recent engagement rate when deciding reach on the next post. Two mediocre posts a week is worse than one good one. Hence the cadence cut.

---

## The filter

A post earns a LinkedIn slot only if it clears **at least one** of these. If it clears none, it does not get posted. Most posts will not clear one, and that is the point.

1. **Stake** — a confession, a reversal, or something it cost Matt something to say. **This is the one that matters.** *(`I Was Wrong About AI`: 14,000+. `Agents Don't Travel Well`, which opens "I've literally caught myself in bed at night thinking...": 2,228 and the best engagement rate on the account.)*
2. **Recipe** — a thing a reader can do on Monday, with the payload delivered in-feed. *(The .env post gave away all five bullets before the link: 2,764.)*
3. **Career** — hiring, roles, what the job actually is. Human, not architectural. *(First Security Hire: 1,719.)*

**Architecture depth is not a qualifying criterion.** Protocol design, authorization models, and identity-spine posts go on the blog and get found by search and by the people who already care. They do not get individual LinkedIn slots. Every architecture post in the last 90 days landed under 600 impressions, including the ones Matt is proudest of.

### The supply problem (read this before "filtering" anything)

The filter is not the bottleneck. **Stake-shaped content barely exists in the pipeline.**

Going through every published post and every draft, the only piece with a genuine confession in it is `two-systems-for-handing-work-to-agents` (the loop ran perfectly, the work breakdown failed, 17 items stranded, a 47-commit runaway branch). Everything else is architecture, and architecture caps out around 500 impressions.

So the action item is not "select harder from the backlog." It is **write more reversals.** Candidate seeds, none of them written yet:

- What Matt got wrong about the identity series itself (25 posts of architecture that ~350 people read; that is a post)
- A control or framework he championed and would now drop
- A security position he has quietly reversed in the last two years
- The AI-governance stance from `I Was Wrong About AI`, revisited 10 months on: what has changed since, what he'd now put differently

**Do not re-run `I Was Wrong About AI` verbatim.** It already ran and it already won. The lesson is the shape, not the artifact.

---

## Writing rules (STYLE.md applies here too)

LinkedIn copy follows the same `STYLE.md` as the blog:
- No em-dashes (use colons, periods, parentheses). No banned vocab. No cheap "is not X, it is Y" reframes (§5B). No "not just X." No marketing three-part rhythm.
- Voice-exception framings stay: **named dichotomies** (overlay vs column, channel vs caller, granted vs reachable) and **structural framings near the close** (the device was never the point). These carry the argument.
- **"Earns its keep"** only in the deliberate MCP / agent-protocol boundary sense (the sanctioned coinage). Avoid it elsewhere.

LinkedIn format on top of that:
- **Deliver the payload in-feed. The link is a footnote.** This is the rule the data most supports and the one the old queue most violated. The .env post (2,764) gave away all five bullets before the link. The workspace post (2,228) gave away the whole four-line stack. The low performers teased and redirected. A post that only works if you click it is a post that does not work: 14,371 impressions bought 18 clicks. Write the post as if nobody will ever click, because roughly nobody will.
- Hook: punchy, often a flat factual jolt or a "most X does not Y" claim. 1-3 short sentences. Lead with the confession if there is one.
- Hard specifics early: numbers, ratios, dates, named CVEs/standards.
- Short paragraphs, generous line breaks. One *italic* emphasis where it lands.
- A named bulleted (•) list or an inline arrow chain (A → B → C) when there's clean structure.
- A sharp landing line right before the link.
- Length flexible: ~100-word teaser to ~300-word argument. Match the post.
- Link on its own line (bare URL, or `→ URL` for punchy teasers). 3-7 hashtags, `#CISO` usually present. No emoji.
- End on a real question only when the reader can genuinely answer it from experience (the Unicorn post did this and drew comments). Never a rhetorical one.

---

## Featured (profile pins)

**Caution before applying the feed data here.** Featured tiles are seen by people who already landed on the profile: recruiters, prospects, people deciding whether Matt is worth talking to. That is a different audience with different intent than the feed, so a post that underperforms in the feed can still be the right pin. Do not mechanically re-rank Featured by impressions.

That said, two of the current pins are the account's proven resonant pieces and are not pinned, which is a miss.

Suggested 5, revised 2026-07-13. Order matters: only ~2 tiles show on desktop (~1 on mobile) before a scroll most people skip, so the first two are the whole first impression.

1. [The Identity Spine](https://mattgoodrich.com/page/identity/) — **new anchor, published 2026-07-13.** The map of the whole 28-post series: two graphs, and a table of every post with the standards and open-source projects it draws on. This is the strongest single artifact on the site for a profile visitor deciding whether Matt knows identity. It replaces the hub as slot 1, which was the plan all along.
2. [You'll Never Be Greenfield: IAM for the Company You Actually Have](https://mattgoodrich.com/posts/iam-for-the-company-you-have/) — the hub, slid to 2 as planned. It underperformed in the *feed* (354 impressions) but it is the positioning piece and it says what Matt does. Feed reach and profile positioning are not the same job.
3. [Stop Putting Secrets in .env Files: A 1Password Service Account for Claude](https://mattgoodrich.com/posts/1password-service-account-claude-secrets/) — **new.** Best-performing post on the account (2,764). Practical, current, and the thing people actually engaged with.
4. [Agents Don't Travel Well](https://mattgoodrich.com/posts/my-ai-workspace-tmux-cloudflared/) — **new.** Best engagement rate on the account (2,228 impressions, 28 reactions, 6 comments). Shows the AI-agent practice rather than describing it.
5. CISO Series video (keep the stronger of the two) — social proof + visual variety

Dropped: [Agents Need Capabilities, Not Roles](https://mattgoodrich.com/posts/agents-need-capabilities-not-roles/) (1,129), [GRC Engineering](https://mattgoodrich.com/posts/grc-engineering/), and [The Hardest Part of Security](https://mattgoodrich.com/posts/hardest-part-of-security/). All still findable; none earns a scarce tile now that the Spine exists.

The top two now read as "here is the whole map of identity, and here is the argument it rests on."

---

## Posted (history — all run, results where known)

| LI date | Day | LinkedIn title | Impressions |
|---------|-----|----------------|-------------|
| Jun 11 | Thu | Security Is an Overlay, Not a Column | ~240 |
| Jun 16 | Tue | Agent Identities Are Service Accounts That Improvise | ~240 |
| Jun 18 | Thu | Agents Need Capabilities, Not Roles | **1,129** |
| Jun 23 | Tue | MCP Authorization When the User Isn't Clicking | 588 |
| Jun 25 | Thu | MCP Earns Its Keep at the Boundary | ~240 |
| Jun 30 | Tue | Your Access Review Is Already Stale | ~240 |
| Jul 2 | Thu | What Compliance Work Belongs to the Agent | ~240 |
| Jul 7 | Tue | Every Agent Protocol Earns Its Keep at a Boundary | ~535 |
| Jul 9 | Thu | IAM for the Company You Have (identity hub) | **354** |

Plus one post this file never tracked: **The Org Chart Is Not the Value Stream (305).** The file had drifted from reality; re-check the activity feed when syncing, not just this table.

Nine of ten landed under 600. That run is what prompted the 2026-07-13 rethink.

### Posted copy (archive)

**Jun 11 — Security Is an Overlay, Not a Column**  ⚠ STYLE-updated (em-dash → colon); re-copy to LinkedIn

```
Security will never get a column on the org chart that scales with the company. It will never get a person on every value stream. The math forecloses that staffing fantasy before the org politics even start.

The industry benchmark for application security is one engineer per hundred developers. Teams that want genuine coverage need closer to one in twenty. Almost nobody is staffed at one in twenty. Surveys put the share of an application portfolio that gets deep security review as low as 7%.

Streams are added faster than the security team is. The moment a security person is fully embedded in one stream they have stopped being able to see the other eleven. Coverage counted in headcount grows in a line. The work does not.

So security does not get a column and does not get a body in every stream. What it does get to decide is how it attaches to the streams it cannot staff.

I argue the answer is an overlay woven from three modes:
• Embed at the decisions that lock in cost for years (architecture, primarily)
• Program across every stream with shared controls, training, and tooling
• On call for events: incidents, audits, customer asks

Most security teams have never actually designed their answer. They inherited it.

https://mattgoodrich.com/posts/security-is-an-overlay-not-a-column/

#Security #CISO #ProductSecurity
```

**Jun 16 — Agent Identities Are Service Accounts That Improvise**

```
An AI agent's identity is a non-human identity, and ninety percent of what governs it is decades-old hygiene. The other ten percent is where most agent rollouts fail.

A service account always does the same thing. An AI agent decides what to do as it runs, against inputs that may include adversarial text indistinguishable from instructions. The base identity discipline is the same. The operating model is different. The difference is where most agent rollouts go wrong.

The ninety percent that is the same is the harder problem in practice. Short-lived credentials, scoped per-action permissions, identity separated from the invoking user, audit on every call. Those have been the right answer for fifteen years. Most companies still have not implemented them, and the agent rollout is what is finally forcing the bill due.

The ten percent that is genuinely new:
• Prompt injection turns adversarial text into control flow (see EchoLeak / CVE-2025-32711)
• Model versioning rewrites what the agent does without rewriting who it is
• Multi-hop delegation across tools confuses the principal in ways OAuth was not designed for

The honest move: finish the NHI discipline that should have been done by 2022, then add the agent-specific controls.

https://mattgoodrich.com/posts/service-accounts-that-improvise/

#Security #AI #Identity #CISO
```

**Jun 18 — Agents Need Capabilities, Not Roles**  ⚠ STYLE-updated (em-dash → colon); re-copy to LinkedIn

```
An AI agent is not a user, and permissioning one like a user is the most expensive shortcut in the AI rollout.

A user has judgment, a slow reaction time, and a strong incentive not to do anything that gets them fired. The permission model you grant a user assumes all three. A user with database write access does not, in practice, drop tables, because their hand stalls at the keyboard before the command runs.

An agent has none of those properties. It executes the action it was prompted into in milliseconds. It does not stall. It does not weigh the social consequence. The shortcut of inheriting the invoking user's auth at runtime is the version of this mistake most companies are making right now.

Security has known the right answer since 1973. POSIX 'rwx' bound the permission to the action, not the identity. Capability-based security (Dennis & Van Horn, 1966) named the per-action token. AWS IAM actions and OAuth scopes generalized the model. The heritage is right; the application has to catch up.

For agents, the unit of permission is the action grouped by blast radius:
Observation → Drafting → Modification → Sanction → Execution → Destruction

Each class is earned against measured evidence, not granted by calendar time. The framework that holds it is the ISMS you already run: NIST 800-53, NIST 800-37 RMF, ISO 42001, OWASP Agentic AI.

The architecture is half a century old. The work is teaching your existing program to apply it to a new kind of caller.

https://mattgoodrich.com/posts/agents-need-capabilities-not-roles/

#Security #AI #IAM #CISO
```

**Jun 23 — MCP Authorization When the User Isn't Clicking**

```
Desktop AI clients authorize themselves to MCP servers by sending you through a browser OAuth flow.

Headless agents do not click.

That single difference is one of the more consequential decisions in an agent rollout. The transition from interactive OAuth to a non-interactive caller has at least four credible architectures, and the choice between them shapes your audit story, your blast radius, and your rotation cadence for years.

I broke down each architecture in my latest post.

→ https://mattgoodrich.com/posts/mcp-headless-authorization/

#MCP #AI #Security #IAM #OAuth #WorkloadIdentity #CISO
```

**Jun 25 — MCP Earns Its Keep at the Boundary**

```
Articles claiming MCP is going away in favor of direct API calls with workload identity are half right.

For systems you own, the direct call is often cleaner.
For third-party services, MCP is the only surface where security policy, audit, and blast-radius control can actually live.

This is the same principle that played out with API gateways in 2008, service mesh in 2018, and the enterprise service bus in 2005. An abstraction earns its keep at boundaries the team does not own. It becomes theater at boundaries the team does own.

The history rhymes. The hybrid pattern is the answer.

→ https://mattgoodrich.com/posts/mcp-at-the-boundary/

#MCP #AI #Security #Architecture #APIGateway #ServiceMesh #CISO
```

**Jun 30 — Your Access Review Is Already Stale**

```
Every quarter, a manager who hasn't touched a kubectl command in two years clicks Approve on a list of permissions they don't understand.

Compliance gets its checkbox. Nothing actually changed.

The telemetry to do access reviews continuously has existed for years. CloudTrail, IdP logs, SaaS admin trails, Kubernetes audit logs. Every modern system emits "who used what." We just don't use it to inform the review.

The shift is from evidence of process to evidence of outcomes. AI takes the routine volume. A named human still signs the call. The auditor gets faster and more rigorous evidence at the same time.

This is GRC engineering, applied to access.

→ https://mattgoodrich.com/posts/telemetry-driven-access-reviews/

#Security #IAM #GRC #AccessReviews #LeastPrivilege #Compliance #CISO
```

**Jul 2 — What Compliance Work Belongs to the Agent**

```
Not every compliance task should belong to an AI agent. Most should not.

But some pieces of work pass a simple three-property test, and those should.

The work is recurring (the SOC 2 cycle, the daily DLP queue, the monthly vuln scan). It produces evidence-shaped output (an auditor or stakeholder wants the artifact). And the action it proposes is bounded (approve, escalate, deny, draft, file, tag, route).

When all three are true, an agent earns its place. The volume work and the evidence-packaging move to the model. A named human keeps the accountability and signs the decision.

When fewer than three are true, leave it to humans, to classical automation, or to the trash.

The post walks through where this works (questionnaires, vuln triage, DLP, drift), where it does not (vendor risk scoring, cert lifecycle), and the guardrails that separate an agent you put in front of an auditor from one you apologize for in a postmortem.

→ https://mattgoodrich.com/posts/what-compliance-work-belongs-to-the-agent/

#AI #AIAgents #Compliance #Security #GRC #CISO #Governance
```

**Jul 7 — Every Agent Protocol Earns Its Keep at a Boundary**  ⚠ STYLE-updated (rhetorical question → statement); re-copy to LinkedIn

```
An agent talks in three directions: down to its tools, sideways to other agents, up to the user. There's a protocol for each one now: MCP for tools, A2A for agents, and AG-UI, the third protocol that quietly became standard in 2026.

Most production systems run all three at once. What decides whether any one of them earns its keep is the boundary the call crosses.

Two of the three directions cross a trust boundary. The tool call and the agent call can land on something you don't own. The agent-to-user call almost never does, because the frontend is yours.

That's the whole decision:

Inside a boundary you own, the protocol is theater. Your agents already share an identity provider and a runtime, so "agent-to-agent communication" is just a function call. Wrapping it in A2A buys you a signed handshake for an address that's a constant in your own config.

Across a boundary you don't own, the protocol earns its keep. Your procurement agent calling a supplier's quoting agent has no shared function, no shared identity, no shared trust. A2A is the only place authentication, audit, and blast-radius control between the two can live.

One distinction clears up most of the confusion: a protocol is a contract between things you don't both own. A runtime (LangGraph, AutoGen, CrewAI, ADK) is how you wire together things you do. Pick a runtime for ergonomics, because you can swap it. Pick a protocol for the boundary it spans, because that was never yours to redesign.

The protocol-wars worry from 2025 is mostly over. MCP, A2A, and AG-UI now sit under one Linux Foundation body with every major cloud as a co-founder. They stopped competing and started layering.

New post:
https://mattgoodrich.com/posts/agent-communication-stack/

#AI #AIAgents #Security #Architecture
```

---

## Queue (rebuilt 2026-07-13 on the filter)

1/week, Tuesday, 5:00 AM. Each slot names which filter criterion it clears. **The 24 remaining identity-series drafts are retired** and collapsed into one synthesis post (Jul 21). Their copy is preserved in the archive at the bottom of this file and is the source material for that synthesis.

| LI slot | Day | Post | Clears | Blog live | Copy |
|---------|-----|------|--------|-----------|------|
| Jul 14 | Tue | Collapsing a Pile of Tunnels onto Tailscale | **Recipe** | 7/13 ✓ | drafted below |
| Jul 21 | Tue | Two Systems for Handing Work to Agents | **Stake + Recipe** | 7/20 ✓ | drafted below |
| Jul 28 | Tue | The Identity Ladder (synthesis — replaces 24 posts) | **Recipe** | 6/07 ✓ | drafted below |
| Aug 4 | Tue | Pasting Screenshots Into a Remote Claude Session | **Recipe** | 7/14 ✓ | not yet drafted |
| Aug 11+ | — | **OPEN — needs a stake-shaped post that does not exist yet** | — | — | — |

**The queue is four slots deep and then it stops.** That is not an oversight. It is the honest state of the material.

**Not queued, and why:**

- **`I Was Wrong About AI`** — already ran (~Sept 2025, 14,000+ impressions). Do not re-run it verbatim. Mine the *shape*, write a new one.
- **`The Perfect Storm` (AI hiring crisis)** — already ran, and it is news-pegged. A stale news peg is a real reason to skip.
- **`1Password SSH Agent`** — already ran. The weaker sibling of the .env post.
- **The identity / authorization / MCP spine (25+ posts)** — the best writing on the site, and every one of them landed under 600. They stay on the blog and get found by search.
- **The parked drafts** (`local-ai-on-paperless`, `personal-ai-agent-system`, `six-years-alteryx`, `travel-tracker`) — not ready, and per Matt (2026-07-13) they may never ship. **Do not plan the queue around them.**

**Cadence.** Do not backfill empty weeks with weaker material to hit a cadence target. Filler depresses the reach of the posts that matter. **If nothing clears the filter, skip the week.** An empty slot costs nothing; a 250-impression architecture post costs reach on the next real one.

**To extend past Aug 4, something new has to get written.** See the supply problem above. The blog backlog cannot fill these slots, because the blog backlog is architecture.

---

## Queue copy

### Jul 14 — Collapsing a Pile of Tunnels onto Tailscale  *(Recipe)*

```
I had three different tools doing the same job, and every one of them worked.

SSH tunnels from the Mac Studio to my Unraid server. UniFi's Teleport VPN to get a laptop onto the home network. Cloudflare tunnels for a fast SSH in, and for the networks that block a VPN outright (a cruise ship is the honest example).

Three configs. Three failure modes. Three things to debug when a laptop can't reach home. The pile was the problem. No single tool in it was.

Tailscale collapsed all three into one overlay:
• Every device authenticates to my identity provider, then reaches the others directly by name, wherever they are
• MagicDNS, so every machine answers to a short name
• Device approval and key expiry on, so a new machine can't silently join
• WireGuard underneath, free plan

And it fixed the thing I actually cared about. A VPN that drops you onto the flat LAN gives you the whole network the moment you're on it. Tailscale scopes access per device and per service: being on the overlay does not mean being trusted for everything on it.

Cloudflare kept the one job it's actually for: public ingress.

Full writeup, including what Tailscale doesn't solve:
https://mattgoodrich.com/posts/collapsing-a-pile-of-tunnels-onto-tailscale/

#Tailscale #ZeroTrust #Homelab #Networking #CISO
```

### Jul 28 — The Identity Ladder  *(Recipe — synthesis, replaces 24 queued posts)*

```
You will never be greenfield.

Security best practices assume a company that doesn't exist: clean directory, one identity provider, every app on SSO, no acquisitions, no debt.

What you have is three IdPs from three acquisitions, a VPN nobody will own, service accounts whose passwords live in a wiki, and more SaaS than finance can list. That is the company you are securing. Not the one on the slide.

I spent three months writing 25 posts on identity. Here is the whole argument in one place, as a ladder you cannot skip rungs on:

1. One front door. Get to a single place to revoke before you do anything clever.
2. Automate the leaver before the joiner. Onboarding is a convenience. Offboarding is the breach.
3. Roles, until they stop scaling. They will, and sooner than you think.
4. Authorization is three decisions, not one: the policy, the evaluation, and the data. Each can be central or local, independently.
5. Device trust after user trust, not before it.
6. Per-app access instead of a flat network. Being on the VPN should not mean being trusted on everything behind it.
7. Workload identity for the machines. Secrets are the thing you're trying to stop shipping.
8. Continuous, risk-based access. Last. It demos beautifully and holds nothing up on its own.

Most teams reach for rung 8 because it's the one on the conference slide, then wonder why it doesn't hold. The rung under it was never built.

Which rung is your program actually standing on?

I mapped the whole thing: 28 posts, the path through each one, and the standards and open-source projects each leans on.

https://mattgoodrich.com/page/identity/

#IAM #IdentitySecurity #ZeroTrust #CISO
```

*(Links to the Identity Spine map, not the hub post. The map is the better destination and it is the new Featured #1.)*

### Jul 21 — Two Systems for Handing Work to Agents  *(Stake + Recipe)*

*(Reframed 2026-07-20 to Matt's "work while I sleep" arc: the experiment framing as the hook, the concrete overnight failure kept as the stake, the two-bucket "where each wins" as the in-feed payload. Prior confession-first draft preserved in git history.)*

```
I've been building different ways to work while I sleep: agents that pick up real tasks overnight and hand me finished work in the morning.

The first version kept everything in git. The backlog, the state, the claim on each task, all of it lived in the repo as files the agents edited. It worked. I woke up to merged PRs. But it taxed every task: because main was protected, one commit of real code cost three pull requests (claim the work, merge it, reconcile the status). The status file was also a lock, and parallel agents kept colliding on it.

So I moved the backlog and the state out of git, into a self-hosted issue tracker the agents poll every 12 minutes. The tax disappeared. A state change went from three pull requests to one API call. Then a different problem showed up. I let four features run overnight, every issue came back "implementation complete," and the feature was broken at the first database write. The loop executed perfectly. My breakdown of the work was what failed.

I went in expecting to find the "right way" to do this. I came out with something more useful: each model has its place.

• Queue in the repo: best inside one deep codebase, where the work and the queue live together and git history is the audit trail.
• Queue in a tracker: best the moment work crosses a boundary (another repo, another machine, a deploy), and when it has to run whether I'm at the keyboard or not.

Two runtimes polling a tracker every 12 minutes is a solved problem. How you cut the work into tasks is not.

https://mattgoodrich.com/posts/two-systems-for-handing-work-to-agents/

#AI #AIAgents #ClaudeCode #SoftwareEngineering #CISO
```

---

## Archive — identity series copy (RETIRED from the queue 2026-07-13)

**These 24 posts are no longer scheduled.** They were drafted 2026-06-09 as a Jul 9 → Oct 1 run at 2/week. The 90-day data (see top of file) showed the identity/architecture posts averaging ~240 impressions, so the run was retired before it started. Only #1 (Jul 9, the hub) ever ran; it landed under 535 impressions.

**Nothing here is wasted.** This copy is the source material for the Jul 21 synthesis post, and every one of these blog posts is live and findable. If a single rung ever earns its own slot (a news hook, a conference talk, a reader question), the copy is ready. Do not re-queue the run wholesale.

### 1. Jul 9 — IAM for the Company You Have

```
Security best practices assume a company that doesn't exist.

Clean directory. One identity provider. Every app on SSO. No legacy, no acquisitions, no debt. Start there, the maturity model says.

You will never be greenfield.

You have three IdPs from three acquisitions, a VPN nobody will own, service accounts whose passwords live in a wiki, and more SaaS than finance can list. That is the company you are securing. Not the one on the slide.

So the real question is which rung you climb next, given where you actually stand.

I think about identity as a ladder you cannot skip:
• Get to one front door before you do anything clever
• Automate the leaver before the joiner
• Earn continuous, risk-based access last, not first

Most teams reach for the top rung because it demos well, then wonder why it does not hold. The rung under it was never built.

https://mattgoodrich.com/posts/iam-for-the-company-you-have/

#IAM #IdentitySecurity #ZeroTrust #CISO
```

### 2. Jul 14 — One Front Door, One Place to Revoke

```
The fastest way to fail an offboarding is to have more than one front door.

Every app with its own login is a door you have to remember to lock when someone leaves. Miss one, and a former employee, or whoever phished them, still has a way in weeks later.

Single sign-on is the difference between revoking access in one place and revoking it in fifteen, hoping you got them all.

Consolidate the logins and two hard problems collapse into one:
• One place to prove who someone is (SAML / OIDC)
• One place to cut them off, instantly, everywhere (SCIM)

The tax is real. Plenty of vendors gate SSO behind their top pricing tier, the industry even has a name for it: the SSO tax. Pay it anyway for anything that touches real data. The alternative is paying it in breaches.

https://mattgoodrich.com/posts/one-front-door-one-place-to-revoke/

#IAM #SSO #IdentitySecurity #CISO
```

### 3. Jul 16 — Automate the Leaver Before the Joiner

```
Most companies automate onboarding first. It's the visible pain: a new hire sitting idle, waiting for accounts.

The leaver is the one that gets you breached.

When someone leaves and their access lingers, you have a credential with no human attached, no one watching it, and every reason for an attacker to go looking. Orphaned access is one of the most reliable ways into a company.

So automate the leaver before the joiner. Wire deprovisioning to the same HR event that triggers onboarding, so the moment someone is marked a leaver their access is gone, everywhere, with no ticket and no human remembering.

Joiner-mover-leaver is one loop. Most teams build a third of it (the joiner), do the leaver by hand, and skip the mover entirely. The mover is how people accumulate access they no longer need until they look like a walking audit finding.

https://mattgoodrich.com/posts/automate-the-leaver-before-the-joiner/

#IAM #IdentitySecurity #Offboarding #CISO
```

### 4. Jul 21 — Roles Don't Scale the Way You Think

```
Give it a few years and you will have more roles than employees.

RBAC starts clean: a handful of roles, everyone slots into one. Then reality arrives. Someone needs almost-this-role-but-not-quite, so you make a new one. Do that for three years and you have a role for nearly every person, which is just per-user permissions wearing a costume.

Roles don't scale the way the textbook promises. The number of distinct access patterns in a real company grows faster than any tidy set of roles can track.

What actually works is a mix:
• Roles for the broad, stable stuff (everyone in support sees the support tools)
• Attributes for the contextual stuff (department, location, data sensitivity)
• Just-in-time, through a broker, for the access that can hurt you (production, finance)

The mistake is forcing all of it into roles, then drowning in role explosion and quarterly access reviews nobody can actually read.

https://mattgoodrich.com/posts/roles-dont-scale-the-way-you-think/

#IAM #RBAC #ABAC #CISO
```

### 5. Jul 23 — Authorization Broker Models

```
The safest standing privilege is the one that isn't standing.

Most "who can touch production" lists are a pile of permanent grants that made sense once and never got revoked. Every one is a credential an attacker can phish or a laptop they can steal, sitting there 24/7 whether or not anyone is using it.

An authorization broker flips that. Nobody holds production access. They request it, a policy engine checks who they are, what device they're on, and why, and they get a short-lived credential that expires on its own.

The access that can hurt you most should exist for the least time:
• Request, with a reason
• Policy decides, in real time
• Short-lived credential, auto-expiring
• Full audit trail of who reached what, when

Teleport, HashiCorp Boundary, and Vault all do versions of this in the open. The standing admin account is the thing attackers count on. Stop leaving it lying around.

https://mattgoodrich.com/posts/authorization-broker-models/

#IAM #ZeroTrust #PAM #CISO
```

### 6. Jul 28 — Break-Glass Without the Backdoor

```
Your break-glass account is a backdoor you wrote a runbook for.

Every company keeps one: the emergency account that bypasses MFA, SSO, and conditional access so you can get back in when identity itself is down. It is also the single most valuable thing in your environment to an attacker, sitting outside every control you built.

The trap is making it a permanent, standing super-credential and calling it "emergency access." That is a backdoor with a procedure attached.

Break-glass done right is a tightly bounded exception, not a parallel admin path:
• Sealed until used (credentials split, vaulted, alarmed)
• Scoped by policy (an AWS SCP can fence even root)
• Loud on use: every break-glass login pages a human in real time
• Rotated and re-sealed immediately after

The test is simple: if using your break-glass account doesn't wake someone up, you don't have break-glass. You have a backdoor.

https://mattgoodrich.com/posts/break-glass-without-the-backdoor/

#IAM #IdentitySecurity #IncidentResponse #CISO
```

### 7. Jul 30 — You Can Reach More Than You Were Granted

```
The permissions you were granted are not the permissions you have.

A cloud identity with "read-only" on one service and "pass role" on another can often chain the two into admin. Nobody granted admin. The policy graph did.

This is the gap between granted access and reachable access. Your IAM console shows what you handed out. It does not show where those grants connect: the role that can assume another role, the function that runs as a stronger principal, the policy that can edit policies.

Attackers map the reachable set. Most defenders only audit the granted set.

Open-source tooling closes the gap. PMapper and Cartography build the actual permission graph; BloodHound and AzureHound do it for AD and Entra. They answer the question your console can't: from here, what can this identity ultimately reach?

Audit the graph, not the grants. The grant is the front door. The reachable set is the whole house.

https://mattgoodrich.com/posts/you-can-reach-more-than-you-were-granted/

#CloudSecurity #IAM #IdentitySecurity #CISO
```

### 8. Aug 4 — Zero Trust Is a Sequence, Not a Posture

```
You cannot buy zero trust. No vendor sells it, because it is a property of an architecture, not a feature you deploy.

Zero trust gets sold two wrong ways: as a posture you either have or don't, and as a product that makes you "zero trust" the day it's installed. It is neither. It is a set of controls that pay off in an order.

And the order is not optional:
• Identity first (you can't evaluate a request you can't attribute)
• Then device (is the thing it came from healthy)
• Then least privilege and per-app access (shrink what each reaches)
• Then continuous, risk-based evaluation, last, not first

Build it out of order and you get a sophisticated control evaluating requests it can't trust. Microsegment with no clean identity behind it, and you've drawn careful walls around traffic you can't attribute.

CISA's maturity model is staged for a reason. Most companies should reach solid Advanced on identity and access and stop there. You're allowed to stop climbing when the next rung costs more than the risk it removes.

https://mattgoodrich.com/posts/zero-trust-is-a-sequence/

#ZeroTrust #IAM #Security #CISO
```

### 9. Aug 6 — MFA That Survives Phishing

```
Most MFA does not survive a phishing attack.

The push notification, the 6-digit code, the SMS, all of them can be relayed in real time by a phishing proxy that sits between your user and the real login. The user approves, the attacker is in. Scattered Spider has run this play against help desks and employees repeatedly (CISA AA23-320A).

What survives is MFA bound to the origin. A FIDO2 security key or a passkey signs a challenge tied to the real domain, so a lookalike site gets a signature it cannot use. The phish has nothing to relay.

The dividing line is where the private key lives and whether the factor checks the origin:
• Phishable: SMS, TOTP codes, push approvals
• Phishing-resistant: FIDO2 keys, device-bound passkeys, WebAuthn

Roll it out in blast-radius order: admins and crown-jewel apps first. And know that compliance frameworks are still catching up to passwordless, so you may be ahead of your own checklist. Be ahead anyway.

https://mattgoodrich.com/posts/mfa-that-survives-phishing/

#MFA #Phishing #IdentitySecurity #CISO
```

### 10. Aug 11 — Trust the User, Then the Machine

```
You can prove exactly who is making a request and have no idea what they are making it from.

A user signs in with a phishing-resistant passkey. The login is genuinely theirs. It tells you nothing about whether the laptop behind it is a hardened company machine or a personal box riddled with malware riding their valid session.

User authentication answers one question. The machine is a second one, and most access decisions never ask it.

Device-based authentication asks it with two separate claims:
• Device identity: a hardware-bound certificate proving this is a machine you enrolled
• Device posture: live signals proving it's healthy right now (encrypted, patched, EDR running)

A cert proves identity and says nothing about health. Posture proves health and says nothing about identity. You need both, evaluated live, because a well-maintained attacker laptop has great posture and no business on your network.

Verify the person. Then verify the machine they brought.

https://mattgoodrich.com/posts/trust-the-user-then-the-machine/

#ZeroTrust #DeviceTrust #IdentitySecurity #CISO
```

### 11. Aug 13 — Per-App Access Ends the Flat Network

```
A VPN does one thing well and one thing badly. It authenticates you to a network. Then it trusts you on all of it.

Once a phished laptop is on the VPN, it isn't on one machine, it's on the network, with line of sight to every box on the subnet. The login was the only gate, and it was at the edge. That's how one credential becomes a breach.

The fix is changing the unit of access from the network to the application:
• Network access (VPN): a route to everything, lateral movement by default
• Application access (ZTNA): a tunnel to the one app you're entitled to, the rest invisible

Google's BeyondCorp is the reference build; OpenZiti and Pomerium do it in the open. The broker checks identity and device, then proxies you to one app while everything else stays dark.

The perimeter doesn't disappear when the VPN does. It moves, off the network and onto identity and device, re-proven on every connection.

https://mattgoodrich.com/posts/per-app-access-ends-the-flat-network/

#ZeroTrust #ZTNA #NetworkSecurity #CISO
```

### 12. Aug 18 — The Gateway Can't See the Object

```
Your API gateway can check whether you may call an endpoint. It cannot see whether this row, this document, this account is yours.

That gap has a name on the OWASP API Top 10: Broken Object Level Authorization. It's the number one API risk, and it's number one because the gateway sits in the wrong place to fix it. The object lives inside the application; the gateway only sees the request.

So the authorization decision has to move next to the data. Two patterns do it:
• Policy engines (OPA, Cedar) evaluate "can this user do this to this object" at the service
• Relationship models (Google's Zanzibar, and OpenFGA / SpiceDB that implement it) answer it at scale

The tell that you have this bug: an endpoint that takes an ID and trusts it. Change the ID in the request, get someone else's data. No gateway rule catches that, because to the gateway it's a valid call.

Put the authorization where the object is.

https://mattgoodrich.com/posts/the-gateway-cant-see-the-object/

#AppSec #Authorization #APISecurity #CISO
```

### 13. Aug 20 — Access Should Know What the Data Is

```
Most access control protects systems: this database, that bucket, this app. It says nothing about what's inside them.

So the same "read" permission guards a marketing list and a table of social security numbers. The control has no idea there's a difference. The data does, but the data isn't part of the decision.

Data-centric access ties the control to the data's classification, so protection follows the data instead of the container. The pieces:
• Classify (NIST FIPS 199 gives you the impact levels)
• Label (Microsoft Purview sensitivity labels, plus Presidio / Macie to find what you missed)
• Decide on the label, so a "confidential" tag carries its own access rules wherever the data lands

This is the hardest zero-trust pillar to finish, because it depends on knowing what you have, and most companies don't. But it's the one that turns a permission into a guarantee.

https://mattgoodrich.com/posts/access-should-know-what-the-data-is/

#DataSecurity #ZeroTrust #DataClassification #CISO
```

### 14. Aug 25 — When You Can Use Workload Identity

```
The best API key is the one you never store, because you never had one.

Most service-to-service auth still runs on a long-lived secret sitting in an env var or a config file, waiting to leak. Workload identity removes the secret entirely: the platform vouches for the workload, and the workload exchanges that proof for short-lived credentials at runtime.

AWS does it with IRSA, GKE with Workload Identity, and SPIFFE/SPIRE does it across clouds. The pod proves what it is to the platform; the platform mints a credential that expires in minutes.

But it only works inside a trust boundary the platform controls. The moment a workload runs somewhere the cloud can't vouch for it, you're back to a secret, and the honest move is to manage that secret well, not pretend you eliminated it.

Drop the secret where you can. Where you can't, know exactly why, and rotate it.

https://mattgoodrich.com/posts/when-you-can-use-workload-identity/

#WorkloadIdentity #CloudSecurity #SPIFFE #CISO
```

### 15. Aug 27 — Workload Identity That Crosses Boundaries

```
Every workload-identity scheme bottoms out in one thing it cannot prove from the inside: the very first secret. The "bottom turtle."

Cloud workload identity solves this beautifully, as long as you stay on one cloud. IRSA is an AWS answer. GKE Workload Identity is a Google answer. The moment a workload has to authenticate across clouds, or to a partner, the cloud's vouching stops at its own edge.

SPIFFE moves the bottom turtle to the infrastructure. SPIRE attests a workload from properties the platform already knows (its node, its kernel, its kubelet) and issues it an SVID, a short-lived identity document the workload can present anywhere that trusts the SPIFFE root, including across clouds via OIDC federation and IAM Roles Anywhere.

One identity per workload, that travels. The IETF's WIMSE working group is standardizing where this goes next.

https://mattgoodrich.com/posts/workload-identity-that-crosses-boundaries/

#SPIFFE #WorkloadIdentity #CloudSecurity #CISO
```

### 16. Sep 1 — Non-Human Identities

```
Machine identities outnumber human ones by more than 80 to 1, and nobody owns most of them.

Service accounts, API keys, tokens, certificates, CI runners, bots. Every one is an identity that can authenticate, and unlike your employees, they don't leave, don't rotate their own credentials, and don't show up in the joiner-mover-leaver process you built for people.

The result is a sprawl of non-human identities with standing access and no human attached. The credential in a config file from 2019 still works. GitGuardian finds millions of secrets leaked in public repos every year.

The discipline is old and unglamorous:
• Short-lived credentials over standing keys
• Scoped per-action, not broad
• An owner and an expiry for every one
• Detection for the leaked ones (Gitleaks, TruffleHog) and a vault to stop minting more (External Secrets, SPIFFE)

Your agent rollout is about to add thousands more. Fix the discipline before you do.

https://mattgoodrich.com/posts/non-human-identities/

#NHI #IdentitySecurity #Secrets #CISO
```

### 17. Sep 3 — Logging Out Is Harder Than Logging In

```
Logging in is instant. Logging out, everywhere, is the genuinely hard part.

A user clicks "sign out" and your IdP ends its session. But the app they were using minted its own session token, and that one is still valid. Revoke the user's access and they can keep working on a cached token for minutes or hours, exactly the window an attacker wants.

There are two clocks: the IdP session and every downstream app session. Logout only really happens when both stop.

The standards exist to close the gap:
• OIDC back-channel logout tells apps to kill their sessions (Keycloak, Authentik, Ory Hydra implement it)
• OAuth token revocation invalidates the token itself
• The Shared Signals Framework and CAEP push a "this session is no longer valid" event in near real time

If your logout only ends the IdP session, you haven't logged anyone out of anything that matters. You've just closed one of the doors.

https://mattgoodrich.com/posts/logging-out-is-harder-than-logging-in/

#IAM #IdentitySecurity #OAuth #CISO
```

### 18. Sep 8 — Identity Is Becoming Continuous

```
Authentication used to be a moment: you proved who you were at login, and the session was yours for the next ten hours no matter what happened.

That model is ending. A device falls out of compliance, a risk score jumps, a credential shows up on a breach list, mid-session, and the old model does nothing until the token expires.

Continuous access evaluation closes that window. Instead of trusting a login for hours, the IdP and the apps subscribe to a stream of signals and re-decide access as the facts change.

The plumbing is standardizing fast:
• The Shared Signals Framework carries the events between systems
• CAEP (Continuous Access Evaluation Profile) defines the access-change signals
• Microsoft, Okta, and Google already ship versions of it

The session that authenticated strongly at 9am should not still be trusted at 3pm if the device it's on stopped being trustworthy at noon. Identity is moving from a gate to a feed.

https://mattgoodrich.com/posts/identity-is-becoming-continuous/

#IdentitySecurity #ZeroTrust #CAEP #CISO
```

### 19. Sep 10 — The Other Half of Identity Security

```
You can build flawless identity controls and still completely miss the attack against them.

Prevention is half the job: SSO, MFA, least privilege, the works. The other half is detection, noticing when someone abuses identity that's working exactly as designed. A valid login from a new country. A service account that suddenly enumerates every bucket. An admin role assumed at 3am.

None of that trips a prevention control, because nothing is broken. The credentials are real. The permissions are granted. It just isn't the legitimate owner using them.

So instrument the identity plane like the attack surface it is:
• Behavioral baselines per identity (human and non-human)
• Detections for impossible travel, privilege escalation, dormant-account wake-ups
• Open tooling that fits: Falco for runtime, Sigma for portable detection rules, Wazuh for the host signal

The teams that get breached through identity usually had the controls. What they didn't have was anyone watching the controls work.

https://mattgoodrich.com/posts/the-other-half-of-identity-security/

#DetectionEngineering #IdentitySecurity #SOC #CISO
```

### 20. Sep 15 — Your Authorization Model Is Never Done

```
Fine-grained authorization starts clean and never stays that way.

You begin with a tidy relationship model: who can touch which object. A Zanzibar-style graph, OpenFGA or SpiceDB under it, and for a while every access question has a crisp answer.

Then the product grows. New object types. New permission verbs. A request for "team admins, but not billing." Roles and groups creep back in. The access graph never stops changing, and now it's load-bearing.

Choosing the model is the easy part. Migrating it while it's live, with real users and real grants and no lockouts and no quietly-opened doors, is the hard one.

So treat authorization like the evolving system it is:
• Version the model and migrate it deliberately, not by accident
• Test access changes the way you test schema changes
• Keep the engine (OpenFGA, SpiceDB, Cedar, Oso) separate from the policy so you can reason about each

The model is never done. Build for the change, not the first clean version.

https://mattgoodrich.com/posts/your-authorization-model-is-never-done/

#Authorization #ProductSecurity #ReBAC #CISO
```

### 21. Sep 17 — Whose Request Is This, Three Hops In?

```
A request comes into your product carrying a real, authenticated user. By the third internal service it touches, that user is gone.

A service mesh and mTLS prove one service is talking to another, the channel. They carry nothing about the original caller, the user on whose behalf every downstream call is being made. The ledger service three hops in knows the orders service called it, and has no idea which customer the call is about.

In multi-tenant SaaS, that dropped identity is a whole category of bug. Any internal service that trusts its caller and acts on the IDs it's handed can't enforce the tenant boundary, because it doesn't know whose request this is.

The fix is two moves:
• Carry the caller (OAuth token exchange, or the IETF's new Transaction Tokens) so the user identity travels the call chain
• Enforce it at each hop that touches tenant data, and derive the tenant from the verified caller, never from a value the caller passes in

The mesh secures the channel. The caller is the part you still have to carry.

https://mattgoodrich.com/posts/whose-request-is-this-three-hops-in/

#AppSec #Kubernetes #Authorization #CISO
```

### 22. Sep 22 — Collapse the Surface, Then Defend It

```
The cheapest attack surface to defend is the one you removed before you started defending.

Most security programs add controls on top of sprawl: more monitoring, more policies, more reviews, all wrapped around an estate that keeps getting bigger. You can do that forever and never catch up, because the surface grows faster than the controls.

The move that changes the math is collapsing the surface first. Every identity provider you consolidate, every standing credential you make just-in-time, every flat network you segment, every app you put behind one front door, is attack surface that no longer needs defending because it no longer exists.

This whole identity series has been one argument made in pieces: SSO, lifecycle, least privilege, per-app access, workload identity, session control. Each one removes a class of exposure before it asks you to monitor for it.

Collapse the surface, then defend what's left. Defending everything is how you defend nothing.

https://mattgoodrich.com/posts/collapse-the-surface-then-defend-it/

#Security #IAM #ZeroTrust #CISO
```

### 23. Sep 24 — Friction Is Why People Hoard Access

```
People hoard access for the same reason they hoard anything: getting it the first time was painful, and they never want to do it again.

If requesting access means a ticket, a three-day wait, and a manager who doesn't understand the ask, your users will do the rational thing: grab everything they might ever need, the first time, and hold it forever. Your least-privilege program loses to a Friday deadline every single time.

The fix is less friction on the right path:
• Self-service requests that resolve in minutes, not days
• Just-in-time grants that expire on their own, so holding access is the inconvenient option
• Paved roads where the secure way is also the fast way

When asking again is cheap, people stop hoarding, because there's nothing to gain by it. Least privilege is won by making the narrow path the easy one.

https://mattgoodrich.com/posts/friction-is-why-people-hoard-access/

#IAM #LeastPrivilege #SecurityCulture #CISO
```

### 24. Sep 29 — A Secure Enterprise on Devices You Don't Own

```
Picture a company that issues no laptops and runs no VPN. Everyone works from the phone and computer they already own. It sounds like a security team's resignation letter.

It can be more locked down than the company handing a managed laptop to every hire, because it's forced to stop trusting the two things that were never as trustworthy as they looked: the device and the network.

Strip both away and the trust has to go somewhere that holds up:
• The data never lands on the device. The endpoint is a window onto apps that keep their data server-side, not a safe that stores it.
• Identity does the work. A phishing-resistant key is the one piece of hardware worth issuing, because it holds up on a device and network you don't control.
• Access goes per-app, not per-network, so a compromised personal laptop reaches one thing, not everything.

You still hand out managed machines for the crown jewels. For everyone else, the device was never the point. The data and the identity were.

https://mattgoodrich.com/posts/secure-enterprise-on-devices-you-dont-own/

#BYOD #ZeroTrust #IdentitySecurity #CISO
```

### 25. Oct 1 — Standardize the Gates, Not the Steps

```
Stop trying to standardize how your teams work. Standardize the gates their work has to pass through.

Every team has a different stack, a different pipeline, a different way of shipping. The classic compliance move is to force one process on all of them, and it fails the same way every time: the process doesn't fit, teams route around it, and the control exists only on paper.

The durable version inverts it. Don't dictate the steps. Define the gate, the check the output has to clear, and let each team meet it however their stack allows:
• The gate is policy as code (OPA / Conftest evaluates the artifact)
• The evidence is generated, not attested (Sigstore signs what actually shipped)
• The standard is the outcome (NIST OSCAL expresses the control), not the workflow

Standardize the gate and you get consistency without the fight. Standardize the steps and you get a binder nobody follows.

https://mattgoodrich.com/posts/standardize-the-gates-not-the-steps/

#GRC #Compliance #DevSecOps #CISO
```

---

## Sync log

- 2026-07-20 — **Two Systems published and promoted up.** Blog post `two-systems-for-handing-work-to-agents` finalized and pushed live (date re-stamped to now per Matt). Swapped it into the Jul 21 LinkedIn slot ahead of The Identity Ladder — it is the one genuine stake/confession in the pipeline (the reason the strategy exists), so it takes the next slot rather than waiting until Jul 28. Clean single swap: Identity Ladder → Jul 28, Aug 4 (Pasting Screenshots) unchanged, no cascade. Copy was already drafted and was re-checked line-by-line against the final post (four features, six Meross issues, 47-commit branch, 17 stranded items, five rules) — accurate, no edits needed. Also this session: published the Open Engine autonomy policy + to-engine/break-to-engine skills to the public plane-client repo (redacted) and linked them from the post; added four themed mermaid diagrams.
- 2026-07-13 — **Identity Spine published.** Page went live at `/page/identity/`. Fixed it first: it was 2 posts stale (drawn 6/09, missing `whose-request-is-this-three-hops-in` and `authorization-is-three-decisions-not-one`). Added both to the table, updated the Product authorization thread, regenerated both mermaid diagrams (26 → 28 nodes), corrected the alt text. Promoted it to Featured #1 and repointed the Jul 21 LinkedIn copy at the map instead of the hub.
- 2026-07-13 — **Strategy reset on the data.** Pulled LinkedIn creator analytics + read exact per-post impressions off the activity feed. Trailing 90 days: 14,371 impressions across 26 posts, 18 blog clicks, and every architecture post under 600. Then the decisive datapoint, from Matt: **`I Was Wrong About AI` (~Sept 2025) did 14,000+ impressions on its own — matching the entire last quarter combined.** Conclusion: the winning shape is the public reversal, and the real constraint is *supply*, not selection. The blog is full of architecture and nearly empty of confessions. Actions: cadence cut 2/week → 1/week Tuesday; added the stake/recipe/career filter with Stake named as primary; **named the supply problem explicitly and listed four unwritten reversal seeds**; retired the 24-post identity backlog into one synthesis post (Jul 21, The Identity Ladder); rebuilt the queue to 4 honest slots (Jul 14 → Aug 4) and left Aug 11+ deliberately empty rather than backfilling with architecture; added the "deliver the payload in-feed, the link is a footnote" rule; corrected all impressions to exact figures; caught one untracked post (Org Chart, 305); revised Featured to pin the two proven performers. Dropped as already-run: I Was Wrong About AI, The Perfect Storm, 1Password SSH Agent. Parked drafts excluded from planning per Matt (may never ship). All 24 retired identity drafts preserved in the archive below.
- 2026-06-09 — Created. Recorded the 8 scheduled posts (Jun 11 – Jul 7) with copy mirrored. Drafted the identity-series backlog: 25 posts, Jul 9 → Oct 1, 2/week Tue/Thu.
- 2026-06-09 — Reformatted all copy into fenced code blocks for clean copy/paste. Applied STYLE.md to LinkedIn: fixed ~6 §5B reframes / a "not just" in the drafts; flagged + corrected 3 scheduled posts (2 em-dashes → colons, 1 rhetorical question → statement). Those 3 need re-copying into the LinkedIn scheduler to match. Normalized the 8 lnkd.in links to canonical mattgoodrich.com URLs.
- 2026-06-09 — Jul 9 (the hub, IAM for the Company You Have) scheduled in LinkedIn. ✅
