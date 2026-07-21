+++
date = '2026-07-23T00:01:00-07:00'
draft = false
title = 'Layering Local AI on Paperless-ngx: Let It Store, Not Think'
aliases = []
description = "Paperless-ngx stores documents well and classifies them badly, so I turned off its classifier and put a local-AI layer in front of the API. It now files thousands of family documents with a review rate under 2%. Here is how the augment-don't-replace pipeline works, and where it still breaks."
categories = ['AI', 'Automation', 'Productivity', 'Tools', 'Software']
tags = ['AI', 'Paperless-ngx', 'Local LLMs', 'Ollama', 'Document Management', 'Google Drive', 'Automation', 'Personal AI']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

I started this project to replace [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx). I ended up keeping it and building on top.

The container kept crashing every few days. Auto-tagging missed anything it hadn't seen before. There was no vision support for scanned PDFs. And it was mine and only mine: the family's documents were locked in a web UI my wife was never going to open, and I never wanted her to have to. The plan was to migrate everything out, stand up something new, and shut Paperless down.

That plan was wrong, and I'm glad I figured it out before I committed to the rebuild.

## The Years of Brittle Rules

None of this was the first attempt, and it is worth saying how the earlier ones failed, because that failure is why the pipeline reasons about a document instead of matching against it.

For a long time I tried to file everything with deterministic rules. Hazel watching folders and renaming by pattern. Hard-coded filenames. Parsing file metadata to guess where a document came from. Dozens of scanner presets, each dropping to its own directory with its own processing rules, and piles of custom Python underneath all of it. Every rule worked for the documents I wrote it for and broke on the next slightly different one: a new biller, a scanner that named a file differently, a statement with a new layout, and I was writing another rule. Across thousands of documents that keep growing as I scan old paper and new mail arrives, it became unmanageable. There is no finite set of rules that covers the documents you haven't seen yet.

That is the whole case for classification over matching, and it is the same case against Paperless's own classifier. A rule fits the documents you already had. A model reads the one in front of it.

## The Pivot

What flipped my thinking: I started auditing what Paperless was actually doing well versus what was making me crazy. The two lists weren't what I expected.

The "doing well" list: OCR. Archive. Postgres-backed metadata. Search and indexing. The web UI for power users (me). The ability to ingest from a watched directory. Years of accumulated correspondent and document-type data on the documents I'd already filed by hand. None of those were the things I was complaining about. All of them were things I'd have to rebuild from scratch if I replaced it.

The "making me crazy" list: confidence-aware classification. Correspondent-first priors. Vision models for scanned PDFs. A non-developer-friendly front door for the family. The ability to know *when not to guess*.

Read those side by side, and the conclusion is obvious in retrospect. Paperless was 80% of a good system. The 20% that was missing was specifically the part that needed AI. Replacing the whole thing meant rebuilding the 80% I already had to add the 20% I didn't. Augmenting meant adding only the 20%.

The container instability was real, but it was a contained operational problem: Watchtower restart policies, monitoring on actual silence rather than just exit codes, alerting when uptime drops. Solvable, not fundamental.

So I kept Paperless and built around it.

## The Architecture

Four pieces, each doing one job:

1. **Google Drive Inbox**: where my wife and I drop documents, plus a watcher on my email that pulls new attachments in automatically. The front doors.
2. **Paperless-ngx**: OCR, archive, metadata store, Postgres backend. The engine room.
3. **Local AI classification layer**: Ollama on the Mac Studio, with the patterns described below. The brain.
4. **Google Drive organized output**: a sync job that mirrors the filed structure back to Drive so the family can usually find what they need on their own. The lobby.

The flow: a document lands in the Drive Inbox, or arrives as an attachment my email watcher pulls in. A sync job lands it in Paperless's consume directory. Paperless OCRs it. The AI layer classifies it using local models. The filing rules engine decides where it goes. rclone copies the OCR'd version to the right path under a separate Drive root.

![The document pipeline end to end. Two front doors, a Google Drive inbox my wife and I drop documents into and an email watcher that pulls attachments, both feed Paperless-ngx, the engine room that handles OCR, PDF/A archiving, storage, and full-text search. Paperless hands off to a local AI brain that classifies type, correspondent, and date and writes it back through the REST API. A filing-rules engine builds the destination path, and the organized copy lands in a Google Drive folder the family looks in.](diagram-pipeline.png)

My wife never sees Paperless. She sees a Drive folder structure. I get the Paperless web UI for the cases where I want to drill into a document directly. Both interfaces serve the same underlying data.

## Turn Off Paperless's Own Classifier

Paperless-ngx has its own automatic classifier, and the first real decision was to stop using it. It is a scikit-learn MLP, a small neural network over one- and two-word token counts, trained on the metadata of documents you have already filed. It is bag-of-words: it can't reason about a document, can't classify a correspondent it has never seen, and only relearns on a schedule. It also has a cold-start tax. It gives you nothing until you have hand-labeled a few hundred documents, where a language model classifies the first document correctly with no training at all.

So I took the fields I wanted the LLM to own away from it. In Paperless, every tag, correspondent, and document type has a matching algorithm; set it to **None** and the built-in classifier stops touching that object, and it gets applied only by whatever I point at the API. I set every correspondent and the tags that matter to None. The all-the-way version is `PAPERLESS_TRAIN_TASK_CRON=disable`, which stops the classifier from training at all so the MLP and the LLM aren't fighting over the same fields.

The division of labor that falls out of this is the whole architecture in one sentence. Paperless owns ingestion, OCR, the PDF/A archive, storage, and full-text search. My code owns classification and writes its answers back through the REST API. Paperless is the engine room. The thinking happens outside it.

## The Local Models

The classification layer runs on a Mac Studio M3 Ultra with 96GB of unified memory, models served by Ollama and picked by a small model-selection router. The pattern is compare-two-local, escalate-to-cloud:

- **Qwen3 30B-A3B (MoE, 3.3B active)** does the fast first pass, pulling type, correspondent, and date out of the OCR text. Local, roughly $0 per document.
- **GPT-OSS 120B** is the heavier local model. It runs as the second opinion the fast pass gets compared against, still on the Mac Studio, still free.
- A **paid cloud model**, Gemini Flash, is the tie-breaker, pulled in only when the two local models disagree or confidence is low. Even at thousands of documents a month the cloud bill stays under $5.

The combination matters more than any single model. Two local passes catch most of the disagreement for free, and the cloud is a quality lever I pull only when local can't decide. Nothing routes to a paid model by default.

## The Patterns

The classification layer is a stack of patterns, each addressing a specific failure mode in document classification.

### Correspondent-First Classification

The first thing I built was a prior probability table. I queried the whole history of documents I'd already filed in Paperless and built a knowledge base: for each correspondent, what document types do I actually have?

```
Anthem Blue Cross:
  - Explanation of Benefits: 70%
  - Insurance Policy: 23%
  - Statement: 7%

King County:
  - Property Tax: 91%
  - Notice: 9%

Chase:
  - Statement: 85%
  - Credit Card Agreement: 10%
  - Notice: 5%
```

This changes the classification problem fundamentally. Instead of asking "what is this document?", the model asks "given that this is from Anthem, what is it most likely to be?" You're not starting from zero, you're starting from a 70% prior.

The LLM still reads the document, but now it's confirming or overriding a strong expectation rather than guessing cold. Accuracy jumped substantially when this was added. The knowledge base is up to 191 correspondents now, all with real probability distributions mined from documents I'd already filed by hand over the years.

### Three-Tier Confidence Routing

Not everything should be auto-filed. This was one of the most important design decisions: build a system that knows *when not to guess*.

- **Tier 1: Auto-file.** High confidence + known correspondent + unambiguous filing rule. The system is sure. File it and move on.
- **Tier 2: Compare and escalate.** Medium confidence, or a known correspondent with an ambiguous document type. The system runs both local models, and if they disagree it escalates to the cloud tie-breaker rather than trusting one answer.
- **Tier 3: Human review.** Low confidence, unknown correspondent, or a document type the system hasn't seen before. Goes to Discord for me to review.

The numbers say it is working, and they have moved. Over the last seven days the pipeline classified 5,019 documents and sent 90 of them to human review: under 2%, at an average confidence of 94%. Over the system's whole life the review rate has run closer to 10%, so the fraction I have to touch has dropped about 5x as the correspondent knowledge base filled in. The review pile is the number I actually watch, because it is the count of documents still on me, and watching it shrink is watching the uncertainty calibration come right.

![The classification decision. A document's OCR text goes to a fast local model, Qwen3 30B; if it is confident and the correspondent is known, the document auto-files, which is about 98% of them. If it is unsure, a second local model, GPT-OSS 120B, runs and the two are compared: agreement auto-files, disagreement escalates to a paid cloud model, Gemini Flash, to break the tie. If it is still low confidence or the correspondent is new, the document goes to human review, about 2%, sent to Discord.](diagram-classification.png)

### Compare Two Local Models, Escalate to Cloud

For anything the fast pass is unsure about, the system does not trust a single model. It runs the document through both local models and compares their answers. Agreement is the signal. Disagreement escalates to the paid cloud model as the tie-breaker, with both local answers in front of it to choose between.

The trick is that it is often easier for a model to pick the better of two answers than to generate the right one cold, and disagreement between two local models is a cheap, reliable flag for the documents worth a cloud call. Most documents never trigger it.

### Human-in-the-Loop with Learning

The Discord interface for Tier 3 does two things. It clears the review queue, and every decision I make there trains the system.

When a document lands in Tier 3, I get a Discord message with the document preview, the proposed classification, and three buttons: **Apply**, **Reject**, or **Reclassify**. If I click Apply, two things happen: the document gets filed, and the correspondent knowledge base updates with this new data point. The next time a similar document comes through, the system has a better prior.

Over time, the review queue shrinks because the system gets smarter. That's the design working as intended.

### Filing Rules Engine

Files don't go into a flat bucket. They go into structured paths:

```
Financial/Chase/Checking/2026/04/
Medical/Insurance/Anthem/EOBs/2026/
Aviation/Pacific NW Aviation/Invoices/2026/
Legal/Estate Planning/
```

The rules engine is a template system: a list of dicts, each with conditions and a path template. Adding a new rule is appending a dict. Templates support variables like `{correspondent}`, `{account}`, `{year}`, `{month}`. About 27 rules cover the active document types: financial, aviation, medical, property, legal, household.

### Custom Attributes the Rest of My Systems Read

Type, correspondent, and date are the obvious fields. The more useful ones are the custom attributes the model pulls straight out of the document: the account a statement belongs to, the provider on a medical bill, whether a letter is a diagnosis, a lab result, or a visit summary. Models are unreasonably good at this. Hand one a page of unstructured text and it will reliably extract the structured fields I ask for, which is exactly the job the old regex rules kept failing at.

Those attributes do two jobs. They shape the storage path, so a document lands under the right account or provider without a rule written for each case. And they feed the other systems I run beyond Paperless: a document the model tagged as a lab result or a diagnosis carries enough structure that a downstream service can decide, on its own, whether it belongs in a running medical history. Paperless stores the document. The attributes are what let something else act on it.

## The Guardrails

The patterns above are what makes the system *work*. The guardrails below are what keep it from doing damage when it doesn't.

### Never Guess a Wrong Folder

When nothing matches, the fallback rule files to `Review/Unsorted/{year}/{month}/`. Not a best-guess folder. The unsorted folder.

Better to have an "I don't know" pile than a wrong folder that hides the document forever. Confidence is queryable; misfiling is not.

### Confidence Thresholds Are Tuned, Not Magic

The thresholds for tier routing came from running real data and seeing where errors clustered. They get retuned as the correspondent knowledge base grows. There's no magic number, only "what does the data say is the right cutoff this quarter?"

### The Judge Is Bounded

The pairwise judge can override the classifier, but only between two presented options. It cannot invent a third option. This prevents the failure mode where a "smarter" model goes off-script and decides the document is something neither tier-1 model considered.

### Dual-Hash Lineage

This one was painful to figure out. Paperless modifies files when it OCRs them: it embeds a text layer in the PDF. The bytes you put in are *not* the bytes Paperless stores.

We track three hashes per document: `source_hash` (the original file before Paperless), `archive_checksum` (the post-OCR file Paperless stores), and `stored_hash` (what rclone sees after the sync). When matching pipeline records against Paperless data, you have to match on `archive_checksum`, not `original_checksum`. Switching to the right field took the dedup match rate from 0% to 82% in a single afternoon. I lost most of a day to debugging this before the right field clicked.

The source hash also does something I lean on constantly. When I turn up a file in iCloud or an old backup and can't remember whether I already filed it, I hash it and ask the system, and it answers yes or no without my opening a single document. As I claw fifteen years of scattered documents back into one place, that programmatic "do I already have this?" is what keeps the migration from becoming its own mess.

### `rclone copy`, Not `rclone sync`

`rclone sync` makes the destination match the source, including deletes. We had pipeline-uploaded files vanish from Drive because rclone ran 15 minutes later, didn't see them in the Paperless source tree, and deleted them as "extra files."

The rule we landed on: `rclone copy` for pipeline output, `rclone sync` only for the Paperless-mirrored content. Two hours of debugging, then a one-line config change. Always.

## Google Drive: Inbox and Organized Output

The Drive Inbox is a single folder. Drop a PDF into it, scan a doc with the iPhone, save an EOB from a portal. A sync job pulls from Drive Inbox into Paperless's consume directory and the rest of the pipeline takes over.

The organized output is a separate Drive root that mirrors the filed structure. `Financial/Chase/Checking/2026/04/`, `Medical/Insurance/Anthem/EOBs/2026/`, and so on. After the filing rules pick a destination, an rclone job copies the OCR'd version of the document to that path.

This is where my wife looks, and keeping her here was the whole point. The structure is honestly organized more for me than for her, but the patterns are consistent enough that she can usually infer where a document landed. Finding things had always been the hard part, and for years we bounced between Google Drive and iCloud, paying for storage and still never sure where anything was. Google Drive is the easiest for us, so that is where documents live now, and the goal was to keep her right there. I never mentioned Paperless to her, because from where she works nothing changed: the pipeline just made the Drive folders organize themselves. It looks like the structure a thoughtful human would build by hand, except it stays consistent because no human is touching it.

## What This Doesn't Solve

iCloud cleanup is a separate project. There are thousands of files in iCloud Documents that aren't all documents: screenshots, downloads, junk that accumulated over 15 years. That needs a pre-filter pass before classification can do anything useful.

The Discord interface works, but a real web UI for managing 191 correspondents and 27 filing rules would be better. That's an investment I haven't made yet because the current setup isn't actively painful.

## Paperless Is Growing Its Own AI

Worth being honest about: the thing I built is partly being absorbed into the tool. Recent Paperless-ngx ships native LLM features. Point it at a local Ollama model and it will suggest a title, correspondent, and tags for a human to accept. That is real, and for a lot of people it will be enough.

It is not enough for mine, for two specific reasons. It suggests; it does not file. There is a person in the loop by design, which is the opposite of what I want for the 98% of documents that are unambiguous. And it does not do the parts that make the pipeline useful to my family: the correspondent-first priors, the routing that decides when *not* to guess, and the filing all the way out to a Drive folder my wife actually opens. The native feature is a much better default than the old MLP. It is not yet a pipeline that files unattended. The day it can file end to end with calibrated confidence, I will happily delete code.

## Why This Matters

The bigger lesson, the one that generalized for me: augmenting open-source tools with AI is a more sustainable pattern than replacing them.

Paperless will keep getting better as a project. The local model layer will keep getting better as the open-weight ecosystem matures. The two improvements compose. If I'd replaced Paperless, I'd have inherited the obligation to maintain everything Paperless was doing, and the underlying tool would have kept getting better in directions I'd never benefit from.

The same logic applies in a lot of places. Find the joint where the existing tool stops being good. Augment exactly there. Don't demolish the parts that work.
