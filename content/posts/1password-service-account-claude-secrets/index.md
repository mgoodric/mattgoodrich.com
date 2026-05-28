+++
date = '2026-05-13T12:00:00-07:00'
draft = false
title = 'Stop Putting Secrets in .env Files: A 1Password Service Account for Claude'
aliases = []
description = "I keep AI tooling out of my .env files entirely. Secrets live in a dedicated 1Password vault that a service account can read — and nothing else. Here's the setup and why I think this is the right pattern for AI agents."
categories = ['Security', 'Productivity', 'Tools', 'Software', 'Artificial Intelligence']
tags = ['AI', 'Claude Code', '1Password', 'Secrets Management', 'Security', 'Developer Tools', 'Workflow']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

**`.env` was already a compromise. AI agents make it a bad one.**

For human developers, a `.env` file is a small, stable risk. It lives on one machine, it's gitignored, the developer who wrote it is the only one reading it, and most of the time nothing ever goes wrong. The control isn't great, but the blast radius is small.

AI agents change that calculation. Now the file isn't being read by the human who wrote it. It's being read by a process that can shell out, edit code, paste into a transcript, run network calls, and occasionally do things you didn't quite ask for. The "small, stable risk" assumption isn't true anymore. The same plaintext file is now an input to a system whose outputs you don't fully control.

It's already happening in the open.

![Twitter Users Baiting AI Agents to Reply with Their .env Contents](env-secrets.png)

I'm not going to pretend I have a perfect answer. But I've moved away from `.env` for anything an AI agent touches, and the pattern that's working for me is a 1Password service account scoped to a single dedicated vault.

## The Problem with `.env`

Three things have always been wrong with `.env` files. They got worse the moment an AI agent showed up.

**They're plaintext on disk.** Anything with file system access can read them. That used to mean "another process running as your user." Now it also means "an AI agent that decided to grep your home directory for context."

**They're easy to commit by accident.** I've done it. You've probably done it. The `.gitignore` catches most cases, but not all. `git add -A` after a refactor that moved `.env` to a slightly different path is the canonical way to leak credentials into history.

**There's no audit trail.** A `.env` file doesn't know who read it, when, or why. If a credential leaks, you have no way to scope what got exposed.

For human-only workflows, those tradeoffs were tolerable. For agents, the second and third problems compound. An agent that decides to commit a file isn't going to second-guess itself the way a human reviewing a `git diff` might. And if an agent does leak a secret (into a transcript, a comment, a paste-buffer) there's no log of which secret, from where, used by what.

## What a Service Account Buys You

1Password's service account model is built for non-human identities. The shape of it:

- A service account is a separate identity with its own token
- The account has access *only to vaults you explicitly grant it*
- The token is revocable in one click, with no impact on the rest of your 1Password setup
- Every secret read is logged with the service account's identity
- A given credential lives in exactly one place, so rotating or revoking it is one update, not a sweep across every `.env` file that copied the value
- Secrets can be fetched at process-start via `op` and never touch disk

That last point is the one that matters most. With a service account and the `op` CLI, secrets exist in environment variables for the lifetime of the process and nowhere else. There's no file to commit. There's no plaintext at rest. The agent reads the secret when it needs it and the secret evaporates when the process exits.

The single-location property is the one I keep noticing in everyday use. The same API key used to end up duplicated across however many project directories needed it, and rotating it meant hunting down each copy and hoping I didn't miss one. With a vault entry, the value changes once and every script that resolves `op://Claude/Anthropic/credential` picks up the new value on its next run. Revoking is the same shape: one delete, and the old credential is unreachable from everywhere at once.

## My Setup: A Dedicated "Claude" Vault

The piece that actually scopes this for AI work is a dedicated vault.

I have a 1Password vault called `Claude`. It contains only the secrets I have explicitly decided that an AI agent on my machine can use: a handful of API keys, a couple of tokens, nothing else. My personal logins, my family's shared vault, my work credentials, any secret I haven't deliberately whitelisted for AI access: none of it is in this vault, and none of it is reachable by the service account.

The service account is scoped to exactly one vault: `Claude`. That's the entire access surface. Even if the token leaked tomorrow, the blast radius is whatever's in that one vault, which is also the set of credentials I already accepted some risk on by allowing AI to use them.

There's a side benefit I didn't expect when I set this up: adding a new secret to the `Claude` vault is now a deliberate act. It's not a copy-paste into a half-edited `.env`. It's a moment of intentionality where I decide whether this credential is one I'm comfortable handing to an AI process. That friction is small, but it's the right friction.

## How It Works in Practice

The flow is a service account token, the `op` CLI, and `op run` (or `op read`) to inject secrets at the moment they're needed.

The token itself lives in the macOS keychain rather than in a shell init file. My shell exports it from the keychain at session start:

```bash
# In ~/.zshrc or equivalent
export OP_SERVICE_ACCOUNT_TOKEN=$(security find-generic-password \
  -s "op-service-account-claude" -w 2>/dev/null)
```

Once that's in the environment, scripts and tools fetch secrets via `op`. The two patterns I use most:

```bash
# Inline read — for one-off scripts
ANTHROPIC_API_KEY=$(op read "op://Claude/Anthropic/credential")

# op run — for an entire process
op run --env-file=.env.template -- bun run my-script.ts
```

The `.env.template` is the file I'd normally call `.env`, except instead of literal values it has `op://` references:

```
ANTHROPIC_API_KEY=op://Claude/Anthropic/credential
OPENAI_API_KEY=op://Claude/OpenAI/credential
GROQ_API_KEY=op://Claude/Groq/credential
```

This file *is* safe to commit. There's nothing sensitive in it, just a manifest of which secrets the script needs and where to fetch them. A human (or an agent) reading the template knows exactly what credentials are in play without ever seeing a value.

When `op run` executes the command, it resolves each `op://` reference, exports the resolved value into the process environment for the duration of the run, and exits with the process. No file gets written. No value lives on disk. The agent gets the credential it needs and nothing more.

## What This Doesn't Solve

I want to be honest about the gaps, because nothing about this setup is bulletproof.

**Once a secret is in the agent's process memory, it's a secret in memory.** A prompt injection that exfiltrates an environment variable still works. `op run` reduces the *at-rest* surface; it doesn't reduce the *in-process* surface.

**The service account token is itself a secret.** I store it in the macOS keychain rather than in a file, but it's still a credential I have to protect. Lose the keychain and you've lost the keys to the `Claude` vault.

**The agent can still print the secret if it wants to.** Nothing stops Claude from echoing `$ANTHROPIC_API_KEY` into a transcript or a commit. The vault scoping limits what's available to leak; it doesn't prevent the leak itself. That's a process and prompt-design problem, not a credential storage problem.

**Vault scoping is only as good as your discipline.** If I get lazy and start dropping production database credentials into the `Claude` vault because it's convenient, I've defeated the whole point of the dedicated vault.

## Why I Still Prefer It

The mental model that makes this click for me: secrets management for AI agents is the same problem as secrets management for CI/CD, scheduled jobs, or any other non-human identity. We've spent years getting the non-human-identity story right in production environments: short-lived tokens, scoped service accounts, audit logs, no static credentials in config files. The only reason `.env` ever felt acceptable for local development is that the threat model was so small.

AI agents make the local threat model bigger. The fix is to apply the production-grade pattern locally. A service account scoped to a single vault, secrets fetched at process-start via `op`, no plaintext at rest. None of that is a new idea. We just keep forgetting to apply it the moment a new tool shows up that wants credentials.

The `.env` file was a compromise we made when the only thing reading it was us. It doesn't have to be the compromise we keep making.
