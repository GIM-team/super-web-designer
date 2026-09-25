---
name: visual-check
description: Screenshot a web page or local dev server at desktop (1440) and mobile (390) width with Playwright and flag broken states (non-200, JS errors, horizontal scroll on mobile). Use after any frontend or design change, before saying a UI is done, or when the user asks to "see", "screenshot", "check on mobile" or visually verify a page. Pairs with impeccable, design-taste-frontend and emil-design-eng, which all require looking at the rendered result.
---

# Visual check

Look at what you built before you call it done. Code that compiles can still ship a
broken mobile layout, an invisible button or a font that never loaded.

## Run

1. Start the project's server (`npm run dev`, `npm run preview`, `python -m http.server`, …)
   and note its URL. For a static build, serve the build output, not the source.
2. From the project root:

   ```bash
   node "${CLAUDE_SKILL_DIR}/scripts/shots.mjs" --base http://127.0.0.1:4321 / /pricing/
   # or full URLs:
   node "${CLAUDE_SKILL_DIR}/scripts/shots.mjs" https://example.com/
   ```

   `${CLAUDE_SKILL_DIR}` is the folder that contains this SKILL.md.
   Output: `shots/<route>-desktop.png` and `shots/<route>-mobile.png` (full page),
   plus one status line each. Exit code 1 if any page returned non-2xx, threw a JS error,
   or scrolls horizontally on mobile.
3. **Open the PNGs with the Read tool and actually look at them.** Check hierarchy, spacing,
   overflow, contrast, images, fonts and the first viewport on mobile.
4. Fix everything in one batch, re-run once, stop. Don't loop on micro-polish.

Add `shots/` to `.gitignore` if the project doesn't ignore PNGs already.

## Browser resolution

- Uses the project's own `playwright` / `playwright-core` if installed; otherwise installs
  `playwright-core` once into `~/.cache/visual-check` (no browser download).
- Browser: Claude Code cloud sandbox Chromium under `$PLAYWRIGHT_BROWSERS_PATH`
  (`/opt/pw-browsers`) → a Playwright-managed browser → system Chrome.
  **Never run `playwright install`** in the cloud sandbox; Chromium is already there.
- `--reduced-motion` is on by default so screenshots don't catch half-finished animations.
  Pass `--motion` to test with animations running.

## Project rules win

This skill only observes. The project's CLAUDE.md decides stack, fonts and brand.
