# mattgoodrich.com — Writing Style Guide

A working description of Matt's voice, derived from recent 2026 posts (BlackDuck API, Hardest Part of Security, Complicated vs Complex, GRC Engineering, 1Password Service Account for Claude, AI Governance Calibrated, Agents Don't Travel Well). Heaviest weight on the most recent posts. This is a living document — refine it as patterns become clearer or shift.

---

## Voice in one paragraph

First-person, conversational, peer-to-peer. Matt writes the way a senior practitioner talks to other senior practitioners — direct, opinionated, specific, and willing to admit what didn't work. He earns credibility through detail and lived experience, not through hedging or formality. The reader feels like they're being let in on something rather than being lectured to.

---

## Openings

The opening sets the contract. Matt's openings have one of three shapes:

### 1. Personal hook — recent experience or memory
> "The first time I opened the BlackDuck API documentation, I thought building a vulnerability collector would take a couple weeks."

> "The first time I heard the term 'GRC engineering,' I'll be honest — I didn't get it."

> "I recently picked up *Team of Teams* by General Stanley McChrystal, and one concept from the book has been rattling around in my head ever since"

The pattern: a specific moment in his own life, told in past tense, that introduces the topic without explicitly stating "this post is about X."

### 2. Quoted dialogue
> 'A CISO once said to me, "Vulnerability management is easy. It's find, then fix."'

The pattern: someone else said something, and the post is the response.

### 3. Bold lead claim
> "**Like many developers, I hate bloated machines.**"

The pattern: a punchy declarative claim, often bolded, that you immediately want to either agree or argue with.

**What openings never do:**
- Start with "This post is about..." or "In this article..."
- Throat-clear with a list of credentials or context
- Define terms before showing why they matter
- Tease without committing to a position

---

## Description (dek)

The `description` field in frontmatter is the dek — what shows up in feeds, social previews, and search results. It's the post's contract with the reader before they click.

### Rules

- **Length:** 2–3 sentences, roughly 200–350 characters
- **Always declarative**, full sentences (not fragments)
- **Voice matches the post** — same register, same tone

### Three shapes that work

**Thesis statement** — for thought pieces:
> "GRC engineering isn't about making spreadsheets fancier. It's about recognizing that compliance at scale is an engineering problem, and it deserves an engineering solution."

> "Most security programs are designed for complicated problems. But the threat landscape — especially with AI — is complex. It's time for a different playbook."

**Problem + promise** — for argument-driven posts:
> "Security teams are great at finding problems. The real challenge is navigating the messy space between finding and fixing — where competing priorities, misaligned incentives, and invisible debt quietly compound."

**Personal-experience + promise** — for technical deep-dives:
> "I spent months building a production collector against the BlackDuck API. The documentation didn't prepare me for what I found. Here's everything I wish someone had told me about navigating its hierarchical data model, undocumented quirks, and the organizational challenges hiding behind the technical ones."

### What deks never do

- Tease without delivering ("Click to find out!")
- List what the post will cover bullet-point style
- Use marketing vocabulary
- Run longer than 3 sentences

---

## Section headers

Headers carry argumentative weight. They are not labels — they are claims, observations, or punchlines.

Examples that work:
- "The Token Exchange Dance"
- "The Accept Header Maze That Almost Broke Me"
- "Why I Was Wrong to Ignore Origins"
- "Don't Create Tickets Engineers Can't Act On"
- "15 Vulns, 3 Tickets: Grouping by Remediation Action"
- "Security Teams Create Work. Everyone Else Has to Do It."
- "Two Species of Security Debt"
- "The Tooling Isn't Solving the Real Problem"
- "A Static Queue in a Dynamic System"

What makes them work:
- They make a claim or name a concept rather than describing the section
- They're short enough to scan
- They often use specific numbers, named patterns, or vivid phrasing
- They feel like talk-track section headers — the kind of thing you'd hear in a conference talk

What to avoid:
- "Background", "Introduction", "Overview" — too generic
- "How to set up X" when the post isn't a tutorial
- Marketing-y three-part subtitles ("X: Better, Faster, Cheaper")

---

## Paragraph and sentence rhythm

### Paragraphs
- Long enough to build an argument; short enough to keep momentum
- A typical thought-piece paragraph is 3–6 sentences and develops one specific idea
- Single-sentence paragraphs are used deliberately for emphasis ("Famous last words." "Just like that, more debt was created.")
- Don't break paragraphs to look "scannable" — break them where the thought changes

### Sentences
- Mix lengths: short declaratives sit next to longer flowing sentences
- Short sentences carry the punch ("Spoiler: what happens is a `406 Not Acceptable`...")
- Longer sentences carry the nuance ("The complete picture is fragmented across systems, tools, and people — which makes evaluating all of the work in the system hard, and continuously re-evaluating all of it practically impossible.")
- Active voice, present tense for current state, past tense for personal anecdotes
- **Three short staccato sentences** ("It's small. It's solvable. It's not existential.") are a permitted and effective rhythm — distinct from the marketing "three-part rhythm in titles/claims" tell flagged in the words-to-avoid table. Stand-alone sentences with periods are crisp; comma-joined three-item lists inside a title or claim are not.

### Em-dashes
- Used, but not constantly. Reserve them for setting off a clarification or twist
- Don't use them as a substitute for commas or parentheses out of habit
- A useful test: if you have more than one em-dash in a paragraph, ask if either could be a comma or a period

---

## Emphasis: bold and italics

### Bold
- Used for **claims you want the reader to agree with** before reading further
- Used for **named concepts** when introducing them ("**Discovered debt** is the stuff your tools find...")
- Used for **a key implication** that changes how the reader should read what follows ("**you cannot skip levels**")
- Don't bold whole sentences as a rule; bold the noun phrase that carries the load

### Italics
- Used for *emphasis on a single word* where the rhythm needs it ("they need to know exactly *where* to make the change")
- Used for *titles* of books, software, etc.
- Used sparingly — italic-heavy prose reads anxious

---

## Personal anecdotes and credibility

Matt's writing earns its authority through specifics. Pattern:

- **"I learned this the hard way."** Often followed by what specifically went wrong: "a 3-hour run that crashed at the 2-hour mark with no recovery."
- **"I spent an embarrassing amount of time..."** Concrete, self-deprecating, no fake humility.
- **"I've seen this create..."** When generalizing, anchor it in something seen.
- **"I can't explain why this works. It just does."** Honesty about edge cases beats false expertise.

The cumulative effect: the reader trusts him because he keeps telling them about specific moments where he was wrong, surprised, or out of his depth. The credibility comes from the willingness to be specific about failure.

What to avoid:
- Generic "many people struggle with..." framings — be specific about who, when, and what
- Hedged claims ("some might argue...") — make the claim or don't make it
- Anecdotes without payoff — every personal story should illustrate the point being made

---

## Dichotomies and named concepts

Matt frequently introduces named pairs that carry a thesis:

- **Discovered debt** vs **decided debt**
- **Direct dependencies** vs **transitive dependencies**
- **Static queue in a dynamic system**
- **Complicated** vs **complex**
- **Find** vs **fix** (and the messy space between)
- **Actionable** vs **unactionable findings**

The pattern: identify two things readers conflate, name them, then use the names through the rest of the piece. The naming itself is part of the argument.

When introducing a named concept:
- Bold or italicize on first use
- Define it in one sentence
- Reuse the name consistently — don't drift into synonyms

### Structural framings and multi-bucket sorts

Beyond two-term dichotomies, Matt uses two related structural devices:

- **Structural framings** — short metaphors that name the argument's spine. Examples: *"the floor, not the ceiling"* (1Password vs. workload identity), *"find vs. fix"* as a *gap* rather than a binary. These show up most often near the closing, where they're doing the work of distilling the post's thesis.
- **Named multi-bucket sorts** — when a two-term dichotomy is too coarse, Matt sometimes uses three (or more) named buckets. The "AI Governance, Calibrated" three-bucket sort — *already mitigated / genuinely new / old problem, new actor* — is the cleanest example. The buckets are *named*; the items in each are concrete; and the post explicitly returns to each bucket in subsequent paragraphs ("The first bucket is..." / "The second bucket is..."). Don't introduce a multi-bucket sort if it's a forced fit — but when the territory genuinely has more than two clean partitions, name them.

---

## Code, tables, and visual elements

### Code blocks
- Used for: the actual command, the actual response, the actual config
- Brief lead-in sentence, code block, then explanation
- Don't comment every line; let the code speak
- Pseudo-code is fine when illustrating a pattern, real code when showing what to actually run
- Variable names are realistic (`payment-service`, `lodash@4.17.15`) — never `foo`/`bar`

### Tables
- Used to compress structured tradeoffs or mappings (Origin → externalId → How to Fix)
- Rows are concrete examples, not abstract categories
- Always two or more rows — never a single-row table

### Inline images

- Reserved for diagrams and illustrations that earn their place — not screenshots for the sake of screenshots
- Alt text is descriptive, title-case, and treated as a caption substitute (no separate caption is rendered)
- Example: `![Vulnerability Management — What It Actually Looks Like](vuln-management-complexity.png)`
- A post should rarely need more than one or two inline images; if you find yourself adding many, ask whether the post is doing too much or whether the images are doing the post's work

### Inline formatting
- Backticks for: code symbols, file paths, header names, exact strings
- Bold for emphasis, never for code
- Italics for titles or single-word emphasis

---

## Honesty about tradeoffs

Every substantial post has at least one section where the post argues against itself or admits limits. Examples:

- BlackDuck post: "What I Wish I'd Known From Day One" lists what didn't work
- Hardest Part of Security: "We've gotten exceptionally good at the finding. What we haven't built is..."
- GRC Engineering: anticipates the "but you didn't mention AI?" objection and addresses it head-on
- Complicated vs Complex: acknowledges that complicated and complex can both be hard

The reader should always feel that Matt has considered the obvious objections. If a post reads like a sales pitch, it's wrong.

---

## Closings

### What Matt's closings do
- Restate the thesis, but with the weight of the post behind it
- Often forward-looking — what comes next, what the reader could do, what to watch
- Sometimes name the next post in a series
- End with a sentence that lands — not a rhetorical question, not a marketing flourish

### Examples
- BlackDuck: "Hopefully this saves you the months of trial and error my team went through building our collector."
- Hardest Part: "In the next post, I'll explore what solving that problem actually looks like..."
- GRC Engineering: "Compliance isn't something that happens to the business. It's something the business engineers."
- Complicated vs Complex: implicit — the reader is left with a new lens to apply

### What closings never do
- Summarize the post bullet-point style ("In summary, we covered...")
- Ask a rhetorical "What do you think?" question
- Use words like "journey", "embrace", "unlock", "leverage"
- Pad the ending to feel substantial — let it stop when it stops

---

## Series indication

When a post is part of a multi-post arc, the connection is signaled through prose, not through formal labels.

- **In the first post**, a closing sentence points forward: "In the next post, I'll explore what solving that problem actually looks like..."
- **In the follow-up**, an opening callback connects back: "In the previous post I argued..."
- No "Part 1 of 3" labels, no slug suffixes, no special frontmatter
- The reader recognizes the series through narrative continuity, not visual UI

The exception is when the post references an *external* series or appearance (e.g., the "CISO Series" podcast). In those cases, the brand reference goes in the description ("From my appearance on the CISO Series.") and may appear as a slug suffix (`-ciso-series`). That's a brand tag, not a series of your own posts.

If a more visible series UI is ever desired (a series tag rendered by the theme, a "Series:" frontmatter field), that's a separate template-level change — not a writing convention.

### Self-callback and revisit posts

When a post explicitly revisits a position from a previous post — especially when the new post extends or partially reverses the older argument — there's a specific pattern that works:

1. **Anchor the callback in the closing section**, not the opening. The new post should stand on its own first.
2. **Lean on a title or section-header echo** if there's a natural one. "AI Governance, Calibrated" closes with a section titled *Same Problems, New Actor* — a deliberate echo of an older post titled *AI Governance: Same Problems, Same Solutions*. The echo earns the callback.
3. **Affirm the through-line before owning the shift.** "I'd still defend the X half of that title without hesitation. But I'd put Y differently now."
4. **Give the technical *why* the position changed.** Not "I've evolved" or "I've grown" (performative reflection — see words-to-avoid). Instead: *"SQL injection has a fixed grammar. Prompt injection doesn't."* The specific reason is the credibility.
5. **Inline-link the older post** the first time you reference it. One link, in prose, not a separate "Previous posts in this series" block.

### Post-publish reader-response addendums

When substantive reader questions come in after publication, an in-post addendum is a viable response shape (used in "Agents Don't Travel Well"):

- Section header is a claim, not a label: *"The Questions That Came Back"* — not "FAQ" or "Reader Questions"
- Brief framing line acknowledges the context ("A coworker read this and came back with three questions. They're the ones I'd ask too, so here they are with answers.")
- Questions appear in **bold inline** rather than as nested H3 headers — keeps the section visually unified
- Answers stay in the same voice and density as the post body
- Cross-link to other posts when an answer is naturally rooted there; don't restate
- Commit the addendum as a separate commit ("Add reader Q&A section to <Post Title>") rather than amending the original — the publish history reflects the conversation

---

## Words and phrases to avoid

These are AI-tells or marketing-speak. They show up in first drafts and need to come out:

| Don't | Why |
|-------|-----|
| "This post is about" | Self-referential, breaks the contract — show, don't announce |
| "Let me reflect on" / "I didn't fully appreciate until" | Performative reflection |
| "That entire category of friction is gone" | Too tidy — a real claim has texture |
| "Game-changing", "leverage", "unlock", "harness" | Marketing vocabulary |
| "In today's fast-paced world" | Generic scene-setting |
| "It's not just X — it's Y" | The "not just X" construction is a tell |
| "You might think... but actually..." | Patronizing setup-and-knock-down |
| Excessive em-dashes ("the work — the actual work — is the running session") | Reads as crafted-essay rather than spoken-thought |
| Three-part rhythm in titles or claims | "One Place, Anywhere, Always Resumable" — too marketing-y |
| Long lists of synonyms or near-synonyms | One precise word beats three vague ones |

---

## Calibration by post type

Matt writes in three registers depending on the post.

### Technical deep-dive (BlackDuck, 1Password SSH)
- Heavier on code blocks, tables, examples
- Sections often shorter, more numerous
- Section headers can be more colloquial ("The Token Exchange Dance")
- Personal anecdotes shorter, used as bridges between technical content
- Closing is often a "What I Wish I'd Known" list
- Length: as long as the subject demands; BlackDuck is 7,000+ words because there's that much real material. No upper bound

### Thought piece / argument (Hardest Part, GRC, Complicated vs Complex)
- Heavier on argument, less on code
- Longer paragraphs, more developed reasoning
- Section headers are claims or named concepts
- Personal experience used as evidence for broader claim
- Closing restates the thesis or points to a next post
- Length: 2,200–2,500 words is the typical range. **If a thought-piece post is under ~1,500 words, ask whether the argument has been fully developed before publishing** — short thought pieces tend to be under-argued

### Hybrid (workspace post, code-attribution post)
- Personal hook, then technical specifics, then broader implications
- Length: ~1,000–1,500 words is fine for this register — it's a deliberate third register, not a short thought piece
- Code blocks present but not dominant
- Closing usually forward-looking ("what's next") rather than thesis-restating

### Length sniff test (any register)
- No hard floor, but if a post feels short, ask: is the argument fully developed? Is there a personal anecdote anchoring it? Is there a named concept or dichotomy the reader can take away?
- Stub posts that exist mostly to host an embed (the CISO Series LinkedIn embeds) are a separate artifact — not a writing target

---

## How to use this guide

1. Read the relevant section before drafting
2. After drafting, do a pass specifically against the "Words and phrases to avoid" table
3. After drafting, read the opening, the section headers, and the closing in isolation — do they each carry weight, or are any throat-clearing?
4. Find the personal anecdote(s). If there's no specific moment, the post is probably running on hedged generalities
5. Find the named concept or dichotomy. If the piece doesn't introduce a named idea, ask whether it should
6. If the post sounds like an essay-class exercise rather than a peer letting you in on something, it's not Matt's voice yet

---

## Open questions / refinements

*(None currently — initial four resolved 2026-05-01. Add new questions here as they surface during writing.)*
