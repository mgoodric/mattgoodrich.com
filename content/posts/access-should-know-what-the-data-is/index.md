+++
date = '2026-06-29T00:01:00-07:00'
draft = true
title = 'Access Should Know What the Data Is'
aliases = []
description = "Most access control protects systems: this database, that app, this bucket. It says nothing about the sensitivity of what is inside, so the same permission guards a marketing list and a table of social security numbers. Data-centric access ties the control to the data's classification, so protection follows the data across the systems that hold it. Here's how classification, labeling, and policy fit together, and why it's the hardest pillar to finish."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'Data Security', 'Data Classification', 'DLP', 'Zero Trust', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Grant someone read access to a database and you have made a decision about a system. You have said nothing about the data inside it. The same read permission covers the table of marketing email addresses and the table of social security numbers sitting one schema over, because the permission is attached to the database, and the database does not care what it holds. Your access control is guarding a container and is blind to the contents.

That blindness is the gap the data pillar of zero trust exists to close. Every other control in this series gates a system: a login, a device, a network path, an API. They ask where data lives and who can reach that place. The data pillar asks what the data is, and whether the protection matches what it is worth.

## System-Centric vs Data-Centric

The two models differ in what the control is attached to, and that attachment decides what happens when data moves.

**System-centric** access ties protection to a location: this database, this bucket, this share, this app. It is how almost all access control works, and it is necessary. Its limit is that the protection belongs to the container, so the moment data leaves the container, the protection stays behind.

**Data-centric** access ties protection to the data itself, through a classification that travels with it. A record marked as containing regulated personal data carries that mark when it is copied, exported, or moved, and the controls key off the mark rather than off the location. The protection rides with the data instead of staying with the box it came in.

The difference only matters because data does not hold still, and in a real company it never does.

## Why the Container Model Leaks

Picture the path a sensitive table actually takes. It starts in a well-governed production database with tight access. An analyst with legitimate access runs a query and exports the result to a CSV. The CSV lands in their Downloads folder, gets attached to a message in chat, uploaded to a spreadsheet tool for a quick pivot, and pasted into a slide for a meeting. Maybe it gets fed to an AI assistant to summarize. At every hop, the careful access controls on the production database are irrelevant, because the data is no longer in the production database. It is in five places that never heard of those controls.

System-centric security protects the first location and loses the data at the first copy. The classification is the only thing that can follow it, because the classification is a property of the data, not of any one system it passes through. If the export carried a label that said this is regulated personal data, the chat tool, the spreadsheet tool, and the AI assistant could each refuse it, redact it, or flag it. Without the label, every one of them sees an anonymous block of text and treats it like any other.

## Classify, Label, Then Enforce

Data-centric access runs as a pipeline, and each stage depends on the one before it.

**Classify.** First you have to know what is sensitive, which means scanning your data for the patterns that matter: personal data, payment card numbers, health records, secrets, regulated categories. Tools like [AWS Macie](https://aws.amazon.com/macie/) for cloud storage do this discovery automatically, finding the social security numbers and card numbers hiding in buckets nobody remembered. [NIST's FIPS 199](https://csrc.nist.gov/pubs/fips/199/final) gives the standard frame for the output: categorize data by the impact of its loss, low, moderate, or high, so the classification means something consistent. On the open-source side, [Microsoft Presidio](https://microsoft.github.io/presidio/) detects and redacts personal data in text, and catalogs like [OpenMetadata](https://open-metadata.org/) and [DataHub](https://datahubproject.io/) store the classification tags alongside the data so the rest of the pipeline can read them.

**Label.** Classification is only useful if it sticks to the data, so the next step is attaching the result as a durable label. [Microsoft Purview's sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels) are the common example: a label embedded in the file or the record that persists when the file is copied or emailed, so the mark travels with the data instead of living in a separate registry that the copy escapes.

**Enforce.** With a label that travels, policy can finally key off what the data is. Access can require a clearance matched to the label. Data loss prevention can block a high-impact label from leaving by email or upload. Encryption can be applied automatically by sensitivity. The same label drives access, movement, and protection, and it drives them wherever the data goes, because the label went too.

The payoff is that protection stops depending on the data staying put. A high-sensitivity label means the same thing, and triggers the same controls, in the production database and in the CSV that escaped it.

## Classification Is the Pillar Nobody Finishes

Here is the honest part, and the reason the data pillar sits at the end of every zero-trust roadmap. It is the hardest one, and almost nobody completes it.

The problem is coverage. Data is created faster than it is classified, by people who are not thinking about labels, in formats that resist scanning. Structured database columns classify reasonably well. The unstructured sprawl, the documents, the chat history, the screenshots, the notes, the years of accumulated files in shared drives, does not, and that is where a great deal of the sensitive data actually lives. Automated classification has false positives and false negatives, manual labeling depends on people bothering, and labels drift out of date as data changes. A program that waits to classify everything before it enforces anything waits forever.

So the realistic version is scoped and continuous, not complete. Auto-classify the patterns you can detect with confidence, the regulated identifiers with clear formats, and enforce on those first. Label the crown-jewel data stores, the handful of systems whose contents would hurt most, by hand if you must, and protect those well. Accept that coverage will be partial and that the long tail of unclassified data is a standing risk you are reducing rather than eliminating. The same telemetry and detection that watches access can watch for sensitive data showing up where it should not, which is how you catch what the classification missed. Partial data-centric protection on your most sensitive data beats perfect protection on the systems while the data walks out in a CSV.

## A Permission That Knows What It Guards

An access decision that cannot tell a newsletter list from a table of social security numbers is guessing, and it guesses the same way for both. Tying the control to the data's classification is what lets it stop guessing, and lets the protection survive the copy, the export, and the upload that system-centric security never sees.

You will not classify everything, and you should not wait to. Find the data that matters, label it so the label travels, and enforce on the label wherever the data goes. The data inside is the thing worth protecting, and the control should know the difference between a newsletter and a table of social security numbers.
