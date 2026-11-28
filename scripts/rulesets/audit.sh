#!/usr/bin/env bash
set -uo pipefail
org=FerrLabs
out=${1:-audit.tsv}
notes=${2:-audit.notes}
: > "$out"; : > "$notes"

apps=$(gh api "orgs/$org/installations" --paginate --jq '.installations[]|{(.app_id|tostring):.app_slug}' | jq -s add)
teams=$(gh api "orgs/$org/teams" --paginate --jq '.[]|{(.id|tostring):.slug}' 2>/dev/null | jq -s 'add // {}')

actors='
def role: {"1":"read","2":"triage","4":"write","5":"admin"};
def actor_name:
  if .actor_type=="OrganizationAdmin" then "OrganizationAdmin"
  elif .actor_type=="Integration" then "Integration:\(($apps[.actor_id|tostring]) // "unknown")(\(.actor_id))"
  elif .actor_type=="Team" then "Team:\(($teams[.actor_id|tostring]) // "unknown")(\(.actor_id))"
  elif .actor_type=="RepositoryRole" then "Role:\(role[.actor_id|tostring] // (.actor_id|tostring))"
  else "\(.actor_type):\(.actor_id)" end;
'

gh repo list "$org" --no-archived --source --limit 200 --json name,defaultBranchRef \
  --jq '.[]|"\(.name)\t\(.defaultBranchRef.name)"' |
while IFS=$'\t' read -r name def; do
  repo="$org/$name"
  list=$(gh api "repos/$repo/rulesets?includes_parents=true" 2>&1) || {
    printf '%s\tSKIPPED\tno access to rulesets\n' "$repo" >> "$out"
    printf '%s: skipped, rulesets not readable (%s)\n' "$repo" "$(jq -r '.message // empty' <<<"$list" 2>/dev/null)" >> "$notes"
    continue
  }
  branch_rules=$(jq -r '.[]|select(.target=="branch")|"\(.source_type)\t\(.id)"' <<<"$list")
  if [ -n "$branch_rules" ]; then
    while IFS=$'\t' read -r stype id; do
      detail=$(gh api "repos/$repo/rulesets/$id" 2>/dev/null) || { printf '%s\tUNREADABLE\t%s\n' "$repo" "$id" >> "$out"; continue; }
      jq -r --arg repo "$repo" --arg stype "$stype" --argjson apps "$apps" --argjson teams "$teams" "$actors"'
        (first(.rules[]|select(.type=="pull_request")|.parameters) // null) as $pr
        | [$repo, $stype, (.id|tostring), .name, .enforcement,
           ((.conditions.ref_name.include // [])|join(",")),
           (if $pr then ($pr.required_review_thread_resolution|tostring) else "no_pr_rule" end),
           (if $pr then ($pr.required_approving_review_count|tostring) else "-" end),
           (if $pr then ($pr.dismiss_stale_reviews_on_push|tostring) else "-" end),
           ([.rules[]|select(.type=="required_status_checks")|.parameters.required_status_checks[].context]|join(";")),
           ([.bypass_actors[]?|actor_name]|join(","))] | @tsv' <<<"$detail" >> "$out"
    done <<<"$branch_rules"
  else
    prot=$(gh api "repos/$repo/branches/$def/protection" 2>&1) && state=CLASSIC_PROTECTION || state=NO_PROTECTION
    printf '%s\tNO_RULESET\t%s\n' "$repo" "$state" >> "$out"
  fi
done
