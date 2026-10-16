# mattgoodrich.com

Personal blog. Hugo with hugo-theme-stack, hosted on GitHub Pages.

## Branch Model (CRITICAL)

| Branch | Purpose | Deploys to |
|--------|---------|-----------|
| `hugo-main` | **PRODUCTION**, the default branch | GitHub Pages, via `.github/workflows/hugo.yaml` |
| anything else | Drafts and work in progress (e.g. `drafts/fall-2026`) | Nothing |

**A push to `hugo-main` is a live deploy.** Never force-push, rebase, or reset it, and never
delete or weaken `hugo.yaml`. The same workflow also rebuilds `hugo-main` daily at 3am Pacific
and on manual dispatch, so anything merged there goes live on the next build even without a push.

Work on a branch and open a PR into `hugo-main`. PRs run the same Hugo build to validate,
and the deploy job is skipped for `pull_request` events.

Posts with `draft = true` are excluded from the production build, but keep unpublished work
off `hugo-main` anyway. A flipped flag would ship it on the next nightly run.

There is no self-hosted build any more. The old `selfhost` branch, Docker image, release-please
pipeline, and Watchtower deploy are retired. Ignore any reference to them.

## Git Conventions

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>
```

- `feat:` new post or feature (`feat: add post on <topic>`)
- `fix:` content fixes, broken links, rendering issues
- `chore:` theme updates, config, dependency bumps
- `docs:` README and repo docs
- `ci:` workflow changes

Keep the first line under 72 characters, and explain why in the body.

## Commands

```bash
hugo server          # Local dev server with live reload (add -D to show drafts)
hugo --gc --minify   # Production build
```

CI pins the Hugo version in `hugo.yaml` (`HUGO_VERSION`). Match it locally when a build differs.

## Content

- `content/posts/<slug>/index.md` is a page bundle, with images beside it
- `content/page/` holds static pages (about, archives, etc.)
- The theme is a git submodule at `themes/hugo-theme-stack`
- Project skills live in `.claude/skills/`: `draft-post`, `approve-post`, `render-mermaid`
