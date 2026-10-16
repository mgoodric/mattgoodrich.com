+++
date = '2026-07-24T00:01:00-07:00'
draft = true
title = "Securing Code You Didn't Write"
aliases = []
description = "I've been building security-atlas for the better part of a year, and almost none of the code is mine. When an agent writes at that speed, the question stops being whether it works and becomes whether it's safe to ship. Here's the free tooling that catches the problems on GitHub, GitLab, and your own server, what can fix them automatically, and the point where it's finally worth paying a vendor."
categories = ['Security', 'AI']
tags = ['AI', 'AppSec', 'GitHub', 'Open Source', 'DevSecOps']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

I've been building [security-atlas](https://github.com/mgoodric/security-atlas) for the better part of a year. It's a security program in a box, aimed at teams standing everything up from scratch, and almost none of the code was typed by me. An agent writes it, I review the shape of it, and it ships.

When code arrives that fast, the question changes. "Does it work" gets answered by the test suite. "Is it safe" doesn't answer itself. I'm not reading every line the way I would if I'd written it by hand, so the scanning has to do the reading I'm not doing. The good news is that for a public repo, almost all of that scanning is free. The better news is that when the free tooling isn't enough, you can usually name the exact reason you've outgrown it.

Here's the stack I'd actually turn on, in the order I'd turn it on, and the point where I'd start paying for something.

## Public or private is the real free line

Most people think GitHub security is a paid product. Most of it is free, if your repo is public. `security-atlas` is public, so I get secret scanning, push protection, CodeQL code scanning, and Copilot Autofix without paying anything. The bill starts when the repo goes private.

One myth to kill first, because it changes the whole calculation: secret scanning and push protection did **not** become free for private repos. What GitHub shipped for organizations in 2025 is a one-time "secret risk assessment," a point-in-time scan that tells you your exposure. That isn't continuous protection, and it isn't push protection. On a private repo on a free plan, the only security tooling that carries over from the public experience is Dependabot and the dependency graph. Everything else moves behind a paid SKU.

| Feature | Public repo | Private repo | Needed for private |
|---|---|---|---|
| Dependency graph | Free | Free | Nothing |
| Dependabot alerts + security updates | Free | Free | Nothing |
| Secret scanning + push protection | Free, default on | Paid | GitHub Secret Protection |
| CodeQL code scanning | Free | Paid | GitHub Code Security |
| Copilot Autofix | Free | Paid | GitHub Code Security |
| Dependency review action | Free | Paid | GitHub Code Security |

Keep that table in mind for the rest of this. If your repo is public, you get the whole first half of this post for nothing. If it's private, you get Dependabot for nothing and a decision to make about the rest.

## Turn on what GitHub already gives you

For a public repo this is the highest-value 20 minutes you'll spend. None of it requires a new tool, an account, or a CI file.

**Secret scanning and push protection.** Both are on by default for public repos. Push protection is the one that matters most: it blocks the commit that contains a live-looking key *before* it reaches the remote, so you're rotating a secret you never actually leaked instead of one that's now in the git history forever. An agent that pastes a config example with a real token in it is exactly the failure this catches.

**Dependabot.** Turn on alerts, security updates, and version updates. Security updates open a pull request that bumps a vulnerable dependency to the patched version. Version updates keep the routine bumps flowing so you're not 40 releases behind when a CVE lands. This is the one piece that's free on private repos too, so there's no reason not to run it anywhere. The one gotcha: on a private repo the dependency graph has to be enabled before alerts work. On public it's already on.

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      python-deps:
        patterns: ["*"]
```

Grouping matters more than it looks. Without it, a quiet week produces eight separate PRs and you start rubber-stamping them, which is how a bad bump sneaks through. Grouped, it's one PR your tests run against once.

**CodeQL.** Use default setup. It's one click in the Security tab, GitHub picks the languages, and you get code scanning on every PR. Advanced setup exists if you need to customize the query suite, but default is the right starting point and it's the one I run on `security-atlas`.

**Dependency review action.** This one blocks a PR that introduces a newly vulnerable dependency, by diffing the dependency graph on the PR itself. It's the difference between finding out about a bad dependency next week and refusing it at the door.

## The scanners GitHub doesn't run

CodeQL is good, but it's one engine with one point of view. External tools catch patterns it doesn't, run where you want them (at commit time or in CI), and let you write rules specific to the mistakes your agent keeps making.

**Semgrep** is the one I'd add first. The Community Edition is free, runs offline, and takes custom rules in a readable pattern syntax, which means you can encode "never do this specific thing" as a rule the moment you catch the agent doing it once. One honest note: Semgrep relicensed in 2024 and moved cross-file dataflow analysis behind its paid platform, so the free engine analyzes one file at a time. A community fork, OpenGrep, restored the cross-function analysis under a permissive license if you want the original open version. For most single-file pattern rules, Community Edition is plenty.

**Secrets, again, from outside GitHub.** Two tools, different jobs. Gitleaks is a fast regex-and-entropy scanner that's ideal as a pre-commit block because it fails in milliseconds and works offline. TruffleHog goes the other way: it *verifies* secrets by making a safe read-only call to see whether the credential is actually live, so `--only-verified` in CI fails the build only on secrets that still work. I run gitleaks at commit time and TruffleHog against history.

**Dependencies, containers, and IaC.** Trivy is the one-binary option: it scans language dependencies, container images, Terraform and Kubernetes misconfigurations, and secrets, all from a single tool. OSV-Scanner (from Google) is the tighter dependency-only choice, matching lockfiles against the OSV database with per-ecosystem precision. Either one covers the supply-chain layer.

Then the language-specific SAST, matched to whatever the repo is mostly written in:

| Language | Code (SAST) | Dependencies | Secrets |
|---|---|---|---|
| Python | Bandit, or Ruff's `S` rules | pip-audit, OSV-Scanner | Gitleaks, TruffleHog |
| JavaScript / TypeScript | eslint-plugin-security | `npm audit`, OSV-Scanner | Gitleaks, TruffleHog |
| Go | gosec | govulncheck (official) | Gitleaks, TruffleHog |
| Ruby / Rails | Brakeman | bundler-audit | Gitleaks, TruffleHog |
| Rust | Semgrep | cargo-audit, cargo-deny | Gitleaks, TruffleHog |
| Java / JVM | Find Security Bugs | OWASP Dependency-Check | Gitleaks, TruffleHog |
| Polyglot | Semgrep | Trivy, OSV-Scanner | Gitleaks + TruffleHog |

The cheapest place to run all of this is a pre-commit hook, mirrored in CI so it can't be skipped. The `pre-commit` framework wires gitleaks, Bandit, gosec, and the rest into local commits, and the same config runs in a GitHub Actions job with `pre-commit run --all-files`. Local catches it before it's pushed; CI catches it when someone runs `git commit --no-verify`.

## GitLab draws its free line somewhere else

Everything in that external section is portable. Semgrep, gitleaks, TruffleHog, Trivy, and OSV-Scanner are CLIs, not GitHub features. The only GitHub-specific part is the `uses:` wrapper in a workflow file; the tool underneath is a binary you can call from GitLab CI, Jenkins, or a shell script. Nothing is lost by running them somewhere other than GitHub Actions.

GitLab is worth its own paragraph because it bundles those same open-source tools and puts its free-versus-paid boundary in a different place than GitHub. GitHub's boundary is public versus private. GitLab's boundary is the scanner versus the dashboard.

On the Free tier, GitLab.com gives you unlimited public and private repos, 400 CI/CD compute minutes a month, and up to five users on a private namespace. Within that, several scanners run and produce reports:

| GitLab feature | Free tier | Engine |
|---|---|---|
| SAST | Runs, emits reports | Semgrep, SpotBugs (open source) |
| Secret Detection + push protection | Runs | Gitleaks-based |
| Container Scanning | Runs, emits SBOM | Trivy |
| IaC Scanning | Runs | KICS |
| Dependency Scanning | Ultimate only | Gemnasium |
| DAST | Ultimate only | ZAP-based |
| Security dashboard + MR vuln widget | Ultimate only | — |

On Free you can run the scanners and get their raw JSON or SARIF output, but the layer that makes findings usable is Ultimate: the security dashboard, the merge-request widget that shows new-versus-existing vulnerabilities, and the vulnerability workflow. You get the detection for free and pay for the triage. GitLab's cross-file "Advanced SAST" is also Ultimate and proprietary, separate from the free Semgrep-based analyzer, so cross-function analysis isn't in the free tier there either.

One thing GitLab does that's worth knowing if `security-atlas` lived there: the GitLab for Open Source program grants full Ultimate plus 50,000 compute minutes a month, free, to namespaces where every project is OSI-licensed and public. That's the entire paid feature set at no cost, with the same public-repo condition GitHub makes by default, just applied through an application instead.

## Self-hosting means owning the aggregation

Run your own git server and the calculation changes again. Gitea and Forgejo, the common self-hosted options, have no built-in Dependabot, no secret scanning, and no vulnerability dashboard. There's nothing to turn on. What they do have is Actions support that reads the same workflow YAML as GitHub, built on the same underlying runner, so the portable CLIs run the way they would anywhere. You reference third-party actions by full URL instead of a marketplace shortname, and otherwise a scan job looks identical.

Two gaps are yours to fill. The first is automated dependency updates. Dependabot is effectively GitHub-only, so the answer everywhere else is Renovate: self-hostable, open source, and runs against GitHub, GitLab, Gitea, Forgejo, Bitbucket, and Azure DevOps. It's the same tool I'd reach for on GitHub when I want more control than Dependabot gives, and it's the only real option once you leave.

The second gap is aggregation, and it's the one people underestimate. What you lose leaving a managed platform isn't the scanning, it's the place all the findings land. Gate on CI pass/fail and you've covered the block-the-bad-change job. If you want a queue to triage across tools, you run one yourself, something like DefectDojo that ingests SARIF from every scanner into a single view. That's the piece GitHub's Security tab and GitLab Ultimate's dashboard were doing for you, and it's the real cost of self-hosting a security program: not the tools, the operation.

## Catch, fix, gate

Detection is only the first of three jobs. **Catch** the problem, **fix** it, **gate** what merges. Free tooling now covers all three, and the third one is the one people skip.

The fix layer has a safe end and a risky end. Dependency bumps are the safe end: Dependabot and Renovate open a reviewable PR that changes a version number, your tests confirm nothing broke, and low-risk patches can auto-merge. Renovate adds one thing worth having, a `minimumReleaseAge` cooldown that holds a brand-new release for a few days before proposing it, which is a cheap defense against a dependency that got compromised yesterday.

Code fixes are the risky end. Copilot Autofix (free on public repos) reads a CodeQL alert and suggests a diff. Semgrep can carry a `fix:` in the rule and apply it with `--autofix`. Both are useful, and both need a human on the diff, because a model rewriting logic it never authored can produce a fix that closes the alert and introduces a different bug.

That's where the gate does the work:

```yaml
# auto-merge only patch-level Dependabot PRs, and only if checks pass
- uses: dependabot/fetch-metadata@v2
  id: meta
- if: steps.meta.outputs.update-type == 'version-update:semver-patch'
  run: gh pr merge --auto --squash "$PR_URL"
  env:
    PR_URL: ${{ github.event.pull_request.html_url }}
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

The rules that make auto-fix safe are the same whether a person or an agent wrote the code, but they're non-negotiable when it's an agent: a real test suite as a required check, because tests are the only thing verifying an automated fix didn't change behavior; auto-merge scoped to patch and maybe minor, with majors always going to a human; and code fixes staying as draft PRs while only dependency patches merge on their own.

One more thing the gate has to account for: the remediation tool is itself attack surface. The Claude Code GitHub Action had a disclosed vulnerability chain last month, indirect prompt injection leading to environment-variable exfiltration and repo write access, fixed in `claude-code-action` v1.0.94. The lesson generalizes to any AI agent you wire into CI. Pin the version, run it with least privilege, scrub secrets from anything it can read, and never let it push to a protected branch. An agent that can fix your code can also be talked into doing something else with the same access.

## When it's worth paying

The free floor is high on a public repo. I'd resist paying for anything until I hit one of these lines, and then I'd pay without hesitating.

**You go private.** This is the big one, and it's abrupt. The moment `security-atlas` went private, secret scanning, push protection, CodeQL, and Autofix would all stop being free, and only Dependabot would carry over. GitHub's paid pieces are Secret Protection at $19 per active committer per month and Code Security at $30, both requiring Team or Enterprise. For a five-person team that's a few hundred dollars a month for the exact protection you had for free a day earlier. It's worth it, but know that going private is the event that flips the bill, not scale.

**You need cross-file analysis.** Semgrep Community Edition reads one file at a time. If your vulnerabilities live across function and file boundaries, taint flowing from an input in one module to a sink in another, that's a real reason to pay for Semgrep's interprocedural analysis or to run OpenGrep. Single-file rules won't see it.

**You need reachability.** Not every vulnerable dependency is actually exploitable in your code path. `govulncheck` gives Go this for free by reporting only vulnerabilities in functions you actually call. For other languages, the paid supply-chain tools that add reachability are worth it specifically because they cut the alert volume, and a quieter queue is one you actually work.

**Triage is eating the team.** At some point the constraint stops being detection and becomes the volume of findings. When you're paying a person's afternoons to deduplicate and route alerts across five tools, you're paying for a dashboard whether you buy one or not. That's when a consolidated platform is cheaper than the status quo.

None of these is "you should have bought security tooling from day one." Each is a specific line you cross. Until you cross one, the free stack is the floor, and the floor is high.

For a public repo written mostly by an agent, the free tooling is enough. As long as I keep the gate honest.
