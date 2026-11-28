#!/usr/bin/env bash
set -uo pipefail

ORG=FerrLabs
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP_DIR=$HERE/backup
CHECKS_FILE=$HERE/checks.json
BASELINE_NAME=ferrlabs-baseline-protection
REPO_RULESET_NAME="main: required CI checks"
CREATE_BYPASS='[{"actor_id":null,"actor_type":"OrganizationAdmin","bypass_mode":"always"},{"actor_id":3455369,"actor_type":"Integration","bypass_mode":"always"}]'
WRITABLE='{name,target,enforcement,conditions,rules,bypass_actors}'

apply=false
do_org=false
do_all=false
repos=()
rollback=""

usage() {
  cat <<EOF
usage: apply.sh [--org] [--repo NAME]... [--all] [--apply] [--rollback FILE]
  default is a dry run: reads only, prints the gh api calls and a diff per ruleset
  --org            baseline org ruleset: required_review_thread_resolution=true (affects EVERY repository)
  --repo NAME      required-checks ruleset of one repository (create it when missing)
  --all            --org plus every repository in $CHECKS_FILE
  --apply          perform the writes (needs --org, --repo or --all)
  --rollback FILE  restore a backup file (or delete a ruleset created by this script)
EOF
  exit 2
}

while [ $# -gt 0 ]; do
  case $1 in
    --apply) apply=true ;;
    --org) do_org=true ;;
    --all) do_all=true ;;
    --repo) shift; [ $# -gt 0 ] || usage; repos+=("$1") ;;
    --rollback) shift; [ $# -gt 0 ] || usage; rollback=$1 ;;
    *) usage ;;
  esac
  shift
done

log() { printf '%s\n' "$*" >&2; }
stamp() { date -u +%Y%m%dT%H%M%SZ; }

writes_enabled() { $apply; }

diff_bodies() {
  diff -u --label before --label after <(jq -S . "$1") <(jq -S . "$2")
}

backup_current() {
  local token=$1 id=$2 json=$3 file
  mkdir -p "$BACKUP_DIR"
  file=$BACKUP_DIR/$token-$id-$(stamp).json
  printf '%s\n' "$json" > "$file"
  chmod 600 "$file"
  log "backup: $file"
}

put_ruleset() {
  local token=$1 path=$2 id=$3 before_json=$4 after_body=$5
  local before_body tmp
  tmp=$(mktemp -d)
  before_body=$tmp/before.json
  jq "$WRITABLE" <<<"$before_json" > "$before_body"
  if [ "$(jq -S . "$before_body")" = "$(jq -S . "$after_body")" ]; then
    log "[$token] already compliant, no change"
    rm -rf "$tmp"
    return 0
  fi
  log "[$token] gh api -X PUT $path --input <body>"
  diff_bodies "$before_body" "$after_body"
  if ! writes_enabled; then rm -rf "$tmp"; return 0; fi
  backup_current "$token" "$id" "$before_json"
  gh api -X PUT "$path" --input "$after_body" >/dev/null || { log "[$token] PUT failed"; rm -rf "$tmp"; return 1; }
  local verify
  verify=$(gh api "$path" | jq -S "$WRITABLE")
  if [ "$verify" = "$(jq -S . "$after_body")" ]; then
    log "[$token] applied and verified"
  else
    log "[$token] applied but read-back differs from the intended body, check manually"
  fi
  rm -rf "$tmp"
}

org_ruleset() {
  local list id json after
  list=$(gh api "orgs/$ORG/rulesets") || { log "[org] cannot list org rulesets, skipped"; return 1; }
  id=$(jq -r --arg n "$BASELINE_NAME" '[.[]|select(.name==$n)]|if length==1 then .[0].id else empty end' <<<"$list")
  [ -n "$id" ] || { log "[org] $BASELINE_NAME not found exactly once, skipped"; return 1; }
  json=$(gh api "orgs/$ORG/rulesets/$id") || { log "[org] cannot read ruleset $id, skipped"; return 1; }
  jq -e '[.rules[]|select(.type=="pull_request")]|length==1' <<<"$json" >/dev/null ||
    { log "[org] unexpected pull_request rule layout, skipped"; return 1; }
  after=$(mktemp)
  jq "$WRITABLE | (.rules[]|select(.type==\"pull_request\")|.parameters.required_review_thread_resolution) = true" <<<"$json" > "$after"
  put_ruleset "org-$ORG" "orgs/$ORG/rulesets/$id" "$id" "$json" "$after"
  local rc=$?
  rm -f "$after"
  return $rc
}

proposed_for() {
  jq -c --arg r "$1" '.[$r].proposed // []' "$CHECKS_FILE"
}

repo_checks() {
  local name=$1 repo="$ORG/$1" proposed list ids cand=() id json
  [ -f "$CHECKS_FILE" ] || { log "[$name] $CHECKS_FILE missing, run derive-checks.sh"; return 1; }
  jq -e --arg r "$name" 'has($r)' "$CHECKS_FILE" >/dev/null || { log "[$name] not in $CHECKS_FILE, skipped"; return 1; }
  proposed=$(proposed_for "$name")
  list=$(gh api "repos/$repo/rulesets") || { log "[$name] rulesets not readable, skipped"; return 1; }
  ids=$(jq -r '.[]|select(.source_type=="Repository" and .target=="branch")|.id' <<<"$list")
  for id in $ids; do
    json=$(gh api "repos/$repo/rulesets/$id") || { log "[$name] cannot read ruleset $id, skipped"; return 1; }
    jq -e '.rules|type=="array"' <<<"$json" >/dev/null || { log "[$name] ruleset $id not parseable, skipped"; return 1; }
    if jq -e 'any(.rules[]; .type=="required_status_checks")' <<<"$json" >/dev/null; then cand+=("$id"); fi
  done
  if [ ${#cand[@]} -gt 1 ]; then log "[$name] ${#cand[@]} rulesets carry required_status_checks, ambiguous, skipped"; return 1; fi

  local after
  after=$(mktemp)
  if [ ${#cand[@]} -eq 0 ]; then
    if [ "$proposed" = "[]" ]; then log "[$name] no ruleset and no check to propose, nothing to do"; rm -f "$after"; return 0; fi
    jq -n --arg n "$REPO_RULESET_NAME" --argjson p "$proposed" --argjson b "$CREATE_BYPASS" '
      {name:$n, target:"branch", enforcement:"active",
       conditions:{ref_name:{include:["~DEFAULT_BRANCH"],exclude:[]}},
       bypass_actors:$b,
       rules:[{type:"required_status_checks",
               parameters:{strict_required_status_checks_policy:false, do_not_enforce_on_create:false,
                           required_status_checks:($p|map(if .integration_id==null then del(.integration_id) else . end))}}]}' > "$after"
    log "[$name] gh api -X POST repos/$repo/rulesets --input <body>   (create)"
    jq -S . "$after"
    if writes_enabled; then
      local created cid
      created=$(gh api -X POST "repos/$repo/rulesets" --input "$after") || { log "[$name] POST failed"; rm -f "$after"; return 1; }
      cid=$(jq -r .id <<<"$created")
      mkdir -p "$BACKUP_DIR"
      printf '%s\n' "$created" > "$BACKUP_DIR/$name-$cid-$(stamp).created.json"
      log "[$name] created ruleset $cid (rollback deletes it)"
    fi
    rm -f "$after"
    return 0
  fi

  id=${cand[0]}
  json=$(gh api "repos/$repo/rulesets/$id")
  jq -e '[.rules[]|select(.type=="required_status_checks")]|length==1' <<<"$json" >/dev/null ||
    { log "[$name] ruleset $id has several required_status_checks rules, skipped"; rm -f "$after"; return 1; }
  jq "$WRITABLE | (.rules[]|select(.type==\"required_status_checks\")|.parameters.required_status_checks) |=
      (. as \$cur | \$cur + [ \$new[] | select(.context as \$c | (\$cur|map(.context)|index(\$c))|not)
                              | if .integration_id==null then del(.integration_id) else . end ])" \
    --argjson new "$proposed" <<<"$json" > "$after"
  put_ruleset "$name" "repos/$repo/rulesets/$id" "$id" "$json" "$after"
  local rc=$?
  rm -f "$after"
  return $rc
}

do_rollback() {
  local file=$1 body path tmp
  [ -f "$file" ] || { log "no such file: $file"; return 1; }
  jq -e '.id and .source_type and .source' "$file" >/dev/null || { log "not a ruleset backup: $file"; return 1; }
  local stype source id
  stype=$(jq -r .source_type "$file"); source=$(jq -r .source "$file"); id=$(jq -r .id "$file")
  case $stype in
    Organization) path=orgs/$source/rulesets/$id ;;
    Repository) path=repos/$source/rulesets/$id ;;
    *) log "unknown source_type $stype"; return 1 ;;
  esac
  if [[ $file == *.created.json ]]; then
    log "gh api -X DELETE $path"
    writes_enabled && gh api -X DELETE "$path" >/dev/null && log "deleted $path"
    return 0
  fi
  local current
  current=$(gh api "$path") || { log "cannot read $path"; return 1; }
  tmp=$(mktemp)
  jq "$WRITABLE" "$file" > "$tmp"
  put_ruleset "rollback-$(basename "$source")" "$path" "$id" "$current" "$tmp"
  local rc=$?
  rm -f "$tmp"
  return $rc
}

command -v gh >/dev/null && command -v jq >/dev/null || { log "gh and jq are required"; exit 1; }

if [ -n "$rollback" ]; then do_rollback "$rollback"; exit $?; fi

if $do_all; then
  do_org=true
  mapfile -t repos < <(jq -r 'keys[]' "$CHECKS_FILE")
fi

if ! $do_org && [ ${#repos[@]} -eq 0 ]; then
  if $apply; then log "--apply needs --org, --repo or --all"; exit 2; fi
  do_org=true
  mapfile -t repos < <(jq -r 'keys[]' "$CHECKS_FILE")
fi

$apply || log "DRY RUN: no write will be made (add --apply to write)"

rc=0
$do_org && { org_ruleset || rc=1; }
for r in "${repos[@]}"; do repo_checks "$r" || rc=1; done
exit $rc
