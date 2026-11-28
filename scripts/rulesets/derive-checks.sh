#!/usr/bin/env bash
set -uo pipefail
org=FerrLabs
out=${1:-checks.json}
echo '{}' > "$out"
gh repo list "$org" --no-archived --source --limit 200 --json name,defaultBranchRef --jq '.[]|"\(.name)\t\(.defaultBranchRef.name)"' |
while IFS=$'\t' read -r name def; do
  repo="$org/$name"
  prs=$(gh pr list -R "$repo" --state merged --base "$def" --limit 5 --json number,headRefOid,statusCheckRollup 2>/dev/null) || { echo "skip $repo: no access" >&2; continue; }
  sha=$(jq -r '.[0].headRefOid // empty' <<<"$prs")
  apps='[]'
  if [ -n "$sha" ]; then
    apps=$(gh api "repos/$repo/commits/$sha/check-runs?per_page=100" --jq '[.check_runs[]|{name,app:.app.id}]' 2>/dev/null || echo '[]')
  fi
  row=$(jq --argjson apps "$apps" --arg def "$def" '
    def norm: (.name // .context) as $n | {n:$n, ok:((.conclusion=="SUCCESS") or (.state=="SUCCESS"))};
    . as $prs
    | ($prs|length) as $cnt
    | [ $prs[] | [ .statusCheckRollup[]? | norm ] ] as $per
    | ([ $per[][] | .n ] | unique) as $names
    | [ $names[] as $n
        | {n:$n, ran:([ $per[] | select(any(.[]; .n==$n)) ]|length), passed:([ $per[] | select(any(.[]; .n==$n and .ok)) ]|length)} ] as $stat
    | { default:$def, merged_prs_sampled:$cnt, prs:[$prs[].number],
        proposed:[ $stat[] | select($cnt>=3 and .ran==$cnt and .passed==$cnt and .n!="cla")
                   | .n as $n | {context:$n, integration_id:(([$apps[]|select(.name==$n)|.app][0]) // null)}
                   | select(.integration_id==15368) ],
        partial:[ $stat[] | select(.ran<$cnt or .passed<.ran) | {context:.n, ran:.ran, passed:.passed} ] }' <<<"$prs")
  tmp=$(mktemp)
  jq --arg r "$name" --argjson row "$row" '.[$r]=$row' "$out" > "$tmp" && mv "$tmp" "$out"
done
