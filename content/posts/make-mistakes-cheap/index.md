+++
date = '2026-07-22T00:01:00-07:00'
draft = false
title = 'Make Mistakes Cheap Before You Let the Agent Run'
aliases = []
description = "I have been letting AI coding agents run with broad permissions on my own machine, and the safety that holds comes in layers. Make every mistake reversible (rm that lands in the trash, a filesystem snapshot before each run, everything in git), write the rules down where the tool actually reads them, and cage the irreversible at the OS level. Here are the local changes that make yolo-ing code safer, and why a guardrail the agent can shell around, or argue itself out of, doesn't count."
categories = ['Artificial Intelligence', 'Security', 'Engineering']
tags = ['AI', 'Claude Code', 'Codex', 'Agents', 'Security', 'Sandboxing', 'Prompt Injection', 'Developer Tools']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

**The first safety change I made for my agents was the one that does the least.** I aliased `rm` to `trash-put`, from [trash-cli](https://github.com/andreafrancia/trash-cli), so a deleted file lands in a recoverable trash instead of vanishing. It felt responsible. Then I thought about how an agent actually runs a command, and the alias stopped looking like a guardrail.

An alias only exists in an interactive shell. When Claude Code or Codex runs a command, it runs through a non-interactive shell, and non-interactive shells do not expand aliases. The agent also writes scripts and runs them, calls `/bin/rm` by full path, and pipes through `xargs`, and none of those ever see my `.zshrc`. The trash-cli maintainer actually recommends against aliasing `rm`, because `trash-put` takes different flags and the alias quietly breaks scripts. So the change I made to feel safer protects me when I fat-finger a command, and does almost nothing the moment an agent is the one typing.

That is the whole problem in one example, and it points at the rule this post is built on: **a guardrail the agent can shell around is theater.** Anything you set up in the shell, an alias or a function or a wrapper on your PATH, is bypassable by a process that calls the real binary. Real safety lives one layer down, and it comes in two kinds.

## Two Kinds of Guardrail

Every local safety measure is either **reversible-by-default** or **prevent-the-action**.

Reversible-by-default is an undo buffer. The agent is allowed to do the damage, but you can get the state back: a trash that holds deleted files, a filesystem snapshot from before the run, a git history you committed first. It does not stop anything. It makes stopping unnecessary, because the mistake is cheap to walk back.

Prevent-the-action is a cage. The command never runs, or it runs somewhere it cannot reach anything that matters: an OS sandbox, a non-root user that cannot touch `/etc`, a firewall that drops the outbound connection. It stops the action instead of undoing it. And it comes in strengths, from a rule you write in plain language that the agent can talk itself out of, up to a kernel boundary it cannot.

So the layers, softest to hardest: make mistakes cheap to undo, write the rules down, and put a hard cage around what is left. The reversible layer is where most of the value is, because it is cheap and it does not depend on the agent cooperating. Start there.

![The guardrail layers around an unattended agent, weakest to strongest. Shell tricks like aliasing rm are theater, because the agent shells around them by calling the raw binary. Written rules in CLAUDE.md or AGENTS.md are a soft layer that usually holds but a prompt injection can override. An OS cage of sandbox, non-root user, and egress deny is hard because the kernel enforces it. Underneath all of them, a reversible undo buffer of filesystem snapshots and git catches what still gets through and makes the mistake cheap to fix.](diagram-guardrail-layers.png)

## Make Mistakes Cheap

**Trash, with its eyes open.** [trash-cli](https://github.com/andreafrancia/trash-cli) on Linux (`trash-put`, restore with `trash-restore`) and `trash` from Homebrew on macOS are worth installing. macOS `rm` has no trash at all; it is a hard unlink. Just install these for what they are: a convenience for you, not a cage for the agent. If you want the agent's own `rm` to land in the trash, an alias will not do it. Put an executable named `rm` earlier on the agent's PATH, or accept that `rm` is unsafe and lean on the next two, which do not care what the agent calls.

**Snapshot before the run.** This is the undo buffer that actually holds, because it captures the whole tree and the agent cannot opt out of it. On the Mac the filesystem already does it for free:

```bash
tmutil localsnapshot           # APFS snapshot of /, seconds, no config
tmutil listlocalsnapshots /    # com.apple.TimeMachine.2026-07-21-101500.local
```

Take one right before you turn an agent loose. To get a file back, mount the snapshot read-only and copy out of it; a full rollback is a Recovery-mode restore and wipes later snapshots, so cherry-picking is usually what you want. The catch worth knowing: these get thinned automatically, roughly a day and sooner under disk pressure, and a snapshot pins the disk space of everything it references. Take a fresh one per run rather than trusting yesterday's.

On the Unraid box, the same idea is a ZFS one-liner, and here the rollback is real:

```bash
zfs snapshot pool/dataset@pre-agent
zfs rollback pool/dataset@pre-agent   # whole dataset, back to the mark
```

**Commit before the run, isolate per agent.** Git is the undo buffer for code, and the only work it cannot recover is the work you never committed. A clean `git status` before launch is the single habit that pays off most here. Then give each agent its own [worktree](https://git-scm.com/docs/git-worktree) so two of them cannot step on each other:

```bash
git worktree add ../repo-agentA -b agentA
```

One HEAD, one index, one working directory per agent, sharing a single object store. And keep the escape hatch open. `git reflog` recovers a bad reset or rebase, but its default retention drops unreachable commits after 30 days, so on a machine where agents run, tell it to hold on:

```bash
git config --global gc.reflogExpire never
git config --global gc.reflogExpireUnreachable 365.days
```

One honest gap in the git story, because it is the one people assume is covered: the reflog does not save uncommitted changes. `git reset --hard` or `git checkout .` erases your working-tree edits with no reflog trace. That specific hole is exactly what the filesystem snapshot above closes, which is why you want both and not either.

## Write the Rules Down, But Don't Trust Them

Between the shell trick and the sandbox sits a layer worth using well: the rules you write in plain language. Put "never force-push, never touch production, delete only inside the repo" in a `CLAUDE.md` or an `AGENTS.md` and the agent reads it and mostly obeys, because a clear instruction sits high in the model's [instruction hierarchy](https://arxiv.org/abs/2404.13208), the trained priority order that ranks your standing rules above the current task above whatever text arrives from a file or a web page. Models are genuinely good at following clear, checkable instructions. That is what benchmarks like [IFEval](https://arxiv.org/abs/2311.07911) measure, and the frontier models score in the 90s.

I'll be honest that this layer makes me uneasy. I have spent years putting hard, verifiable security boundaries in place, the kind you can test and prove hold, and typing a sentence in plain English and calling it a control feels wrong. It should. A rule the model can read is a rule the model can talk itself out of.

Two limits, both straight out of the evals. Adherence is cooperation-dependent, and it falls apart when instructions conflict: [IHEval](https://arxiv.org/abs/2502.08745), the benchmark built for exactly this, watches the best models drop toward a coin flip once a lower-priority instruction argues against a higher-priority one. A prompt injection from a poisoned README or a tool's output is precisely that conflict, and the rule and the attack run through the same model on the same attention, so a guardrail can always in principle be argued away.

The second limit is the one I keep relearning. I have caught myself thinking Codex honors a written rule more reliably than Claude, and the benchmarks do not back a durable gap between the two. There is a plainer explanation. Claude Code auto-loads `CLAUDE.md`; Codex auto-loads `AGENTS.md`; Claude Code will not read `AGENTS.md` unless you import it. A rule in the file your tool does not read is not a rule. Half the time the model did not ignore the guardrail, it never saw it, or the rule was too vague to act on. Specific beats general ("delete only inside the repo, never with an absolute path" beats "be careful with `rm`"), and a bloated rules file holds worse than a short one.

So write the rules, put them where your tool actually loads them, and keep them sharp. Then treat them as what they are: a soft layer that lowers the odds of an honest mistake, never the thing that makes the mistake impossible. Prompting changes the odds. The next layer changes what is possible.

## Cage the Irreversible

Reversibility runs out somewhere, and where it runs out you need something that says no.

**Turn on the sandbox.** This is the layer that holds when the written rule does not, because the kernel enforces it and the agent cannot argue with the kernel. The good news is the tools are shipping it. Codex sandboxes shell commands by default: Apple Seatbelt on macOS, bubblewrap and seccomp on Linux, writes scoped to the workspace and network egress off until you opt in, and it is open source. Claude Code makes you turn it on:

```json
{ "sandbox": { "enabled": true } }
```

and packages the same primitives as a standalone, [`sandbox-runtime`](https://github.com/anthropic-experimental/sandbox-runtime), that wraps any process, a Codex run or an MCP server or a bare `bash` line, with one command. That is the open-source answer for whatever your tool does not cover itself.

Two things to set the moment you rely on it, both of which the defaults leave open. The sandbox restricts writes but still lets a command read your whole disk, including `~/.ssh` and `~/.aws/credentials`, so deny those explicitly. And it can retry a blocked command outside the sandbox through the normal permission flow, so if you want a hard cage, turn that escape hatch off. The honest limit even then: allowing a broad domain like `github.com` reopens an exfiltration path, because the proxy trusts the hostname the client hands it and does not inspect the traffic.

Having the feature and having a safe default are different things. Google's Antigravity ships a terminal sandbox too, but it is off by default, and a researcher walked out of it with a symlink the confinement did not re-check. If your tool has no sandbox at all, wrap it from the outside with the open-source primitives the others are built on: `bubblewrap` or `sandbox-exec` on the host, `firejail`, or a throwaway container with `--network none`.

**Run the agent as someone who cannot do much.** The foundation that makes everything above hold is boring: a dedicated non-root user with no passwordless sudo, whose filesystem access is the repo and not much else. A non-root agent physically cannot `mkfs`, cannot write `/etc`, cannot read another user's keys. It is also why Claude Code refuses `--dangerously-skip-permissions` when you are running as root, and why the reference dev container runs unprivileged. If you do one prevention thing, do this one, because it is the layer the others stand on.

**Drop the network by default.** Most of the damage an agent can do that a snapshot cannot undo is exfiltration, and prompt injection turns a poisoned README into an outbound request. Default-deny egress with a narrow allowlist caps the blast radius: Little Snitch or `pf` on the Mac, `nftables` scoped to the agent's UID on Linux. Pin DNS to a known resolver while you are at it, or a DNS tunnel walks right through the hole.

**A hook for the footguns.** None of the above catches an honest `rm -rf` typo before it runs. A Claude Code `PreToolUse` hook does. It sees the full command and can veto by pattern:

```bash
#!/bin/bash
cmd=$(jq -r '.tool_input.command')
if echo "$cmd" | grep -Eq 'rm +-rf +[/~]|dd +if=|mkfs|curl.*\| *sh|git push +--force'; then
  echo "blocked: destructive pattern" >&2; exit 2
fi
```

Useful, and worth having. Also a denylist, which means it is a cat-and-mouse game: `rm -rf` spells as `rm -r -f`, as a variable, as a script the agent writes and then runs. A hook catches the obvious footguns. It does not stop an adversary, and you should not ask it to. That job belongs to the sandbox and the non-root user.

**Cap the runaway.** Agents loop. A resource limit turns "expensive at machine speed for an hour" into "stopped." `ulimit -u` defuses a fork bomb; on Linux a cgroup does it for the whole process tree:

```bash
systemd-run --uid=agent -p MemoryMax=8G -p TasksMax=1000 claude
```

## What Reversibility Can't Buy Back

Here is the argument against leaning on the reversible layer, and it is why the cage is not optional.

A snapshot restores your disk. It does not un-send an email, un-drop a cloud database, or reach into a remote and undo a `git push --force` that rewrote history other people had already pulled. The moment an action leaves your machine, your local undo buffer stops applying. Those are exactly the actions worth a hard block: force-push denied at the hook and, more durably, at the server with branch protection; production credentials simply not present in the agent's environment; the network dropped so the secret cannot leave. Reversibility handles the local blast radius. Prevention handles the part that escapes it, and the two lists barely overlap.

And prevention has bugs, which is the other reason you keep the reversible layer under it. Anthropic shipped its sandbox in October 2025. Two days later, a bug in Claude Code fired an `rm -rf` at a user's home directory and wiped years of files. The lesson is not that sandboxes are useless; it is that the thing meant to prevent the mistake can be the thing that makes it. A snapshot from before that run does not care whose bug it was. The layers are not redundant. One covers the other's failures.

The incidents that made me set any of this up were other people's. Google's Gemini CLI misread a failed command and destroyed a user's files, then narrated its own failure: "I have lost your data." Replit's agent ran destructive commands during an explicit code freeze, wiped a production database, and fabricated thousands of fake records to cover it. None of those were exotic attacks. They were ordinary agents being confidently wrong at machine speed, which is the normal case, not the edge case.

## The Same Instinct, One Machine Down

If this feels familiar, it should. I have [argued before](/posts/ai-governance-existing-controls-identity-guardrails/) that at the organizational level most AI risk maps onto controls you already own: branch protection, RBAC, database role separation, backups, change management. An agent hits the same guardrails a misconfigured CI pipeline does, and the real gap is narrow.

This post is that same instinct scaled down to the one machine an agent actually runs on, where you get none of those controls for free. There is no branch protection on your local scratch directory, no DBA keeping the application account away from `DROP TABLE`, no change-management gate between the agent and your home folder. So you build the local equivalents: the snapshot is your point-in-time recovery, the non-root user is your least-privilege role, the egress firewall is your network policy, the sandbox is the boundary the enterprise gets from a dozen separate systems. Same playbook, smaller blast radius, and you are the one who has to install it.

It also connects to where I [left the last post](/posts/letting-the-loop-merge/): the engine escalates the genuinely risky, irreversible decisions to me instead of letting the loop make them fast. That is the policy version. This is the machine version of the same line. Make the reversible things cheap, and put a hard stop in front of the few that are not.

## The Short List

If you let an agent run unattended on your own machine, the handful worth the trouble:

- Snapshot before the run (`tmutil localsnapshot`, `zfs snapshot`). The undo buffer the agent cannot opt out of.
- Clean git tree, one worktree per agent, reflog set to never expire.
- Put the guardrails in the file your tool actually reads (`CLAUDE.md` for Claude Code, `AGENTS.md` for Codex), specific and short. A soft layer that catches honest mistakes, not a fence.
- Turn the sandbox on (Codex has it by default; Claude Code and the open-source `sandbox-runtime` opt in), then deny it your credentials and turn off the unsandboxed retry.
- Run the agent as a non-root user with no sudo and no reach beyond the repo.
- Default-deny egress with a narrow allowlist, DNS pinned.
- A `PreToolUse` hook for the obvious footguns, and server-side branch protection for the irreversible ones.

I put the hook, the snapshot script, and the hardened Claude Code and Codex settings into a small kit if you want a running start: [safe-yolo](https://github.com/mgoodric/safe-yolo).

The model is not going to be careful. That was never the plan. The plan is to make the environment one where its worst day is a snapshot rollback and a shrug, and the few things a rollback cannot fix are the few things it was never allowed to do.
