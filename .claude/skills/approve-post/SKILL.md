---
name: approve-post
description: Finalize a drafted Hugo post on mattgoodrich.com — style-guide review and fixes, link verification, flip draft = false (keeping the scheduled date), build-verify, and commit locally. Never pushes. USE WHEN approve post, finalize post, flip the draft bit, publish-schedule, ready to commit a post, do a final review and commit, /approve-post.
---

# approve-post

Takes a post that draft-post scaffolded and Matt has edited to final voice, and does the finalize ritual: review against STYLE.md, fix what's safe, verify links, flip `draft = false` while **keeping the post's scheduled future date**, build-verify, and commit locally. **Never pushes.** Publishing happens later when Matt pushes and the date arrives.

This is the counterpart to `draft-post`. draft-post creates; approve-post finalizes.

## Why "approve" is not "publish now"

Matt's posts are scheduled: a future `date` plus `draft = false`, pushed to the remote, auto-publishes on that date via the daily cron (`hugo` skips future-dated and draft posts until both conditions clear). So approving a post means **flip the bit and keep the schedule**, not re-stamp the date to now. Re-stamping would either publish immediately or break the intended order. Confirmed by history: finalized posts kept their future dates (MFA stayed 6/22, SPIFFE 6/12) with `draft = false`.

## Inputs

- **A slug or title fragment** (e.g. `trust-the-user-then-the-machine`, or `device trust`). If omitted, operate on the **most-recently-edited `draft = true` post** under `content/posts/` and name it in the report so Matt can correct.

## Outputs

- The post's `index.md` with `draft = false`, mechanical style fixes applied, **date unchanged**
- A local commit containing **only** that post's directory (never a push)
- A status report: fixes applied, items flagged for Matt's judgment, link results, build status, commit hash, and the explicit "not pushed" reminder

## Workflow

### Step 1 — Resolve the post

Resolve the slug/fragment to exactly one `content/posts/<slug>/index.md`. If the fragment matches more than one, list the matches and ask which. If it's already `draft = false`, say so and switch to a no-op/clean-up path (Step 7 handles "already approved").

Read **STYLE.md at the repo root** (don't rely on memory — Matt edits it) and the full post.

### Step 2 — Style review (fix mechanical, flag judgment)

Run the STYLE.md audit. Apply the **fix-mechanical / flag-judgment** split:

**Auto-fix (unambiguous, no meaning change):**
- Words-to-avoid from STYLE.md, including `leverage`, `unlock`, `harness`, `seamless`, `bolted`, `journey`, `embrace`, and **"earns its keep" / "pays for itself"** — replace with the plain alternative the sentence wants. (Exception, leave intact: the deliberate "earns its keep at the boundary" coinage in the published MCP/agent-protocol posts.)
- Em-dash density over the "sparingly" rule — recast with commas/periods where a comma carries it.
- A rhetorical question in the closing — rewrite as a statement.
- "Not just X / not only X" constructions — recast positively.

**Flag, do NOT silently rewrite (Matt cares about specific lines):**
- §5B "is not X. It is Y." reframes — list each with a suggested positive-lead rewrite.
- Three-part rhythm in titles or claims — flag, suggest reducing to two.
- Mixed opening shape, dek register problems, named-dichotomy gaps, or any restructure that changes meaning.
- Anything touching a quotation or a passage that reads as Matt's own words — never edit user content; flag only.

Output a compact audit block (what was fixed, what is flagged with line numbers).

### Step 3 — Verify links

- **External:** extract every `https?://` URL; `curl -sIL -o /dev/null -w "%{http_code}"` each. Non-200 → **warn** in the report (some sites 403 a bot; Matt eyeballs these). Do not block on external.
- **Internal:** for every `/posts/<target-slug>/` link, confirm `content/posts/<target-slug>/` exists, and compare the target's `date` to this post's `date`. A link to a post that publishes **after** this one is a forward reference that will 404 at render time. A link to a non-existent slug is broken. **Either of these BLOCKS the commit** (Step 6) — report it and stop, consistent with the de-link discipline. Matt either de-links it or reschedules.

### Step 3.5 — Recommend release-order fit

Look at whether this post sits in the right place in the release calendar, and recommend moving it **earlier** if it fits more naturally sooner. approve-post **recommends only** — it never reschedules on its own, because reordering is a bulk, cross-post judgment Matt makes.

Build the mutable calendar: every post that is **not yet published** (`draft = true`, or `date` in the future), sorted by `date`. Only these can move; already-published posts are fixed and are never suggested for a move.

Two signals:

1. **Dependency.** Find every not-yet-published post that links to the one being approved (`grep -rl "/posts/<approved-slug>/" content/posts/*/index.md`). For each referrer, what matters is whether it will actually go live before this post:
   - **Blocking:** the referrer is `draft = false` (genuinely scheduled) with a `date` on or before this post's `date`. It will render a link that 404s before this post exists. **Stop the commit** the same way Step 3 does: recommend moving the approved post to publish before its earliest such referrer (give the date), or de-linking the referrer.
   - **Advisory only:** the referrer is `draft = true` (unscheduled, or sitting at a placeholder/today date). It cannot 404 the live site because it is not publishing. Note it so its outbound link gets checked when that post is itself approved, but do not block on it.

2. **Narrative fit (advisory).** Using the spine's natural order (hub → building the ladder → zero trust → workload and machine → running it → product authorization → synthesis) and the post's cross-links, judge whether it reads better earlier than its current slot. If yes, recommend a **concrete** move: the proposed earlier date or a swap with the specific post in that slot, plus a one-line reason ("a foundational ladder rung that three later posts already assume"). If the slot is right, say so in one line. This is advisory — surface it, then continue to flip, build, and commit.

Keep it concrete and minimal: name the posts and dates, propose the smallest shift that fixes the fit (a single swap beats a full reshuffle), and offer to apply the reschedule as a separate step if Matt approves.

### Step 4 — Flip the bit, keep the date

Set `draft = true` → `draft = false`. **Do not change `date`.** If `date` is already in the past, note it (it will publish on the next cron run) but do not alter it. Leave all other frontmatter as-is.

### Step 5 — Build verify

Build to a throwaway output dir so stale `public/` files never mask the result. Run two builds:
- `hugo --quiet --cleanDestinationDir -d /tmp/approve-plain` — the production build. A future-dated, non-draft post is correctly **held** (absent from the output); that is expected, not a failure. This confirms nothing else broke.
- `hugo -F --quiet --cleanDestinationDir -d /tmp/approve-future` — `--buildFuture` forces the post to render so you can confirm it and its assets build clean: `posts/<slug>/index.html` present and any diagrams copied.

Mind the Hugo flag semantics: `-D` adds **drafts**, `-F` / `--buildFuture` adds **future-dated** content. An approved post is `draft = false` and usually future-dated, so `-D` alone will NOT render it (future-exclusion still applies) — don't expect a future-dated post under plain `hugo` or `hugo -D`. Use `-F` for the render check.

Pass = exit 0 on both, and the page present under `-F`. On any non-zero exit, or a missing page under `-F`: **abort before committing.** Leave the working-tree changes in place, surface the full error, and stop. Better to leave it uncommitted than to commit a broken build.

### Step 6 — Commit (automatic), never push

Stage **only** the post's directory:

```bash
git add content/posts/<slug>/
```

Never `git add -A`, never `git add -u`, never stage `.claude/`, other posts, STYLE.md, or unrelated drafts. If those need committing, that's a separate, explicit action.

Pick the message by whether the post was already tracked (`git ls-files --error-unmatch content/posts/<slug>/index.md`):
- **Untracked** (brand-new post dir): subject `New post: <Title> (M/D)`
- **Tracked** (flipping a committed draft): subject `Set <slug> to publish on <Month Day>`

Body: 2–4 lines — the style fixes applied, links verified, and the schedule (publishes <date>). End with a blank line and the trailer:

```
Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

Commit if and only if: style step left no unresolved **blocking** issue, internal links passed (Step 3), and the build passed (Step 5). Per Matt's setting, do not pause for confirmation when those hold — commit. **Do not push.**

### Step 7 — Report

```
✅ Approved (committed locally, not pushed)

Post:        content/posts/<slug>/   "<Title>"
Schedule:    draft = false, date <date> (publishes <date>; KEPT, not re-stamped)
Style fixes: [mechanical fixes applied, or "none needed"]
Flagged:     [judgment items for Matt, with line numbers — or "none"]
Links:       internal <n> ok; external <n> ok[, <m> flagged: …]
Release order: [fits current slot | recommend moving to <date> / swap with <slug> — <one-line reason>]
Build:       hugo (held, future-dated) + hugo -D — both passed
Commit:      <hash> "<subject>"

Not pushed. Run `git push origin <branch>` when you're ready, or batch with others.
```

If the run **stopped** instead of committing (blocking link or build failure, or `draft` was already false), report exactly what blocked and what's needed, with nothing committed.

## Hard rules

- **Never push.** Commit locally only. Pushing is Matt's deliberate, separate step.
- **Never re-stamp the scheduled date.** Approve keeps the future date; only the draft bit flips.
- **Recommend reordering; never reschedule.** Step 3.5 may suggest moving this or other not-yet-published posts earlier, but editing any post's date is a separate, explicit action Matt approves. The one exception that blocks (not reschedules) is an inbound forward reference.
- **Never `git add -A` / `-u`.** Stage only `content/posts/<slug>/`. Keep `.claude/`, STYLE.md, and other drafts out of the commit.
- **Never silently rewrite Matt's prose for judgment-level style issues.** Fix mechanical, flag the rest.
- **Never edit a quotation or user-written passage.** Flag only.
- **Abort without committing** on a build failure, a broken internal link, or a forward-reference internal link.
- **Read STYLE.md at runtime** every invocation; never hardcode its contents here.

## Iteration hooks

- **"Re-run approve-post"** after Matt resolves flagged items → repeat from Step 2; skip fixes already applied.
- **A flagged forward reference** → offer to de-link it (replace the `[text](/posts/later-slug/)` with plain `text`) or note that rescheduling this post later than the target also fixes it; Matt picks, then re-run.
- **Already `draft = false` but with uncommitted edits** → run the style review + link check + build, then commit with the `Set <slug> …` message. Don't re-flip anything.
- **Accept a reorder recommendation** → as a separate step after Matt approves, apply the smallest set of frontmatter `date` edits (a swap, or move this post earlier and bump the displaced ones), keep every post's `draft` state, then re-run the forward-reference checks (Step 3 and Step 3.5) across the affected posts to confirm no link now resolves out of order.
