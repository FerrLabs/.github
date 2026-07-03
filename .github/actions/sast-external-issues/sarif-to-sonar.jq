# SARIF -> SonarQube Generic Issue Import Format (Clean Code taxonomy).
#
# Usage:  jq -s -f sarif-to-sonar.jq a.sarif b.sarif > out.json
#
# Consumes one or more SARIF 2.1.0 documents (slurped into a top-level array)
# and emits { "rules": [...], "issues": [...] } consumable by SonarQube via
# `-Dsonar.externalIssuesReportPaths`. Every issue's ruleId is guaranteed to
# have a matching rule (rules are synthesised from the results themselves and
# enriched with the SARIF driver rule metadata when present).
#
# Kept deliberately jq-only (no python/pip) so it runs on the self-hosted
# ferrlabs-k8s pool as well as ubuntu-latest.

def sev(l):
  if   l == "error"   then "HIGH"
  elif l == "warning" then "MEDIUM"
  else "LOW" end;

# Normalise a SARIF artifact URI into a project-relative path.
def relpath(u):
  (u // "unknown") | sub("^file://"; "") | sub("^\\./"; "");

# All runs across every slurped SARIF document.
[ .[] | .runs[]? ] as $runs

# Rule metadata map keyed by "<engine>:<ruleId>".
| ( reduce ( $runs[]
             | (.tool.driver.name // "sast") as $e
             | (.tool.driver.rules // [])[]
             | { k: ($e + ":" + (.id // "unknown")), v: . }
           ) as $r ({}; .[$r.k] = $r.v) ) as $meta

# Flatten every result, tagging it with its engine + composite rule id.
| ( [ $runs[]
      | (.tool.driver.name // "sast") as $e
      | .results[]?
      | { engine: $e, rid: ($e + ":" + (.ruleId // "unknown")), res: . } ] ) as $results

| {
    rules: (
      [ $results[] | { engine, rid } ] | unique_by(.rid)
      | map(
          .rid as $rid | .engine as $e | ($meta[$rid] // {}) as $m
          | {
              id: $rid,
              name: (($m.name // $m.id // ($rid | sub("^[^:]+:"; ""))) | tostring),
              engineId: $e,
              cleanCodeAttribute: "CONVENTIONAL",
              impacts: [ { softwareQuality: "SECURITY",
                           severity: sev($m.defaultConfiguration.level // "warning") } ],
              description: (($m.shortDescription.text // $m.fullDescription.text // $m.name // "Security finding") | tostring)
            }
        )
    ),
    issues: (
      [ $results[]
        | .rid as $rid | .res as $res
        | ($res.locations[0].physicalLocation) as $pl
        | select($pl != null)
        | {
            ruleId: $rid,
            primaryLocation: {
              message: (($res.message.text // "Security finding") | tostring),
              filePath: relpath($pl.artifactLocation.uri),
              textRange: (
                { startLine: ($pl.region.startLine // 1) }
                + ( if ($pl.region.endLine // 0) > ($pl.region.startLine // 1)
                    then { endLine: $pl.region.endLine } else {} end )
              )
            }
          }
      ]
    )
  }
