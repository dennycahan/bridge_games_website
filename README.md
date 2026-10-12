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
js/visit.js       GoatCounter's count.js, self-hosted (see "Visit counter")
favicon.ico       16/32/48 spade, same drawing as images/favicon.svg
apple-touch-icon.png  180×180, square (iOS rounds the corners itself)
robots.txt        allows everything, points at the sitemap
sitemap.xml       the three pages; bump a <lastmod> when its page changes
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
host (GitHub Pages); the Mac serves only the app. The app lives at
`https://app.bridge.games`, which needs:

1. Squarespace DNS: `A app.bridge.games → 104.52.87.186` — the Mac's own
   static address since the 2026-09-14 cutover (it was the house's dynamic
   162.202.3.68 before).
2. Cert on the Mac: `certbot ... -d app.bridge.games`, http-01 through the
   WAN-80 forward. (The lineage is still named `bridge.games` from the days
   it covered the apex too.)
3. nginx `bridge-games.conf`, which lives in the app repo
   (`deploy/nginx/`) and is installed by its `scripts/prod.sh nginx`. The
   app repo's `docs/hosting.md` is the runbook for the Mac side: ports, TLS,
   DNS. (The old `:5553` port was retired outright on 2026-09-14.)

## App links on the page

Every call to action points into the app, on its portless origin (moved off
`:5553` on 2026-09-14). If the app's address ever changes, update these in
`index.html`, `privacy.html` and `terms.html`:

- `https://app.bridge.games/register` — "Create your free account" (×2), "Play free"
- `https://app.bridge.games/lobby` — "Open the lobby"
- `https://app.bridge.games/login` — "Log in"

The footer/contact address is `hello@bridge.games` — the mailbox (or a forward)
has to exist before launch.

## Visit counter

Every page carries GoatCounter (the hosted service, free non-commercial tier).
The dashboard is `https://bridgegames.goatcounter.com` — visitors, pages,
referrers, countries, browsers, screen sizes; sign in with the account that
created it. It sets no cookies and stores no IP addresses, which is why the
privacy page can still say "no cookies". The privacy page discloses the
counter under "What we collect"; that disclosure stays as long as the snippet
does.

`js/visit.js` is GoatCounter's `count.js`, byte-for-byte below its header
comment. It is self-hosted so the page loads no third-party script (the
beacon to `bridgegames.goatcounter.com/count` is the only cross-origin
request) and renamed so generic `/count.js` adblock rules don't match it. It
is therefore pinned: if GoatCounter ever changes the script, fetch
`https://gc.zgo.at/count.js` again and replace everything below the header.
The snippet is the last thing before `</body>` on all three pages.

Sign-up clicks are GoatCounter events: every link to `/register` carries
`data-goatcounter-click`, named for where it sits — `signup-header`,
`signup-hero`, `signup-closing` on the home page, `signup-privacy` and
`signup-terms` on the doc pages. They show on the dashboard as their own rows,
and an event's referrer is the page visit's referrer (Bing, Google, …), so
each row tells you which source sent the people who clicked. A new link to
`/register` gets its own name; the privacy page says sign-up clicks are counted,
so tag no other kind of click without changing that sentence too.

Your own visits: open `https://bridge.games/#toggle-goatcounter` once and that
browser is excluded (a localStorage flag, per browser); or list addresses
under Settings on the dashboard. The script also skips localhost and private
addresses, so a `python3 -m http.server` preview sends nothing.

## Search

The site is verified in Google Search Console and Bing Webmaster Tools;
submit `https://bridge.games/sitemap.xml` to both. The queries that find us
(2026-10) are the searcher's words, not ours: "free bridge", "bridge for
free", "free bridge games no download", "play bridge online free against
computer". So:

- The `<title>` and meta description speak search ("Play Free Bridge Online
  — No Download", "against the computer"); `og:title`/`og:description` keep
  the brand voice ("real faces at the table") for link previews. Keep the
  description under 160 characters.
- The Alert section (`#faq`) answers those queries in plain text, which
  is most of what lets the page rank for them. Its answers sit under the
  honesty guardrails below like any other copy, and "Do I need an account?"
  stays yes until guest play exists.
- The JSON-LD in `index.html` is WebSite + Organization only, so Google shows
  "bridge.games" as the site name. There's no SoftwareApplication block on
  purpose: Google treats one without ratings as an error, and we have no
  ratings to give it.
- The favicon is a gold spade on felt, drawn for this site on 2026-10-12. The
  app still carries Vite's default lightning bolt in
  `frontend/public/favicon.svg`; the site no longer does.

## Screenshot provenance

All app images are real screenshots of the current bridge.games build,
retaken 2026-08-20 after the table/lobby redesign (auction pad + level→strain
bidding box, name bars, drawer dock, felt lobby cards). They were shot on an
isolated staging node running the production code against a **copy of the
live database**, so every score, field percentage, and traveller row is a
real club result; the staging boards and the throwaway database were deleted
after the shoot. The hero shot is a **seated player's own view**:
a temporary account ("Ellen") sat South with three bots, a script passed her
auctions and played her lowest legal cards over the channel until a board
mid-play with her on turn defending — her hand plus dummy, the gold your-turn
nameplate, the Claim/Undo command bar, and a genuinely scored drawer
("1 watching" is a real kibitzer, staged as "Margaret"). The two phone shots (`phone-table.jpg`, `phone-kibitz.jpg`) were retaken the
evening of the same day, after the phone table overhaul (the four-tile strip,
the auction band beneath it, dummy's cards on the felt) landed in app commit
`a538cc0`. Same pipeline, fresh run: an isolated worktree node
(`bridge_play-site`, port 4112) against a new same-day copy of the live
database (`BridgeDB_shoot2`), Ellen South with three bots at "The Card Room"
and Margaret the "1 watching" kibitzer; the table, node, database, and
worktree were torn down as soon as the shots were taken. `phone-table.jpg` is
Ellen's own view defending 2NT — dummy's cards fanned beside the trick, the
full auction beneath the strip. `phone-kibitz.jpg` is Margaret's view of a
later board at the same table: all four hands are face up because the table's
kibitzers-see-all setting (a captain's choice, on by default) allows it, and
the page's caption scopes the claim accordingly. The running-score
percentages in both are real field results from the copied database.

The captain-menu and
settings shots are the captain's own view at a forming table; the traveller
and replay panels are the drawer dock's own objects. `images/og-image.jpg` is
a 1200×630 crop of the hero for link previews. The video-section "four
corners" figure is a CSS illustration (bots have no cameras), deliberately
stylized rather than a faked screenshot.

## Honesty guardrails for future copy

The site says **beta** (the hero pill and the footer paragraph, added 2026-09-02),
and the app's lobby says the same thing in the same words. Keep the two in step:
drop both when Denny says the app has left beta, never one without the other.

Don't claim: guest play without an account, bot difficulty levels (the two bots
differ in speed, not strength), video on phones, individual movements (pairs
and team matches today — team matches shipped 2026-08, so the page may now say
so), masterpoints or league sanctioning, that kibitzers always see all four
hands (it's a per-table setting — scope any such claim to tables that allow
it), that media never touches our servers (it goes peer to peer where the
network allows and through our relay, still encrypted, where it doesn't — the
privacy page has said so since 2026-09-01), that a browser only ever holds its
own hand (dummy, a claim's responders, spectators at see-all tables, directors
and the Double Dummy bot all see more, by the rules and the table's settings),
or regularly scheduled house-run games (every event is player-hosted today;
Denny plans house games once built out — add them to the page only when they
actually run).

Do say, when the copy touches them: tournament voice and video are the
director's call (event switches, since 2026-08-18 — the tables are not
"silent on purpose"), and password reset ships (by email, since 2026-08).
