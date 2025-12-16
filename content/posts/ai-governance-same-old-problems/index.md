+++
date = '2025-08-24T12:00:00-07:00'
draft = false
title = 'AI Governance: Same Problems, Same Solutions'
aliases = []
description = "AI governance challenges aren't fundamentally new - they're extensions of existing IT security problems like shadow IT, data inventory gaps, and data loss. Organizations with mature security programs already have the building blocks needed to govern AI, though some AI-specific challenges require additional consideration."
categories = ['Security', 'Artificial Intelligence','Governance']
tags = ['AI', 'Artificial Intelligence', 'governance', 'security', 'risk management', 'IT governance', 'shadow IT', 'data loss prevention', 'enterprise security', 'security architecture']
[params]
  author = 'Matt Goodrich'
+++

**What risks does AI pose that didn't exist before?**

The short answer: not many. Companies have been dealing with these fundamental challenges for years:

- **Shadow IT** - applications and services introduced without approval, oversight, or visibility
- **Data Inventory gaps** - lack of knowing where data is or what data is stored
- **Data Loss** - data leaving the environment for one reason or another

If your organization struggles with employees downloading unauthorized software, storing sensitive data in personal cloud accounts, or bypassing IT controls, then AI tools are simply the latest category of shadow IT operating in those same blind spots.

**The foundations for governing AI are largely the same now as they were before AI.**

Organizations with mature security programs already have the building blocks needed:

- **IT Asset Management & Discovery** - Regular scanning and inventory of all devices, applications, and services connected to the network to identify unauthorized tools
- **Data Loss Prevention (DLP) with discovery and content inspection** - finds sensitive data, classifies it, and prevents it from leaving to unauthorized services
- **Endpoint protection with application control** - blocks unauthorized installations while monitoring data access patterns
- **Network monitoring/traffic analysis/Cloud Access Security Brokers (CASBs)** - detect unauthorized access while tracking data movement and egress

These aren't new problems requiring new solutions - they're the same fundamental security challenges that mature programs were already addressing. The difference is scope and scale, not the nature of the risk.

**Where AI does introduce new challenges**

There are some AI-specific governance challenges that organizations need to address:

- **Model Integration Complexity** - MCP servers, API integrations, and proxy architectures that can obscure individual user actions behind service accounts, reducing auditability
- **Data Context Leakage** - AI systems that retain conversation history or use data for training may expose information across user sessions or organizational boundaries
- **Prompt Injection and Manipulation** - Users finding ways to bypass AI safety controls or extract sensitive information through carefully crafted prompts
- **Model Hallucination Risks** - AI generating false information that gets treated as authoritative, especially problematic in decision-making contexts
- **Third-party Model Dependencies** - Reliance on external AI services where data processing, retention, and security practices are outside organizational control
- **Cross-tenant Data Bleeding** - Risk of data from one organization being inadvertently accessible to another through shared AI infrastructure

But even these challenges can largely be addressed through existing security program components. Third-party risk management and vendor security assessments become critical since most AI capabilities are external services. API security and service account governance help with integration complexity. Input validation principles apply to prompt injection, just like they do for SQL injection.

**The bottom line**

Organizations with strong foundational security controls can extend those controls to cover AI use cases. Those without these fundamentals will find AI amplifies their existing vulnerabilities rather than creating entirely new categories of risk.

Don't let AI governance become an excuse to skip the security basics your organization should have implemented years ago.