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
| Jul 21 | Tue | Two Systems for Handing Work to Agents | *(tbd)* |

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

1/week, Tuesday, 5:00 AM. Each slot names which filter criterion it clears. **The 24 remaining identity-series drafts are retired** and collapsed into one synthesis post, The Identity Ladder (queued below, not yet posted). Their 24 individual drafts were archived at the bottom of this file; those were removed 2026-07-21 to slim the doc and are preserved in git history.

| LI slot | Day | Post | Clears | Blog live | Copy |
|---------|-----|------|--------|-----------|------|
| Jul 28 | Tue | Letting the Loop Merge | **Stake + Recipe** | 7/21 ✓ | drafted below |
| Aug 4 | Tue | Make Mistakes Cheap Before You Let the Agent Run | **Stake + Recipe** | 7/22 ✓ | drafted below |
| Aug 11 | Tue | The Identity Ladder (identity-series synthesis) | **Recipe** | 6/07 ✓ | drafted below |
| Aug 18 | Tue | Collapsing a Pile of Tunnels onto Tailscale | **Recipe** | 7/13 ✓ | drafted below |
| Aug 25 | Tue | Pasting Screenshots Into a Remote Claude Session | **Recipe** | 7/14 ✓ | not yet drafted |
| Sep 1+ | — | **OPEN — needs a stake-shaped post that does not exist yet** | — | — | — |

**The queue is four slots deep and then it stops.** That is not an oversight. It is the honest state of the material.

**Not queued, and why:**

- **`I Was Wrong About AI`** — already ran (~Sept 2025, 14,000+ impressions). Do not re-run it verbatim. Mine the *shape*, write a new one.
- **`The Perfect Storm` (AI hiring crisis)** — already ran, and it is news-pegged. A stale news peg is a real reason to skip.
- **`1Password SSH Agent`** — already ran. The weaker sibling of the .env post.
- **The identity / authorization / MCP spine (25+ posts)** — the best writing on the site, and every one of them landed under 600. They stay on the blog and get found by search.
- **The parked drafts** (`local-ai-on-paperless`, `personal-ai-agent-system`, `six-years-alteryx`, `travel-tracker`) — not ready, and per Matt (2026-07-13) they may never ship. **Do not plan the queue around them.**

**Cadence.** Do not backfill empty weeks with weaker material to hit a cadence target. Filler depresses the reach of the posts that matter. **If nothing clears the filter, skip the week.** An empty slot costs nothing; a 250-impression architecture post costs reach on the next real one.

**To extend past Aug 18, something new has to get written.** See the supply problem above. The blog backlog cannot fill these slots, because the blog backlog is architecture.

---

## Queue copy

### Jul 28 — Letting the Loop Merge  *(Stake + Recipe)*

```
I let my AI agents merge their own work to main, no human review. The first thing I learned is that an autonomous queue rots silently.

Nobody is watching it. That is the whole point. So when a PR falls behind main and can't merge, or an agent marks an issue "done" that never actually landed, or a finished PR sits green and ignored because its review task was never filed, nothing tells you. I found each of these the hard way: a 32-item pile of done-but-unmerged work, a PR that sat ready for a week, a stale test on main that quietly parked every unrelated issue.

Every one of those failures became one of two things.

A line in a policy file, when it was recurring bad judgment. "Autonomous by default, escalate only when risky," ten named risky categories, and the rule I keep coming back to: "I wasn't sure" is not a reason to escalate.

A small script on a timer, when it was recurring silent rot. Eight of them now: a base-drift reconciler, an orphan-PR review filer, a false-Done backstop, a superseded-issue surfacer, an age escalator, and a digest that pings me when something genuinely needs a human.

The rule that keeps the scripts safe: make rot visible, and leave the irreversible call to a person. A wrong cancel loses real work. A wrong surface costs a glance. So the janitors that could act destructively flag and reopen instead.

I used to maintain a queue. Then I decided what went in it. Now I decide how the thing that empties it is allowed to fail.

Full writeup, and the janitor scripts:
https://mattgoodrich.com/posts/letting-the-loop-merge/

#AI #AIAgents #ClaudeCode #SoftwareEngineering #CISO
```

### Aug 4 — Make Mistakes Cheap Before You Let the Agent Run  *(Stake + Recipe)*

```
The first safety change I made for my AI agents was the one that does the least. I aliased rm to trash-put, so a deleted file lands in the trash instead of vanishing. Then I thought about how an agent actually runs a command, and the alias stopped looking like a guardrail.

An alias only lives in an interactive shell. When Claude Code or Codex runs a command it goes through a non-interactive shell that doesn't expand aliases, or calls /bin/rm directly, or writes a script and runs that. The guardrail I set up to feel safer protects me, not the agent.

That is the whole problem: a guardrail the agent can shell around is theater. Real safety on your own machine comes in layers, weakest to strongest.

Make mistakes reversible. A filesystem snapshot before each run (tmutil localsnapshot on macOS, zfs snapshot on Linux) is an undo buffer the agent can't opt out of. Commit to git first; the only work git can't recover is the work you never committed.

Write the rules down, but don't trust them. A rule in CLAUDE.md or AGENTS.md lowers the odds of an honest mistake, because models are good at following clear instructions. But it's cooperation-dependent: the same benchmarks that show 90%+ instruction-following show adherence falling toward a coin flip when instructions conflict, which is exactly what a prompt injection is. I've spent years building hard, verifiable security boundaries, and calling a plain-English sentence a control feels wrong. It should.

Cage the irreversible. This is the layer that holds when the rule doesn't, because the kernel enforces it. Codex sandboxes by default; Claude Code opts in. Run the agent as a non-root user with no reach beyond the repo. Default-deny the network so a poisoned README can't send anything out.

The model is not going to be careful. The plan is to make its worst day a snapshot rollback and a shrug.

Kit (hook, snapshot script, hardened Claude Code + Codex settings):
https://github.com/mgoodric/safe-yolo

Full writeup:
https://mattgoodrich.com/posts/make-mistakes-cheap/

#AI #AIAgents #ClaudeCode #Security #CISO
```

### Aug 11 — The Identity Ladder  *(Recipe — identity-series synthesis)*

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

*(Links to the Identity Spine map, not the hub post. The map is the better destination and it is the Featured #1.)*

### Aug 18 — Collapsing a Pile of Tunnels onto Tailscale  *(Recipe)*

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

## Archive — identity series copy

_The 24 retired identity-series LinkedIn drafts were removed 2026-07-21 to slim this file. They are preserved in git history, and every one of those posts is live and findable on the blog. None are scheduled; do not re-queue the run wholesale. If a single rung ever earns a slot, recover its copy from git._

## Sync log

- 2026-07-21 — **Make Mistakes Cheap queued (Aug 4).** Approved the blog post (publishes 7/22) and slotted its LinkedIn post at Aug 4, right after Letting the Loop Merge, to cap the agent-loop trilogy (two-systems 7/21 → LLTM 7/28 → this 8/4) while the theme is fresh. It clears **Stake + Recipe**: the "the rm you alias isn't the rm the agent runs" reversal, the security-veteran discomfort at plain-English controls, plus a public kit (github.com/mgoodric/safe-yolo). Cascaded the Recipe posts back a week: Identity Ladder → Aug 11, Collapsing → Aug 18, Pasting → Aug 25, OPEN → Sep 1+. Copy drafted, payload in-feed.

- 2026-07-21 — **Letting the Loop Merge finalized; archive cleared; queue reconciled.** Blog post approved and re-stamped to today (7/21); added a series backlink to two-systems. Drafted its LinkedIn copy and slotted it **Jul 28** (Stake + Recipe). **Cleared the 24-post retired identity-series archive** (preserved in git history; every one of those posts is live on the blog). Reconciled the badly-drifted queue against what Matt confirmed actually ran: only **Two Systems (7/21)** and the **greenfield-IAM hub (~a week earlier)** posted. **Collapsing Tunnels and The Identity Ladder never ran** — both restored to the queue (Aug 11 and Aug 4), their copy re-added, Pasting Screenshots bumped to Aug 18. The greenfield-IAM hub stays at its recorded 7/9 (Thu) slot — 12 days back, which LinkedIn shows as "1w"; Matt can't pin the exact date from the app (posts T/R only), and 7/9 is consistent. So nothing ran between the hub and Two Systems: Jul 14 was skipped.
- 2026-07-20 — **Two Systems published and promoted up.** Blog post `two-systems-for-handing-work-to-agents` finalized and pushed live (date re-stamped to now per Matt). Swapped it into the Jul 21 LinkedIn slot ahead of The Identity Ladder — it is the one genuine stake/confession in the pipeline (the reason the strategy exists), so it takes the next slot rather than waiting until Jul 28. Clean single swap: Identity Ladder → Jul 28, Aug 4 (Pasting Screenshots) unchanged, no cascade. Copy was already drafted and was re-checked line-by-line against the final post (four features, six Meross issues, 47-commit branch, 17 stranded items, five rules) — accurate, no edits needed. Also this session: published the Open Engine autonomy policy + to-engine/break-to-engine skills to the public plane-client repo (redacted) and linked them from the post; added four themed mermaid diagrams.
- 2026-07-13 — **Identity Spine published.** Page went live at `/page/identity/`. Fixed it first: it was 2 posts stale (drawn 6/09, missing `whose-request-is-this-three-hops-in` and `authorization-is-three-decisions-not-one`). Added both to the table, updated the Product authorization thread, regenerated both mermaid diagrams (26 → 28 nodes), corrected the alt text. Promoted it to Featured #1 and repointed the Jul 21 LinkedIn copy at the map instead of the hub.
- 2026-07-13 — **Strategy reset on the data.** Pulled LinkedIn creator analytics + read exact per-post impressions off the activity feed. Trailing 90 days: 14,371 impressions across 26 posts, 18 blog clicks, and every architecture post under 600. Then the decisive datapoint, from Matt: **`I Was Wrong About AI` (~Sept 2025) did 14,000+ impressions on its own — matching the entire last quarter combined.** Conclusion: the winning shape is the public reversal, and the real constraint is *supply*, not selection. The blog is full of architecture and nearly empty of confessions. Actions: cadence cut 2/week → 1/week Tuesday; added the stake/recipe/career filter with Stake named as primary; **named the supply problem explicitly and listed four unwritten reversal seeds**; retired the 24-post identity backlog into one synthesis post (Jul 21, The Identity Ladder); rebuilt the queue to 4 honest slots (Jul 14 → Aug 4) and left Aug 11+ deliberately empty rather than backfilling with architecture; added the "deliver the payload in-feed, the link is a footnote" rule; corrected all impressions to exact figures; caught one untracked post (Org Chart, 305); revised Featured to pin the two proven performers. Dropped as already-run: I Was Wrong About AI, The Perfect Storm, 1Password SSH Agent. Parked drafts excluded from planning per Matt (may never ship). All 24 retired identity drafts preserved in the archive below.
- 2026-06-09 — Created. Recorded the 8 scheduled posts (Jun 11 – Jul 7) with copy mirrored. Drafted the identity-series backlog: 25 posts, Jul 9 → Oct 1, 2/week Tue/Thu.
- 2026-06-09 — Reformatted all copy into fenced code blocks for clean copy/paste. Applied STYLE.md to LinkedIn: fixed ~6 §5B reframes / a "not just" in the drafts; flagged + corrected 3 scheduled posts (2 em-dashes → colons, 1 rhetorical question → statement). Those 3 need re-copying into the LinkedIn scheduler to match. Normalized the 8 lnkd.in links to canonical mattgoodrich.com URLs.
- 2026-06-09 — Jul 9 (the hub, IAM for the Company You Have) scheduled in LinkedIn. ✅
