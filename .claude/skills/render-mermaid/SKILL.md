---
name: render-mermaid
description: Render a Hugo post's .mmd source to the matching diagram-<slug>.png using the site's canonical mermaid-cli invocation and editorial theme. Source and PNG live side-by-side in the post directory and are both committed. USE WHEN render mermaid, mermaid to image, mermaid to png, diagram from mermaid, build diagram, blog diagram, regenerate diagram, /render-mermaid.
---

# render-mermaid

Render a mermaid diagram for a mattgoodrich.com Hugo post to a PNG that sits next to its `.mmd` source in the post directory. The editorial theme (Atlantic / New Yorker register, paper-cream background, deep purple ink) is encoded **inside** each `.mmd` source via a `%%{init}%%` directive, so every render uses the same tool and the same flags — what varies is the diagram, not the look.

Codified from the existing pattern: 60 `.mmd` sources paired 1:1 with 60 `diagram-*.png` outputs across `content/posts/`, all sharing the canonical theme block.

## Inputs

- **Path to a `.mmd` source file** sibling to a post's `index.md`, e.g. `content/posts/<post-slug>/diagram-<slug>.mmd`.
- **OR an inline mermaid block extracted from a Hugo post** plus the target post slug. In that case, write the block to `content/posts/<post-slug>/diagram-<slug>.mmd` first (the source must exist on disk and be committed — there is no "render from string" path on this site).

The source file MUST start with the canonical `%%{init}%%` directive (see "Design traits (canonical)" below). If it doesn't, refuse to render and surface that — consistency with the existing 59 diagrams is the point. Don't silently inject the theme; flag the missing block so Matt fixes the source.

## Outputs

- A PNG at `content/posts/<post-slug>/diagram-<slug>.png`, same basename as the source, same directory.
- Returns the **relative path** for the post's markdown reference: `diagram-<slug>.png` (Hugo resolves it against the post's directory).
- A short status line: source path, output path, output dimensions, render seconds.

## Workflow

### Step 1 — Resolve the source

Accept either a path or a (post-slug, inline-block) pair. If inline, write the block to the canonical filename first; never render a block that isn't on disk under the post directory.

Confirm:
- File extension is `.mmd` (NOT `.mermaid` — that's a single legacy outlier this skill does not touch).
- File lives sibling to an `index.md` under `content/posts/<post-slug>/`.
- Filename matches `diagram-<kebab-slug>.mmd`.
- First non-blank line is the canonical `%%{init}%%` directive (verbatim — see below). If missing or modified, stop and surface it.

### Step 2 — Resolve the output path

`<source-dir>/<source-basename>.png`. If the PNG already exists, **stop and ask Matt** whether to overwrite — never silently replace a committed diagram. (The exception is a test render to `/tmp/`, which has no committed counterpart.)

### Step 3 — Invoke the canonical render command

Run, from inside the post directory or with a full path to the source:

```
npx -y -p @mermaid-js/mermaid-cli mmdc -i diagram-<slug>.mmd -o diagram-<slug>.png -w 1568 -b '#FBF7EE'
```

Flag-by-flag:

- `npx -y -p @mermaid-js/mermaid-cli mmdc` — the tool. `npx -y -p <pkg>` fetches and runs `@mermaid-js/mermaid-cli` on demand without a global install; the `-p` form is what makes `npx -y` resolve the binary name `mmdc` against that package. No `package.json` or local install required.
- `-i <source>.mmd` — input.
- `-o <source>.png` — output, same basename.
- `-w 1568` — width. This is the canonical max-width that anchors the recent diagrams (e.g. `diagram-jml-lifecycle.png` at 1568x242). Mermaid still auto-sizes content within that ceiling, so narrower diagrams come out narrower — passing `-w 1568` is not a hard rectangle.
- `-b '#FBF7EE'` — background fill, the paper-cream that matches `tertiaryColor` / `clusterBkg` in the in-source theme. Belt-and-suspenders with the init block, so PDF tools that ignore SVG `<rect>` backgrounds still land on the correct color.

Do NOT pass `-t` / `--theme`. **The theme lives in the `.mmd` init block, not on the CLI.** Setting `-t` here would override the source's themeVariables and break the editorial look.

### Step 4 — Verify

- Exit code 0.
- Output PNG exists at the expected path, non-zero size, decodable.
- If `file` or `sips -g pixelWidth -g pixelHeight` is available, capture dimensions for the status line.

On render failure, surface stderr verbatim and stop. Do not retry with different flags — diverging from the canonical command is what this skill exists to prevent.

### Step 5 — Return

Print the relative-path embed and the status block:

```
[OK] Rendered

Source:  content/posts/<post-slug>/diagram-<slug>.mmd
Output:  content/posts/<post-slug>/diagram-<slug>.png  (<W>x<H>, <KB> KB)
Embed:   ![<descriptive alt text>](diagram-<slug>.png)
Render:  npx -y -p @mermaid-js/mermaid-cli mmdc -i diagram-<slug>.mmd -o diagram-<slug>.png -w 1568 -b '#FBF7EE'
```

The skill does NOT commit. The composing skill (typically `draft-post` or a follow-up edit step) stages and commits both the `.mmd` and the `.png` together.

## Design traits (canonical)

These are the invariants every diagram on mattgoodrich.com follows. Encoded verbatim from the OE-33 survey.

- **Source extension:** `.mmd` (sibling to the post's `index.md`).
- **Filename convention:** `diagram-<kebab-slug>.mmd` and matching `diagram-<kebab-slug>.png`. Slug describes the diagram's content (e.g. `diagram-relationship-graph`, `diagram-schema-migration`, `diagram-jml-lifecycle`).
- **Output format:** PNG, 8-bit RGB. Solid background (no alpha channel).
- **Background color:** `#FBF7EE` — paper-cream. Passed on the CLI via `-b '#FBF7EE'` AND set inside the source as `themeVariables.tertiaryColor` / `clusterBkg`.
- **Dimensions:** Mermaid auto-sizes within a max width of `-w 1568`. Observed range: 482x920 (tall narrow flow) to 1784x122 (wide horizontal banner). No fixed height; no upscaling.
- **Markdown reference in `index.md`:** `![<long descriptive alt-text>](diagram-<slug>.png)` — alt-text is genuinely descriptive, often a full sentence describing what the diagram shows (see `content/posts/your-authorization-model-is-never-done/index.md` for canonical examples).
- **Mermaid theme directive (must be the first non-blank line of every `.mmd`):**

  ```
  %%{init: {'theme':'base','themeVariables':{'fontFamily':'Georgia, serif','primaryColor':'#ECE4F2','primaryBorderColor':'#5B2A86','primaryTextColor':'#2D2D2D','lineColor':'#3A3A3A','secondaryColor':'#F6E7D2','tertiaryColor':'#FBF7EE','clusterBkg':'#FBF7EE','clusterBorder':'#B5A98E','edgeLabelBackground':'#F4EEE2'}}}%%
  ```

  Palette:
  - `fontFamily: 'Georgia, serif'` — serif body, not the mermaid default sans
  - `primaryColor: '#ECE4F2'` — pale lavender (node fill)
  - `primaryBorderColor: '#5B2A86'` — deep purple (node stroke)
  - `primaryTextColor: '#2D2D2D'` — near-black (text on nodes)
  - `lineColor: '#3A3A3A'` — charcoal (edges)
  - `secondaryColor: '#F6E7D2'` — warm cream (secondary nodes)
  - `tertiaryColor: '#FBF7EE'` — paper white (tertiary / background-feeling fills)
  - `clusterBkg: '#FBF7EE'` — subgraph background (matches paper)
  - `clusterBorder: '#B5A98E'` — soft tan (subgraph stroke)
  - `edgeLabelBackground: '#F4EEE2'` — light cream behind edge labels

This palette matches the editorial illustration aesthetic the rest of the site uses (header art, etc.). Don't drift from it without changing it everywhere.

## Composition

Other skills invoke `render-mermaid` rather than calling `mmdc` directly. Example call sites:

- **`draft-post`** — when a new post needs a diagram, scaffold the `.mmd` source (with the canonical init block) under the post directory, then call `Skill('render-mermaid', { source: 'content/posts/<slug>/diagram-<name>.mmd' })`. The returned embed line drops into the body.
- **Manual diagram refresh** — when Matt edits a `.mmd` after publish, re-render via `Skill('render-mermaid', ...)` against the existing source. The skill prompts before overwriting the PNG (Step 2 above).
- **Future diagram-aware skills** — anything that produces a `.mmd` for a post on this site composes through this skill instead of duplicating the render invocation. One canonical path means one place to update if the tool, theme, or flags change.

Conceptual call shape (the literal API depends on the host harness):

```
Skill('render-mermaid', {
  source: 'content/posts/your-authorization-model-is-never-done/diagram-relationship-graph.mmd'
})
# returns: { output: 'diagram-relationship-graph.png', width: 694, height: 518 }
```

## Boundaries

- **Never modify the source `.mmd`.** This skill reads and renders; if the init block is missing or off-canonical, it stops and reports — it does not patch.
- **Never overwrite an existing committed `.png` without confirmation.** Test renders go to `/tmp/`; in-tree renders prompt before replacing.
- **Never commit.** The composing skill (draft-post / approve-post / manual) stages and commits the `.mmd` + `.png` pair together.
- **Never install tools or modify global state.** `npx -y -p @mermaid-js/mermaid-cli` fetches into the npm cache on demand; nothing is written to the repo, no `package.json` is created, no global install is added. If `npx` itself is not on PATH on a given machine, surface that as a missing dependency — do not fall back to a different renderer.
- **Never pass `-t` / `--theme` on the CLI.** The theme is sourced from the `.mmd` init block. CLI theme flags would override and break the look.
- **Never touch the single `.mermaid` legacy file** at `content/posts/hardest-part-of-security/vuln-management-complexity.mermaid`. It pre-dates the canonical style and uses a different shape; leave it alone.
- **Never push, deploy, or open PRs.** Local file changes only.
