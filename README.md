# bridge.games — marketing website

The public front door for bridge.games: a single static page that pitches the
product and sends visitors into the app. No framework, no build step — edit the
files, deploy the folder.

```
index.html        the whole page
css/site.css      styles (palette/type inherited from the app's design tokens)
fonts/            Fraunces + Atkinson Hyperlegible, copied from the app's own
                  @fontsource packages (OFL-licensed, self-hosted)
images/           app screenshots (see provenance below) + favicon.svg + og-image
favicon.ico
```

## Preview locally

```sh
python3 -m http.server 8321
# http://127.0.0.1:8321/
```

Asset URLs are root-relative (`/css/...`, `/images/...`), so the site must be
served from a domain root (bridge.games apex) — not from a subpath.

## Deploying

Any static host works: Cloudflare Pages, Netlify, GitHub Pages (user/org page or
custom-domain project page — must end up at the domain root), or an nginx `root`
directive. There is no build step; publish the repo as-is.

DNS plan (2026-08-14): the apex `bridge.games` points at the external static
host (it cannot be served from the Mac — WAN 443 belongs to the Dinger API
host). The app lives at `https://app.bridge.games:5553`, which needs, in order:

1. Squarespace DNS: `A app.bridge.games → 162.202.3.68` — **before** moving the
   apex, so existing `bridge.games:5553` users have somewhere to land.
2. Cert SAN on the Mac: `certbot ... -d bridge.games -d app.bridge.games`
   (http-01 through the existing WAN-80 forward; the port-80 nginx server block
   needs `app.bridge.games` in its `server_name` for the ACME webroot). After
   the apex moves to the external host, renew with `-d app.bridge.games` only.
3. nginx `bridge-games.conf`: add `app.bridge.games` to the 5553 TLS server's
   `server_name`. Phoenix needs nothing while it runs dev mode
   (`check_origin: false`); the prod cutover must add app.bridge.games to
   `check_origin`.

## App links on the page

Every call to action points into the app. If the app's address ever changes
(e.g. dropping the port at the prod cutover), update these in `index.html`:

- `https://app.bridge.games:5553/register` — "Create your free account" (×2), "Play free"
- `https://app.bridge.games:5553/lobby` — "Open the lobby"
- `https://app.bridge.games:5553/login` — "Log in"

The footer/contact address is `hello@bridge.games` — the mailbox (or a forward)
has to exist before launch.

## Screenshot provenance

All app images are real screenshots of bridge.games taken 2026-08-14 on the
live server via a kibitzed bot table (`kibitzers_see_all` enabled so all four
hands show). To retake: create a table with four bots, kibitz it in a browser
at 1600×1000@2x, screenshot, crop. `images/og-image.jpg` is a 1200×630 crop of
the hero shot for link previews. The video-section "four corners" figure is a
CSS illustration (bots have no cameras), deliberately stylized rather than a
faked screenshot.

## Honesty guardrails for future copy

Don't claim: guest play without an account, bot difficulty levels (the two bots
differ in speed, not strength), video at tournament tables or on phones,
individual/team events (pairs only today), masterpoints or league sanctioning,
or password reset (not wired up yet).
