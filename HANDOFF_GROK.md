# Flame Sheet Sim — deployment handoff

You are deploying a finished, self-contained static web app. **Do not modify the
physics, the UI, or `index.html` unless something listed under "If it doesn't work"
applies.** Your job is only to put the files on a public URL and confirm the page
runs there exactly as it runs locally.

## What this is

An interactive three.js visualisation of a premixed flame sheet in a Hele-Shaw
channel (Ronney lab, USC). It renders a flame surface with wrinkling, cross-gap
tilt, local burning-rate colouring (Markstein curvature law), isothermal-wall
quench layers (Pe* based), a C² B-spline surface basis, and a real-time
G-equation simulation with a histogram of S_T/S_L. Everything runs in the
browser — there is no backend, no build step, no database, no API keys.

## Folder contents

```
flame_sheet_sim/
├── index.html               the entire app (HTML + CSS + JS, ~59 kB)
├── vendor/
│   └── three.r128.min.js    three.js r128 (UMD build, vendored — no CDN needed)
├── serve.sh                 one-line local preview (python http.server on :8000)
├── HANDOFF_GROK.md          this file
└── README.md                short user-facing description
```

`index.html` references exactly one local asset, `vendor/three.r128.min.js`,
via a relative path. The only external request is an optional Google Fonts
stylesheet (IBM Plex Sans / STIX Two Text); if it is blocked the page falls back
to system fonts and still works.

## Requirements of the host

- Static file hosting. That's it. Any of: GitHub Pages, Netlify, Vercel,
  Cloudflare Pages, S3 + CloudFront, nginx, Apache, `python -m http.server`.
- Must serve `.js` with a JavaScript MIME type (every host above does).
- No server-side rendering, no Node runtime, no build command. If a platform
  asks for a build command, leave it empty; the output/publish directory is the
  folder root (`.`).
- HTTPS is preferred (needed for the Google Fonts request on some browsers) but
  the page works over plain HTTP and even directly from `file://`.
- The folder root must stay intact: keep `index.html` and `vendor/` side by side.

## Deploy — pick one

### A. Netlify (fastest, no account config)
1. `npm i -g netlify-cli` (or use the web UI drag-and-drop at app.netlify.com/drop).
2. From inside this folder: `netlify deploy --prod --dir=.`
3. Open the printed URL.

### B. Vercel
1. `npm i -g vercel`
2. From inside this folder: `vercel --prod`
   - Framework preset: **Other**. Build command: *(empty)*. Output directory: `.`
3. Open the printed URL.

### C. GitHub Pages
1. Create a repo, copy this folder's contents to its root, commit, push.
2. Settings → Pages → Source: *Deploy from a branch*, branch `main`, folder `/ (root)`.
3. URL will be `https://<user>.github.io/<repo>/`.

### D. Cloudflare Pages
Direct upload: Workers & Pages → Create → Pages → Upload assets → drag this folder.

### E. Plain web server
Copy the folder to the document root. Nothing else to configure.

## Verify after deploying (do all four)

1. Page loads with a dark background, a 3-D wireframe channel with rings
   receding into the distance, a small identity card top-left (`S_T/S_L = …`),
   a colour-scale card top-right, and a control column on the right edge.
2. Open the browser devtools console: there must be **no errors** (a blocked
   `fonts.googleapis.com` request is acceptable; a 404 on
   `vendor/three.r128.min.js` is NOT — it means the `vendor/` folder was not
   uploaded or the path was rewritten).
3. Drag the *bulge height* slider: a single bump grows on the sheet. Drag
   *Markstein length* away from 0: the sheet colour changes. Set *heat loss*
   > 0: a dark band appears along the walls.
4. Press **Simulate**: the surface starts evolving, a histogram card appears
   bottom-left, and the `S_T/S_L` readout updates every frame. Press it again
   to stop.

If all four pass, report the URL and stop.

## If it doesn't work

- **Blank black page, console says `THREE is not defined`** → `vendor/` was not
  deployed or the host rewrote the script path. Re-upload the whole folder; do
  not change the `<script src="vendor/three.r128.min.js">` line.
- **Blank page, console says WebGL unavailable** → the viewer's browser or GPU
  has WebGL disabled. Nothing to fix on the server; test in desktop Chrome/Firefox/Safari.
- **Page renders but fonts look generic** → Google Fonts blocked; cosmetic only, ignore.
- **Host insists on a build step** → choose "Other"/"static", empty build
  command, output directory `.`. Do not add a bundler, framework, or package.json.
- **Host serves `index.html` but 404s the subfolder** → some drag-and-drop uploaders
  flatten folders. Zip the folder and upload the zip, or use the CLI route.

Do not: convert to ES modules, upgrade three.js, minify or "optimise" the HTML,
add analytics, add a service worker, split the file, or reformat the code. The
file is a finished research artefact and must stay byte-identical except for
the deployment itself.

## Credits

Benny Cohen, Combustion Physics Laboratory (Ronney group), University of
Southern California, 2026. Built for the PhD qualifying exam presentation.
