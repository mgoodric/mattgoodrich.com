---
name: draft-post
description: Turn an idea into a draft Hugo post for mattgoodrich.com — generates the post directory, frontmatter, body draft in Matt's voice (per STYLE.md), and a header image matching the site's editorial illustration aesthetic. USE WHEN draft post, new post, create post, scaffold post, start a post, blog draft, /draft-post.
---

# draft-post

End-to-end scaffolding for a new Hugo post on mattgoodrich.com. Takes an idea, returns a complete draft (directory + frontmatter + body + header art) ready for Matt to iterate on. **Draft only — never publishes, never commits.**

## Inputs

- **The idea.** One sentence to several paragraphs. Examples: *"post about workload identity as the layer above secret management"*, *"the broker pattern between 1Password vault scoping and pure workload identity"*, *"what I changed my mind about with AI governance after a year"*.
- **Optional context.** Audience, angle, length target, specific framings to preserve.

## Outputs

- `content/posts/{slug}/index.md` — frontmatter + body draft (`draft = true`)
- `content/posts/{slug}/header.png` — header image matching the site aesthetic
- A status report listing path, title, dek, word count, build status

## Workflow

### Step 1 — Capture the idea

Read what Matt provided. Apply the **restate-in-one-sentence test**: regardless of input length, can you restate the post's argument in one sentence? If no, ask up to 2 short clarifying questions (audience, angle, format) until you can. Do not generate anything until you can pass that test.

### Step 2 — Read context (mandatory, every invocation)

Read these files at runtime (don't rely on training memory — Matt edits them):

1. `STYLE.md` at repo root — voice, openings, headers, words-to-avoid, length targets
2. Frontmatter + first 30 lines of the 3 most recent posts in `content/posts/` (sort by `date` in frontmatter) — calibrate current tone, tag vocabulary, dek shape

Run `ls content/posts/` to know what slugs already exist.

### Step 3 — Propose title, slug, dek — get approval (gate)

Output **exactly this shape** and stop for Matt's response. Do not proceed to Step 4 without his approval:

```
Concept: [one-sentence restatement of the post's argument, in Matt's voice]

STYLE.md last-modified: [date from `ls -l STYLE.md`]
Recent posts read: [3 slugs]

Title options (recommended first):
1. [Title A] — [one-line why]
2. [Title B] — [one-line why]
3. [Title C] — [one-line why]

Slug (from recommended title): {kebab-case-slug}
  collides with existing post? yes / no (checked against content/posts/)

Dek (description, 2-3 declarative sentences, matches post register per STYLE.md):
"[…]"

Categories (proposed, single-quoted TOML strings): ['Security', 'AI']
Tags (proposed, single-quoted TOML strings): ['AI', 'Identity', '…']

Proposed publish date: {next Mon–Fri slot after the queue tail}, 00:01 Pacific
  queue tail right now: {latest active-queue date} ({slug})
  earlier-fit option (only if this clusters with queued posts): inject at {date}, ahead of {slug} — {one-line reason}; cascades {N} later posts back one weekday. Default is append-to-tail.

Approve to proceed to body draft + art generation? Or change the title/slug/dek/categories/tags/date first?
```

**Why this gate:** Art generation is expensive; frontmatter is the post's contract. Settle them before continuing.

### Step 4 — Draft the body

After approval, draft the body in Matt's voice. **Apply STYLE.md.**

In the output, prefix the body with a labeled banner so the choices are explicit:

```
Opening shape: [personal hook | quoted dialogue | bold lead claim]   ← pick ONE; mixing is a failure mode
Named dichotomy or concept this post coins/uses: [...]
Honest-tradeoff section will be: [section header]
Closing landing sentence: [one line]
Word-count target: [X]–[Y] (per STYLE.md register)
```

Then the body. Constraints:

- Section headers are **claims or named concepts** — never "Background", "Introduction", "Overview"
- Aim for a named dichotomy or named concept readers can carry away (Matt's posts always have one)
- At least one section argues against the post's own thesis (honest tradeoff)
- Closing lands; no rhetorical question; no marketing vocab (`leverage` / `unlock` / `harness` / `journey` / `embrace`)
- Length range by register:
  - Technical deep-dive: as long as the subject demands; no upper bound
  - Thought piece: 2,200–2,500 typical; flag if under ~1,500
  - Hybrid (workspace/code-attribution register): 1,000–1,500 fine

### Step 4.5 — Self-audit (mandatory, blocking)

Before continuing to Step 5, output this audit block. If anything fails, fix and re-audit:

```
Words-to-avoid scan:    [clean | found and replaced: leverage→use, unlock→...]
"Not just X — it's Y":  [absent | found at line N, rewritten]
Three-part rhythm in titles/claims: [absent | found, reduced to two]
Rhetorical question in closing:     [absent | found, rewritten]
Em-dash density:        [acceptable | one paragraph has >1 where comma works, fixed]
Opening shape consistent (not mixed): [yes]
Named dichotomy present: [yes / explicitly chose not to, reason: ...]
Honest-tradeoff section present: [yes, section: "..."]
```

### Step 5 — Generate the header image

Invoke the **Media skill** for the header. Use this style brief **verbatim**, plus a one-sentence concept tied to this post:

> **Style brief — Matt Goodrich blog header (consistency across all posts):**
>
> Editorial illustration in the register of Atlantic / New Yorker / Stratechery essay art. Ink and marker line work over watercolor splash washes. Cream/off-white textured paper background — NOT pure white, slight warm tone. Color palette: deep purple/violet as dominant accent, warm orange/amber as secondary accent, charcoal/black line work for form. Visible paint splatters and soft drips for organic texture. Wide cinema aspect ratio (16:9 or slightly wider). Centered or symmetric composition. Subject matter is **metaphorical** — depicts the post's concept through objects, technology motifs, or abstract forms — not literal scenes, no text inside the image. **No human faces or full human figures. Mechanical / robotic objects ARE fine** (e.g., a robotic hand reaching for a vault is on-brand). Tone: thoughtful, slightly playful, intellectually serious. Hand-drawn feel, not photo-real, not 3D render, not flat vector.

Concept-line examples (for shape, don't copy):
- 1Password post: *"A weathered vault box with a robotic hand reaching for its dials, next to an open book."*
- AI Governance post: *"Concentric architectural rings forming a quiet, ordered amphitheatre at the center, splashed with purple paint."*
- Agents Don't Travel Well post: *"A workshop wall of glowing monitors over a desk, all wired into one quiet workstation."*

**Verify Media result before continuing:**

- File exists at `content/posts/{slug}/header.png`
- Aspect ratio is 16:9 (±10%)
- Image is non-zero size and parseable

On any verification failure, **stop** — surface the error and do NOT write `index.md`. Better to ship no scaffolding than scaffolding with a missing or wrong-aspect header.

### Step 6 — Scaffold the post directory

**Date handling — schedule into the publish queue:**

New posts are future-dated into the publish queue and kept `draft = true`. A future date plus `draft = true` is held by Hugo on both counts, so the post will not go live until Matt both approves it (`draft = false`, via approve-post) and the date arrives. The future date is deliberate here, which is different from the 2026-05-14 gotcha (that was a post meant to publish *now* that got held by an accidental future stamp; here being held is the point).

Compute the slot once (propose it in Step 3, write it in the frontmatter here):

1. Build the active queue: every post not yet published (`draft = true`, or `date` in the future), sorted by `date`. Exclude far-future parking sentinels (the `2026-12-31` placeholders are not real slots; drop anything dated more than ~60 days out).
2. The tail is the latest active-queue date.
3. Default date = the next weekday (Mon–Fri) strictly after the tail, at `T00:01:00-07:00` (just after midnight Pacific). The time matters: the publish cron runs in the early morning, so a post timestamped noon is still "future" at that run and goes live the morning *after* its date. Anchoring at 00:01, before the cron, makes a post dated 6/X publish on 6/X. Roll a Sat/Sun result forward to Monday. If the queue is empty, use the next weekday from today.

This matches the cadence the existing schedule and approve-post follow: one post per weekday, weekends skipped.

```bash
# latest active-queue date (ignoring 12/31 sentinels)
tail=$(for d in content/posts/*/index.md; do
  dt=$(grep -m1 '^date' "$d" | sed "s/.*= *'//;s/'.*//" | cut -dT -f1)
  awk -v x="$dt" 'BEGIN{ if (x < "2026-12-01") print x }'
done | sort | tail -1)
# next Mon–Fri after the tail:
n="$tail"
while :; do n=$(date -j -v+1d -f %Y-%m-%d "$n" +%Y-%m-%d); \
  dow=$(date -j -f %Y-%m-%d "$n" +%u); [ "$dow" -le 5 ] && break; done
echo "$n"   # -> use as ${n}T00:01:00-07:00
```

If the post clusters with posts already in the queue (shared thread, tags, or cross-links), you may **suggest** an earlier injection slot in Step 3, naming the slot, the one-line reason, and that injecting cascades the later posts back one weekday. Injecting is a reschedule Matt opts into; never cascade dates automatically. Default is append-to-tail.

**Write `content/posts/{slug}/index.md` using this template (filled, not placeholders):**

```toml
+++
date = '2026-07-09T00:01:00-07:00'
draft = true
title = "Title With An Apostrophe Needs Double Quotes"
aliases = []
description = "Two to three declarative sentences. Same register as the post. No marketing vocab."
categories = ['Security', 'AI']
tags = ['AI', 'Identity', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

{body draft from Step 4, post-audit}
```

**TOML rules to enforce:**
- `categories` and `tags` are arrays of **single-quoted strings**, comma-separated. `['Security', 'AI']` is valid; `[Security, AI]` is not.
- `title` uses single quotes unless the title contains an apostrophe — then double quotes.
- `aliases = []` always emitted (intentionally empty; reserved for slug-change redirects, see Iteration Hooks).
- `description` uses double quotes (deks routinely contain apostrophes and em-dashes).

### Step 7 — Build verify

Run `hugo -D --quiet` from the repo root.

Pass criteria:
- Exit code 0
- Either: file at `public/posts/{slug}/index.html` exists, **or** Hugo's build log lists the page as built (theme-routing variation tolerated)

If exit code is non-zero, surface the full error and stop. Common failure causes: TOML quoting error (apostrophe in title needs `"…"`), missing required frontmatter field, slug collision Hugo didn't reject in Step 3.

### Step 8 — Report

Output:

```
✅ Draft post scaffolded

Path:        content/posts/{slug}/
Title:       {title}
Dek:         {dek}
Word count:  {N}
Opening shape: {shape}
Named concept: {dichotomy or "none, deliberate"}
Header art:  content/posts/{slug}/header.png  (16:9, {file size})
Status:      draft = true
Date:        {scheduled date}  (queue slot: next weekday after {tail}; held until you approve it)
Build:       passed (hugo -D)

Next steps Matt typically takes:
- Read the body, edit toward final voice
- Iterate the header art if it doesn't land ("redo the header with concept: …")
- When ready to publish: run /approve-post (flips draft to false, keeps the scheduled date, commits locally)
```

## Hard rules

- **Never set `draft = false`.** Publishing is Matt's deliberate decision in a separate step.
- **Future-date into the publish queue, keep `draft = true`.** Pick the next free weekday slot after the queue tail (Step 6); don't re-use today as a placeholder when posts are already lined up. The future date is safe because `draft = true` holds the post until approve-post flips it.
- **Never duplicate STYLE.md content** into the post itself. Read it; reference it; apply it.
- **Never auto-commit or push.** This skill creates files only.
- **Never overwrite an existing post directory.** Slug collision → surface in Step 3, propose alternatives.
- **Never generate the header before title + dek are approved.** Art is expensive.
- **Never include readable text, human faces, or full human figures in the generated header image.** Mechanical/robotic objects are fine.

## Iteration hooks

If Matt comes back asking for a redo of one part, keep state across iterations — don't regenerate parts he didn't ask to change:

- **"Redraft the body"** → repeat Steps 4 + 4.5 with optional new direction; reuse approved frontmatter + art
- **"Redo the header"** → repeat Step 5 with a new concept line; reuse frontmatter + body
- **"Different title or dek"** → repeat Step 3
  - If the **slug changes** as a result:
    1. `git mv content/posts/{old-slug}/ content/posts/{new-slug}/` (preserves both `index.md` and `header.png`)
    2. Add the old path to `aliases` in the frontmatter so any links survive: `aliases = ['/posts/{old-slug}/']`
    3. Re-run Step 7 build verify
- **"Make it shorter / longer / sharper"** → focused revision of body only; re-run Step 4.5 self-audit afterward
