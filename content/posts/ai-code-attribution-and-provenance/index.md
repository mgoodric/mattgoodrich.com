+++
date = '2026-06-06T12:00:00-07:00'
draft = false
title = 'Who Wrote This Code? A Layered Approach to AI Attribution and Provenance'
aliases = []
description = "AI writes a growing share of the code in every repo, and almost no team can say which lines came from a model or who is accountable for them. That gap turns expensive the moment IP changes hands, a security review needs prioritizing, or an auditor asks. Most of the fix is attribution you can build from git metadata you already have."
categories = ['Security', 'AI', 'Engineering', 'Leadership']
tags = ['AI', 'AI Governance', 'Security', 'Code Attribution', 'Provenance', 'Git', 'CISO', 'Engineering', 'Compliance', 'IP', 'Copyright']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

A simple question that most engineering organizations can't answer: **which code in our repos was written by AI, which was written by humans, and who is accountable for each?**

It sounds like the kind of thing you'd just know. In practice, almost no one knows. AI tooling is rolling out across teams faster than the governance stack can keep up. Each tool has different attribution behavior: some attribute by default, most don't. Almost no one is writing this down at the commit level. And the moment a customer, an auditor, or a court asks the question, the answer is a shrug.

This is the architecture I'd recommend, the working git hooks for the layers you can roll out today, and an honest accounting of what this approach doesn't solve.

## Why Attribution Matters (Supposedly)

Four domains care about the answer to "who wrote this?", and they care for different reasons.

**Intellectual property.** The U.S. Copyright Office has held that works created entirely by AI are not copyrightable. Authors must "identify and disclaim AI-generated parts" to protect what humans authored. Without attribution, you cannot accurately represent ownership of your codebase, which becomes a problem the moment IP changes hands, gets licensed, or ends up in court.

**Security.** [Veracode's 2025 GenAI Code Security Report](https://www.veracode.com/resources/analyst-reports/2025-genai-code-security-report/) found that 45% of AI-generated code samples contained a security flaw, including OWASP Top 10 vulnerabilities, across more than 100 models, and that newer and larger models were no safer. On secrets, [GitGuardian's 2025 State of Secrets Sprawl](https://www.gitguardian.com/state-of-secrets-sprawl-report-2025) found public repositories with GitHub Copilot active leaked secrets at 6.4%, against a 4.6% baseline. Whether or not those numbers hold for your codebase, the implication is the same: you can't prioritize security review for AI-authored code if you can't find AI-authored code.

**Regulatory compliance.** EU AI Act enforcement begins August 2026. The Act requires machine-readable disclosure on AI-generated content. Whether source code is in scope is ambiguous, but the prudent posture is to treat it as covered, because the compliance cost of being wrong is much higher than the cost of attribution.

**Audit readiness.** SOC 2, ISO 27001, and customer due-diligence reviews are starting to ask about AI usage in codebases. You want to answer those questions with data, not estimates. "We don't know" is not a competitive answer in a vendor security questionnaire.

## The Attribution Spectrum

The first thing to get past is the binary mental model. "AI-written" vs "human-written" is not a coin flip. Code authorship lives on a spectrum:

| Level | Description | Example |
|-------|-------------|---------|
| Autonomous | AI agent writes and commits with no human editing | A coding agent generates a module from a ticket and pushes |
| AI-Primary | Human prompts, AI generates, human accepts verbatim | Developer describes a function, accepts the suggestion as-is |
| Collaborative | Human and AI alternate edits within the same unit | Pair-programming with an inline assistant, each contributing lines |
| AI-Assisted | Human writes, AI provides completions or suggestions inline | Accepting a 3-line autocomplete |
| AI-Informed | Human writes independently with AI as a reference | Asking Claude about an API while writing the code yourself |
| Human-Only | No AI involvement | Traditional development |

Any attribution architecture has to handle this whole spectrum. A system that only records "did AI touch this commit?" gives you a single dirty bit. A system that captures *degree* of AI involvement gives you something you can actually act on.

## The Tooling Reality

Here's where the gap shows up: most AI coding tools do not self-attribute by default.

| Tool | Auto-Attributes? | Method | Gap |
|------|-----------------|--------|-----|
| **Claude Code** | Yes | `Co-Authored-By` trailer on every commit | No line-level granularity |
| **Aider** | Yes | `(aider)` in author name + model co-author | Non-standard format |
| **OpenAI Codex CLI** | Configurable | Optional `Co-Authored-By` via prepare-commit-msg hook | Off by default; some subcommands emit no telemetry |
| **GitHub Copilot** | No | None at the commit level | Aggregate metrics API only |
| **Cursor** | No | None at the commit level | Per-acceptance only at Enterprise tier |
| **Gemini Code Assist** | No | None at the commit level | Invisible at commit level |

The takeaway: if you want commit-level attribution, you have to enforce it through git conventions and hooks. You cannot rely on the tooling to do it for you, because most of the tooling won't.

## A Layered Attribution Architecture

The right shape here is layered. Each layer is independently valuable. You don't need a "big bang" rollout. You start with Layer 1 today and layer the rest in when you're ready.

### Layer 1: Git Commit Attribution

**Mechanism:** standardize git commit metadata.

For autonomous AI commits, set the author to a non-human identity:

```bash
git commit --author="ai-agent <ai@example.com>"
# The committer remains the human; git preserves both fields
```

For AI-assisted human commits, require a `Co-Authored-By` trailer in the message body:

```
Refactor pricing module to use new cache layer.

Co-Authored-By: Claude Code <noreply@anthropic.com>
Signed-off-by: Jane Doe <jane@example.com>
```

A `prepare-commit-msg` hook auto-adds the trailer when an `AI_TOOL` environment variable is set:

```bash
#!/usr/bin/env bash
# .githooks/prepare-commit-msg
COMMIT_MSG_FILE="$1"

if [[ -n "${AI_TOOL:-}" ]]; then
    if ! grep -qF "Co-Authored-By: ${AI_TOOL}" "$COMMIT_MSG_FILE"; then
        printf "\nCo-Authored-By: %s\n" "$AI_TOOL" >> "$COMMIT_MSG_FILE"
    fi
fi
```

The immediate payoff is queryability. From the moment this hook is in place:

```bash
# All commits where an AI tool was a co-author
git log --all --grep="Co-Authored-By:" --pretty=format:"%h %an %s"

# Commits authored entirely by an autonomous agent
git log --all --author="ai-agent" --pretty=format:"%h %an %s"

# Per-author counts (humans + named AI agents)
git shortlog -sne --all
```

That's an enormous step up from "we don't know." It costs nothing. It runs in any git repo. And it works whether or not your AI tooling cooperates.

The accountability piece sits next to this: every AI-authored PR has a named human sponsor who accepts responsibility for review and correctness. This is the same pattern most organizations already use for vendor-contributed or contractor code.

### Layer 2: Responsibility Classification (RAI Footers)

Layer 1 captures presence/absence. Layer 2 captures *degree*.

The convention I'd use is RAI footers: three trailers that distinguish how much of the commit is AI-generated, paired with a `Signed-off-by` to keep a human accountable:

```
Assisted-by: Copilot           # AI helped with suggestions (~up to 33% generated)
Co-authored-by: Claude Code    # Substantial AI contribution (35–67%)
Generated-by: Claude Code      # Primarily AI-generated (67%+)
Signed-off-by: jdoe            # Human takes responsibility
```

A `commit-msg` hook enforces the dual-attestation:

```bash
#!/usr/bin/env bash
# .githooks/commit-msg
COMMIT_MSG_FILE="$1"

if grep -qE "^(Assisted-by|Co-authored-by|Generated-by):" "$COMMIT_MSG_FILE"; then
    if ! grep -qE "^Signed-off-by:" "$COMMIT_MSG_FILE"; then
        echo "ERROR: AI attribution trailer present, but no Signed-off-by." >&2
        echo "       Re-run with: git commit -s" >&2
        exit 1
    fi
fi
```

A small reporting script summarizes the AI footprint for a repo:

```bash
#!/usr/bin/env bash
# bin/ai-attribution-stats.sh
RANGE="${1:-HEAD~1000..HEAD}"
total=$(git log "$RANGE" --oneline | wc -l | tr -d ' ')
assisted=$(git log "$RANGE" --grep="^Assisted-by:" --oneline | wc -l | tr -d ' ')
coauth=$(git log "$RANGE" --grep="^Co-authored-by:" --oneline | wc -l | tr -d ' ')
generated=$(git log "$RANGE" --grep="^Generated-by:" --oneline | wc -l | tr -d ' ')
ai_total=$((assisted + coauth + generated))

printf "AI Attribution Report\n"
printf "  Total commits:    %s\n" "$total"
printf "  Assisted-by:      %s\n" "$assisted"
printf "  Co-authored-by:   %s\n" "$coauth"
printf "  Generated-by:     %s\n" "$generated"
printf "  AI percentage:    %s%%\n" "$((ai_total * 100 / total))"
```

What this gives you: degree-of-AI-involvement per commit, plus dual-attestation. Commit-level dashboards become possible. "What percentage of commits in this service are `Generated-by` vs `Assisted-by`?" goes from a guess to a query.

The honest limitation is self-reporting. The hook can enforce that *some* classification is present when an AI tool is named. It cannot verify the percentage split is accurate. That's a discipline question, not a tooling question.

### Layer 3: Line-Level Provenance

Commit-level is coarse. A commit that's 60% AI-assisted contains specific lines an AI wrote and specific lines a human wrote, and Layers 1 and 2 give you no way to tell them apart.

For that, look at [`git-ai`](https://github.com/git-ai-project/git-ai). It uses Git Notes (`refs/notes/ai`) to attach metadata to commits without modifying commit history, supports a growing list of agents including Claude Code, Copilot, Cursor, and Windsurf, and is listed on Thoughtworks Technology Radar. The format is an open standard.

What it answers that Layers 1–2 cannot:

- Exact percentage of a file or module that was AI-generated
- Security review prioritization based on AI-authored line density
- Function-level IP risk assessment
- Compliance evidence at line granularity

[`whogitit`](https://github.com/dotsetlabs/whogitit) is a similar tool with automatic redaction for sensitive prompt content, worth evaluating if prompt privacy is a concern.

The trade-off is operational complexity. Git Notes are powerful but they require the agents to call into them at commit time, and they require everyone working on the repo to fetch the notes namespace. Layer 3 is where the investment starts to look real.

### Layer 4: Telemetry Aggregation

For organizations with enough scale to justify it, aggregate telemetry from multiple AI tools into a unified dashboard:

- **GitHub Copilot Metrics API**: suggestion/acceptance rates by org, team, language, editor
- **Anthropic API consumption**: token usage and model versions per team
- **Cursor Enterprise API**: per-acceptance tracking
- **`git-ai stats`**: line-level aggregates from Layer 3
- **Internal commit metadata**: Layers 1 and 2 data

No off-the-shelf product unifies these today. It's a custom build. The upside is a single pane of glass for AI code footprint across the org; the downside is that you're integrating against four or five different telemetry shapes that weren't designed to compose.

## Rollout Recommendation

| Phase | Layer | Timeline | Owner |
|-------|-------|----------|-------|
| **Phase 1** | Git conventions + hooks | 2–4 weeks | Engineering standards team |
| **Phase 2** | RAI footers + accountability policy | 4–6 weeks | Standards + Legal |
| **Phase 3** | `git-ai` pilot | 1–2 months | 1–2 pilot teams |
| **Phase 4** | Telemetry dashboard | 3–6 months | Platform engineering |

**Phase 1 is the critical path.** Zero tooling investment, immediate queryable data, and it establishes the cultural norm that AI code is attributed code. Everything else builds on this foundation.

## The Standards Landscape

There is no settled industry standard for AI code provenance. The closest thing to one, `git-ai`'s line-level format, is a single-project specification that is gaining traction but has not been ratified by any standards body.

| Standard | Scope | Code Provenance? | Status |
|----------|-------|------------------|--------|
| **C2PA** (v2.2) | Images, video, audio, documents | No | Active, no code working group |
| **AIBOM** | Model provenance (models, datasets, configs) | No (tracks what model built it, not which lines) | Emerging |
| **SLSA 1.2** | Software supply chain artifacts | Build/source provenance, not AI authorship | Active (Linux Foundation) |
| **git-ai v3.0.0** | Line-level AI attribution in git | Yes | Active, single-project spec |
| **EU AI Act** | AI-generated content disclosure | Likely applicable to code (ambiguous) | Enforcement August 2026 |

The space between "sign your commits" and "maintain cryptographic chain-of-custody for every AI-generated patch" is where standards will likely emerge over the next 12–24 months. A layered approach lets you adopt early without rework when standards land.

## Detection as a Backstop (Not a Strategy)

When provenance metadata is missing (legacy code, tools that don't self-attribute), statistical signals can sometimes identify AI-generated code. Structural uniformity, comment-to-code ratio, naming conventions, the absence of typos in comments, lower token perplexity. These are real signals, and they're useful for retroactive analysis of legacy codebases.

They are not a governance strategy. The signals are statistical and they degrade as models improve. By the time you've trained a classifier on this generation of models, the next generation produces code that looks more like what humans write. The lesson is to instrument attribution at write-time, not detect it after the fact.

## The Threshold Nobody Can Draw

Here is the counterargument to all of this, and I think it's a real one.

The attribution spectrum assumes you can draw a line between human and machine authorship. At the commit level you roughly can. At the line level, the line dissolves.

Take a function a developer wrote by hand. An AI assistant changes one character in one line: a `<=` becomes a `<`. Is that line now AI-authored? Is the whole function? If the answer is yes, a single keystroke from a model relabels human work as machine output. If the answer is no, then what is the threshold: ten characters, a whole expression, half the line? Nobody has a principled answer. The Copyright Office said to "identify and disclaim AI-generated parts," but it never defined how large a part has to be before it counts, and no court has either.

Flip it around and it gets worse. A human edits one character of an AI-generated line. Does that keystroke pull the line back into copyrightable human authorship? If a one-character human edit launders AI output into protected IP, then the cheapest way to own your codebase is to have someone retype one character on every line. That is absurd, and the absurdity is the point. The threshold model breaks in both directions.

So a chunk of the IP rationale rests on a line nobody can draw, for a legal fight that may never come. The case law isn't there yet, and it may never get tested at the granularity that would make line-level provenance the deciding evidence. There is a real chance we are building careful chain-of-custody for a courtroom no one ever walks into.

I still think you should instrument attribution. The IP rationale is the shaky one; the other three are not. Security prioritization, compliance posture, and audit answerability all run fine on coarse, commit-level signals. A rough, queryable answer to "how much of this was AI?" is all they need, and that is Layer 1. Layer 1 is cheap. The expensive, line-level, cryptographic chain-of-custody is the part most likely being built for the court case that never comes.

## Open Questions Worth Asking Inside Your Org

This is the section to take into a working group meeting:

1. Which AI tools are officially supported, and what are the attribution behaviors of each?
2. Where does accountability land? The "bot sponsorship" model, where every AI PR has a named human sponsor, is the pattern I'd recommend.
3. What threshold triggers enhanced review? Should `Generated-by` (67%+ AI) commits require additional reviewers or security review?
4. How do you handle the Copilot/Cursor invisibility gap? Mandate manual attribution, or accept the blind spot?
5. Do you need line-level tracking (Layer 3) for compliance, or is commit-level (Layers 1–2) sufficient given your audit posture?

## Companion Code

The three scripts above (`prepare-commit-msg`, `commit-msg`, `ai-attribution-stats.sh`) are the minimum viable Layer 1 + Layer 2 deployment for any team. Drop them into `.githooks/`, run `git config core.hooksPath .githooks`, and you have queryable AI attribution from the next commit forward.

Production-ready versions live at **[github.com/mgoodric/ai-attribution-hooks](https://github.com/mgoodric/ai-attribution-hooks)**, including a one-shot installer and a slightly enhanced `prepare-commit-msg` that also auto-adds `Signed-off-by` so commits clear the dual-attestation check.

```bash
git clone https://github.com/mgoodric/ai-attribution-hooks.git
cd /path/to/your/repo
/path/to/ai-attribution-hooks/install.sh
```

## Someone Has to Set the Standard

You can start with Layer 1 today. The perfect provenance system can wait.

The technical work here is the easy part: it's git hooks. The hard part is the organizational discipline to actually require attribution across teams, to actually enforce the dual-attestation, and to actually treat AI authorship as something that deserves the same accountability as human authorship. That's not a tooling problem.

Attribution is how you keep IP defensible, security review prioritized, and audits answerable with data instead of estimates. The tools don't do this for us. The convention doesn't establish itself. Someone has to set the standard inside the org and stick to it.

---

## References

- [git-ai: Line-level AI attribution](https://github.com/git-ai-project/git-ai) | [How it works](https://usegitai.com)
- [whogitit: AI attribution with Claude Code integration](https://github.com/dotsetlabs/whogitit)
- [botcommits.dev: Tracking AI commits on GitHub](https://botcommits.dev/)
- [RAI Footers for AI-assisted commits](https://dev.to/anchildress1/signing-your-name-on-ai-assisted-commits-with-rai-footers-2b0o)
- [SSW Rules: Attribute AI-assisted commits](https://www.ssw.com.au/rules/attribute-ai-assisted-commits-with-co-authors)
- [The New Git Blame: Who's Responsible When AI Writes Code](https://pullflow.com/blog/the-new-git-blame/)
- [U.S. Copyright Office on AI-generated works](https://www.copyright.gov/ai/)
