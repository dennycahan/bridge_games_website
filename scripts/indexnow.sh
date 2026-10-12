#!/usr/bin/env bash
# Tell IndexNow which pages changed, once GitHub Pages is serving them. Bing
# takes the submission and shares it with the other IndexNow engines; Yahoo,
# DuckDuckGo and Copilot search Bing's index, so they follow.
#
#   scripts/indexnow.sh           submit all three pages
#   scripts/indexnow.sh <commit>  submit only pages whose file changed since <commit>
#
# .github/workflows/indexnow.yml runs it on every push to main that touches a
# page. By hand, run it after the push, from anywhere in the repo.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

host=bridge.games
key=$(git ls-files | grep -E '^[0-9a-f]{32}\.txt$' | sed 's/\.txt$//' || true)
[ -n "$key" ] || { echo "no committed IndexNow key file (<32 hex>.txt) at the repo root" >&2; exit 1; }

url_for() {
  case "$1" in
    index.html)   echo "https://$host/" ;;
    privacy.html) echo "https://$host/privacy" ;;
    terms.html)   echo "https://$host/terms" ;;
  esac
}

pages="index.html privacy.html terms.html"
if [ -n "${1:-}" ] && git cat-file -e "$1^{commit}" 2>/dev/null; then
  pages=$(git diff --name-only "$1" HEAD -- $pages)
fi
[ -n "$pages" ] || { echo "no page changed; nothing to submit"; exit 0; }

# Pages takes a minute or three to build. Submitting before the new bytes are
# live would send Bing to crawl the old page.
for f in $pages; do
  u=$(url_for "$f")
  for i in $(seq 60); do
    curl -fsS "$u?indexnow=$RANDOM" | cmp -s - <(git show "HEAD:$f") && break
    [ "$i" = 60 ] && { echo "$u still isn't serving the committed $f after 15 minutes" >&2; exit 1; }
    sleep 15
  done
done

urls=$(for f in $pages; do printf '"%s",' "$(url_for "$f")"; done)
body=$(printf '{"host":"%s","key":"%s","keyLocation":"https://%s/%s.txt","urlList":[%s]}' \
  "$host" "$key" "$host" "$key" "${urls%,}")

resp=$(mktemp)
code=$(curl -sS -o "$resp" -w '%{http_code}' \
  -H 'Content-Type: application/json; charset=utf-8' -d "$body" \
  https://api.indexnow.org/indexnow)
case "$code" in
  200|202) echo "IndexNow $code: submitted ${urls%,}" ;;
  *) echo "IndexNow refused the submission ($code):" >&2; cat "$resp" >&2; echo >&2; exit 1 ;;
esac
