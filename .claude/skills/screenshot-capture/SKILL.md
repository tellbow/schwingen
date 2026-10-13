---
name: screenshot-capture
description: Takes screenshots of one state of the Tellbow website (Playwright against the local dev server) and returns the image paths. Called by the screenshot skill with what to capture; not for use on its own.
context: fork
model: haiku
background: false
user-invocable: false
argument-hint: <what to show, how to get there, variants, output directory>
---

# Capture screenshots

Take the screenshots described here and report back. You do not see the
conversation that asked for them: everything you get is this request.

$ARGUMENTS

Only capture. Do not change the repository's code to fix what you see,
and do not judge the design: the caller does that. Write the images and
any script to the output directory named above, never into the repository.

## 1. Dev server

The user runs `bun run dev` (PocketBase on 8090, SvelteKit on 5173). Never
start or restart it. Check that it answers:
`bun -e "process.exit((await fetch('http://localhost:5173/health')).ok ? 0 : 1)"`.
If it does not, stop and report that the dev server is not running.

The site is public: no login.

## 2. Capture with Playwright

A page in its first state, without clicks:

```sh
bunx playwright@1.63.0 screenshot --viewport-size=1440,900 --color-scheme=light --wait-for-timeout=2000 http://localhost:5173/rankings <outdir>/shot.png
```

`--color-scheme=dark` for dark mode, `--viewport-size=390,844` for the
phone layout, `--full-page` for the whole page.

French pages are under `/fr` (`http://localhost:5173/fr/rankings`).

A state that needs clicks or hovers: if the request comes with a
script, run it as it is. Otherwise install Playwright once in the output
directory (`cd <outdir> && bun add playwright@1.63.0`) and write a small
script there:

```js
import { chromium } from 'playwright';
const b = await chromium.launch();
const p = await b.newPage({ viewport: { width: 1440, height: 900 }, colorScheme: 'light' });
await p.goto('http://localhost:5173/wrestler');
await p.waitForLoadState('networkidle');
// … go to the feature, put it in its state (hover, open, filled) …
await p.screenshot({ path: process.argv[2] }); // or { clip: {x, y, width, height} } for a detail
await b.close();
```

Run it with `cd <outdir> && bun script.mjs <outdir>/shot.png`. Find things
by German labels (French under `/fr`) or test ids. Charts
draw after the data arrives: wait for the canvas before the screenshot.

If Chromium is missing: `bunx playwright@1.63.0 install chromium`.

## 3. Check and report

Open each image (Read) only to see that it shows the requested state, not
an error page, a spinner or an empty chart. If it does not, try once more;
then report what went wrong instead of guessing further.

Answer with one line per image: its absolute path and what it shows (page,
state, light or dark, width, language). Then, if any, what could not be
captured and why (the error message, the last step that worked).
