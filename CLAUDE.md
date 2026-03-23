# mattgoodrich.com

Personal blog. Hugo 0.140.1 with hugo-theme-stack, served via Docker/nginx.

## Git Conventions

This repo uses **release-please** for automated versioning. Commit messages MUST follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>
```

### Types
- `feat:` — New feature or new blog post (→ minor version bump)
- `fix:` — Fix content, broken links, rendering issues (→ patch version bump)
- `chore:` — Theme updates, config changes (no version bump)
- `docs:` — README updates (no version bump)
- `ci:` — CI/CD changes (no version bump)

### Rules
- After completing and verifying a task, create a commit with the appropriate prefix
- The description should explain **why**, not just what (the diff shows what)
- Keep the first line under 72 characters
- New blog posts use `feat: add post on <topic>`

### Deploy Flow
Push to main → release-please opens a Release PR → merge it → tag created → GH Actions builds Hugo + nginx Docker image → GHCR → Watchtower deploys on Unraid.

## Commands

```bash
hugo server          # Local dev server with live reload
hugo --gc --minify   # Production build
```

## Content

- `content/posts/` — Blog posts (markdown + frontmatter)
- `content/page/` — Static pages (about, archives, etc.)
- Theme loaded as git submodule: `themes/hugo-theme-stack`
