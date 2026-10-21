# bridge.games — marketing website

The public front door for bridge.games: a static home page and a page for
clubs that pitch the product and send visitors into the app, plus the privacy
and terms pages. No framework, no build step — edit the files, deploy the
folder.

```
index.html        the home page
clubs.html        /clubs: for organisers moving a whole club online
privacy.html, terms.html   the doc pages
css/site.css      styles (palette/type inherited from the app's design tokens)
fonts/            Fraunces + Atkinson Hyperlegible, copied from the app's own
                  @fontsource packages (OFL-licensed, self-hosted)
images/           app screenshots (see provenance below) + favicon.svg +
                  og-image.jpg and og-clubs.jpg (link previews)
js/visit.js       GoatCounter's count.js, self-hosted (see "Visit counter")
js/zoom.js        tap a screenshot to enlarge it (see "Screenshots enlarge")
favicon.ico       16/32/48 spade, same drawing as images/favicon.svg
apple-touch-icon.png  180×180, square (iOS rounds the corners itself)
robots.txt        allows everything, points at the sitemap
sitemap.xml       the four pages; bump a <lastmod> when its page changes
7f195cac….txt     IndexNow key (see "Search"); public by design, keep it
scripts/indexnow.sh, .github/workflows/indexnow.yml   IndexNow pings
```

## The home page, in order

Reworked 2026-10-21 around one idea, *your new home for bridge*: any level
can play here, it is free, it is open all day and all night, and you are in
control (your table, your tournament, public or private). Card size and the
"real faces" video pitch were deliberately demoted to a bullet and a section
respectively.

1. Hero: "Your new home for bridge." and one paragraph.
2. The free band: no subscriptions, no add-ons, no payments of any kind.
3. **1♣** the six-card grid. Each card is a link to the section that
   explains it, in the same order: play at any hour (**1♦**, bots), your own
   table (**1♥**), talk to your table (**1♠**), tournaments (**1NT**), replay
   any hand (**2♣**), clubs (**2♦**). Keep the grid and the sections in step.
4. The signed note from Denny ("From the dealer"): built by a bridge player,
   for bridge players. Denny's words; change them only with Denny.
5. **2♥** how to start, then **Alert** for the questions, then the closing.

The bid cards walk up the auction in bridge order, one step a section
(1♣ 1♦ 1♥ 1♠ 1NT 2♣ 2♦ 2♥ …). Never skip a step, never repeat one; a new
section takes the next bid and everything after it moves up.

Type is large on purpose (20px body on a desktop, 18px on a phone, captions
in the body face at 16px): many of the people who play are older. Don't
shrink it to fit something in.

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
`index.html`, `clubs.html`, `privacy.html` and `terms.html`:

- `https://app.bridge.games/register` — "Create your free account" (×2 on each
  of the home and clubs pages), "Play free" (every header)
- `https://app.bridge.games/lobby` — "Open the lobby" (home hero)
- `https://app.bridge.games/login` — "Log in" (home and clubs headers; shown on
  phones too since 2026-10-21 — it used to be hidden under 620px)
- `https://app.bridge.games/clubs` — "Start your club in the app" (clubs hero,
  for people already signed up: the app's club directory, with its Create a
  club button)

The clubs page sends a newcomer to `/register`, not `/clubs`: there is no
account yet, and the app has no "after signing up, go to" parameter, so step 2
of the page says where Clubs is. Note the app's own Create-a-club dialog prints
a club's address as `bridge.games/club/<handle>`, which this site does not
serve (the app does, at `app.bridge.games/club/<handle>`); a `404.html`
forwarder is the open question in the 2026-10-21 plan.

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
The snippet is the last thing before `</body>` on all four pages (`js/zoom.js`
loads just before it on the home and clubs pages).

Sign-up clicks are GoatCounter events: every link to `/register` carries
`data-goatcounter-click`, named for where it sits — `signup-header`,
`signup-hero`, `signup-closing` on the home page, `signup-clubs-header`,
`signup-clubs-hero`, `signup-clubs-closing` on the clubs page, `signup-privacy`
and `signup-terms` on the doc pages. They show on the dashboard as their own rows,
and an event's referrer is the page visit's referrer (Bing, Google, …), so
each row tells you which source sent the people who clicked. A new link to
`/register` gets its own name; the privacy page says sign-up clicks are counted,
so tag no other kind of click without changing that sentence too.

Your own visits: open `https://bridge.games/#toggle-goatcounter` once and that
browser is excluded (a localStorage flag, per browser); or list addresses
under Settings on the dashboard. The script also skips localhost and private
addresses, so a `python3 -m http.server` preview sends nothing.

## Screenshots enlarge

Every screenshot sits in `<a class="zoom" href="/images/…">` pointing at its
own file. `js/zoom.js` (about 40 lines, no library) opens it whole in a
`<dialog>`. Esc, the ×, or a press anywhere closes it, and focus returns to the
picture. A modified click, or no JS, just opens the image. It stores nothing
and must never carry `data-goatcounter-click` (the privacy page says only
sign-up clicks are counted).

## Search

The site is verified in Google Search Console and Bing Webmaster Tools;
submit `https://bridge.games/sitemap.xml` to both. The queries that find us
(2026-10) are the searcher's words, not ours: "free bridge", "bridge for
free", "free bridge games no download", "play bridge online free against
computer". So:

- The `<title>` and meta description speak search ("Play Free Online, No
  Download", "against bots") around the page's own line, "Your New Home for
  Bridge"; `og:title`/`og:description` carry that line for link previews.
  Keep the meta description tight (the 2026-10-21 one runs long on purpose,
  to name every pillar; trim it before adding to it).
- The Alert section (`#faq`) answers those queries in plain text, which
  is most of what lets the page rank for them. Its answers sit under the
  honesty guardrails below like any other copy, and "Do I need an account?"
  stays yes until guest play exists.
- The JSON-LD in `index.html` is WebSite + Organization only, so Google shows
  "bridge.games" as the site name. There's no SoftwareApplication block on
  purpose: Google treats one without ratings as an error, and we have no
  ratings to give it.
- Bing sends nearly all our search traffic, counting Yahoo, DuckDuckGo and
  Copilot, which search its index (GoatCounter, Sept–Oct 2026: 63 of 70
  search visits; Google 6). So every page change is pushed to Bing through
  IndexNow instead of waiting for a recrawl: on a push to main that touches
  `index.html`, `clubs.html`, `privacy.html` or `terms.html`, the IndexNow
  workflow waits until Pages serves the committed bytes, then submits just
  the changed pages. Its runs are on the repo's Actions tab, and Bing
  Webmaster Tools → IndexNow lists what arrived. "Run workflow" there, or
  `scripts/indexnow.sh` by hand, submits all four.
- `/clubs` speaks to an organiser's search ("Move Your Bridge Club Online —
  Free"); it carries no JSON-LD on purpose, the home page's WebSite +
  Organization block already names the site. The key is the root
  `<32 hex>.txt` file, which IndexNow fetches to check that we own the site.
  It's public on purpose; replacing it just means committing a new one.
- The favicon is a gold spade on felt, drawn for this site on 2026-10-12. The
  app still carries Vite's default lightning bolt in
  `frontend/public/favicon.svg`; the site no longer does.

## Screenshot provenance

All app images are real screenshots of the build the club ran on 2026-10-21
(app commit `7f2e1a4`, the same bytes `app.bridge.games` served that morning),
retaken after the bigger cards, chat, tables, tournaments and clubs work of
2026-10-09 → 10-20. Same pipeline as 2026-08-20: an isolated worktree node
(`../bridge_play-shoot`, port 4112, Erlang cookie of its own so it could not
link to any other node) against a same-day **copy of the live database**
(`BridgeDB_shoot3` on the scratch Postgres, the library's bulk tables left
out, every open table, scheduled event and queued job scrubbed before the
node booted). Staged accounts appear under every name shown — "Ellen" seated,
"Margaret" kibitzing, Priya, Walter, Rosa, Tom, June, Harold, Arthur,
Beatrice and Frank — and every real member whose username could have reached
a traveller was renamed inside the copy (Agnes, Basil, Clara, …). Every
address in `club-invite.jpg` is an `example.*` one, and the shoot node held
all mail in its dev mailbox. Scores and traveller rows are real club results:
"The Card Room"'s four scored boards replay four real pool hands (the real
auction and all but the last card pre-applied, so the bots on the club's live
engine answered only a dozen forced cards), and the hold board is a real
4♠ by West with Ellen on play to trick two. The lunchtime event was a real
two-round, one-board pairs event padded with FastBen pairs, played out and
finished. Node, tables, club, event, database and worktree were torn down
after the shoot.

- `hero-table.jpg` (3200×2000): Ellen's seat at Card size **Large**, a
  1600×1000 Chromium window at 2×, defending 4♠, the Results drawer pinned
  on the Scorecard. `og-image.jpg` is a 1200×630 crop around the felt.
- `tablet-table.jpg` (2048×1536): a 1024×768 WebKit iPad viewport at 2×
  (full screen, as the home-screen app shows it) at **Extra large** — the
  header folded, the side panel a rail. The dark frame around it on the page
  is CSS, not part of the screenshot.
- `card-size-normal/-large/-xl.jpg` (1600×1133 each): the same board, the
  same 1600×1000 window, the three sizes, cropped to the stage column.
- `bidding-box.jpg`: a second table (Priya and three BenBots) with a real
  auction's first five calls applied, at Large.
- `chat-to-menu.jpg`: a table of four staged people with no hand dealt, so
  Partner is offered; Ellen in green is a friend who had just written.
- `lobby-stats.jpg` (2300×1724): three staged tables (Sit chairs, in play,
  locked with Ask), a booked table, a scheduled event with a description,
  the lounge bar closed; the "8 online" are the staged accounts' live
  connections.
- `create-table.jpg`, `host-tournament.jpg` and `host-tournament-settings.jpg`
  (the dialog's top 1360 px and its remaining 1308 px, shown side by side),
  `captain-menu.jpg`, `traveller.jpg` (board 1's field, 12 results),
  `replay-panel.jpg` (the defeated slam), `event-page.jpg` (a spectator's
  view of round 2), `event-director.jpg` (the director's), `event-score.jpg`
  (the score pad at Ellen's seat in round 2, cropped from her table),
  `club-page.jpg` (`og-clubs.jpg` is its top 1200×630), `club-invite.jpg`
  (Preview only; nothing sent), `phone-table.jpg`/`phone-kibitz.jpg`
  (390×844 WebKit at 3×; the kibitz shot is at a see-all table, and the
  caption is scoped to that).
- `replay-table.jpg` (3200×2000) and `bookmarked-boards.jpg`: a second,
  shorter run of the same pipeline the same afternoon (`BridgeDB_shoot4`),
  replaying one of Ellen's own real August hands (2♠ by East at a Thursday
  club table, the field's 55 results untouched) from the 17th card at a
  private replay table with Double Dummy bots, after starring it with a
  note; the replay was held, so no bot played a card.
- Retired 2026-10-21: `table-settings.jpg` (the Create a table dialog shows
  the same settings list). The CSS "four corners" video illustration went
  with the 2026-10-21 rework (the chat's To menu carries the section now).
- Shot but not on any page since the 2026-10-21 rework, kept for later:
  `card-size-normal/-large/-xl.jpg` (card size is one bullet and one FAQ
  answer now) and `replay-panel.jpg` (Bookmarked Boards shows the same deal
  panel). `event-director.jpg` is on the clubs page only.

## Honesty guardrails for future copy

The site says **beta** in the hero pill on the home and clubs pages and in
every footer's beta paragraph, and the app's lobby says the same thing in the
same words. Keep them in step: drop all of them when Denny says the app has
left beta, never one without the others.

Don't claim:

- lessons, hints, tutorials or teaching of any kind: there are none. The
  beginner pitch is the patient table (bots that never rush, Undo where the
  table allows it, replay with all four hands up, the traveller to compare)
  and the FAQ says "no lessons here yet";
- guest play without an account;
- bot difficulty levels: there are three bots — BenBot (the default), FastBen
  (faster, and measured slightly weaker: say so wherever it is named) and
  Double Dummy (sees all four hands; its boards are flagged and kept out of
  comparisons);
- that voice and video are on at a table: off by default at every new casual
  table and event since 2026-10-18, on only where the creator ticks Voice and
  video or the captain or director turns them on, and each player still
  chooses a microphone or camera;
- video on phones (A/V is off under 640px wide);
- rated play (the box is shown greyed: "Rated play is not open yet — every
  table plays unrated");
- Full screen on an iPhone (Add to Home Screen is the iPhone's way);
- that Card size follows you between devices (it is per device);
- repeating bookings or events (every booking and event is one-off);
- that non-members see a club's tables or member list, or that managers get
  members' email addresses (the export has none);
- that clubs are free forever: they are free today, but creating a club is
  built as an entitlement that could later be a subscriber's (app
  `docs/clubs.md`), so say "free" in the present tense only;
- individual movements (pairs events and team matches only), masterpoints or
  league sanctioning, that kibitzers always see all four hands (a per-table
  setting, on by default — scope any such claim), that media never touches
  our servers (peer to peer where the network allows, through our relay,
  still encrypted, where it doesn't), that a browser only ever holds its own
  hand (dummy, a claim's responders, spectators at see-all tables, directors
  and the Double Dummy bot all see more), or regularly scheduled house-run
  games (every event is player-hosted today).

Do say, when the copy touches them: tournament voice and video are the
director's call (off by default since 2026-10-18); partner chat is closed
while a hand is live; password reset ships (by email, since 2026-08); an
invitation's email carries the sender's address as its reply-to (the privacy
page says so); "Do I need an account?" stays yes until guest play exists.
