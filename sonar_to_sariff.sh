#!/usr/bin/env bash
set -euo pipefail

# Temporary file for rule IDs
RULE_IDS_FILE="$(mktemp)"
trap 'rm -f "$RULE_IDS_FILE"' EXIT

# Dependencies
jq_bin=$(command -v $jq || echo "$jq")
if [[ -z "$jq_bin" ]]; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# Utility functions
# ------------------------------------------------------------------------------
add_rule_id() {
  local rule_id="$1"
  [[ -n "$rule_id" ]] && echo "$rule_id" >> "$RULE_IDS_FILE"
}

severity_map() {
  local sev="$1"
  case "$sev" in
    MINOR) echo "LOW" ;;
    MAJOR|HIGH) echo "HIGH" ;;
    CRITICAL|BLOCKER) echo "VERY-HIGH" ;;
    MEDIUM) echo "MEDIUM" ;;
    LOW) echo "LOW" ;;
    *) echo "INFORMATION" ;;
  esac
}

get_snippet() {
  local file="$1" start_line="$2" end_line="$3"
  if [[ ! -f "$file" ]]; then
    echo ""
    return
  fi
  sed -n "${start_line},${end_line}p" "$file"
}

# ------------------------------------------------------------------------------
# Fetch from SonarQube API
# ------------------------------------------------------------------------------
fetch_sonar_issues() {
  local host="$1" token="$2" project="$3"
  curl -s -u "${token}:" \
    "${host}/api/issues/search?componentKeys=${project}&ps=500"
}

fetch_sonar_hotspots() {
  local host="$1" token="$2" project="$3"
  curl -s -u "${token}:" \
    "${host}/api/hotspots/search?projectKey=${project}&ps=500"
}

fetch_sonar_rule() {
  local host="$1" token="$2" rule_id="$3"
  curl -s -u "${token}:" \
    "${host}/api/rules/show?key=${rule_id}"
}

# ------------------------------------------------------------------------------
# Map issues to SARIF
# ------------------------------------------------------------------------------
map_issues_to_sarif() {
  local issues_json="$1" workspace="$2"

  while read -r issue; do
    local rule message file_path start_line end_line start_col end_col severity type
    rule=$($jq_bin -r '.rule' <<<"$issue")
    message=$($jq_bin -r '.message' <<<"$issue")
    file_path=$($jq_bin -r '.component | split(":")[1]?' <<<"$issue")
    start_line=$($jq_bin -r '.textRange.startLine // 1' <<<"$issue")
    end_line=$($jq_bin -r '.textRange.endLine // 1' <<<"$issue")
    start_col=$($jq_bin -r '.textRange.startOffset // 1' <<<"$issue")
    end_col=$($jq_bin -r '.textRange.endOffset // 1' <<<"$issue")
    severity=$($jq_bin -r '.severity' <<<"$issue")
    type=$($jq_bin -r '.type' <<<"$issue")

    snippet=$(get_snippet "${workspace}/${file_path}" "$start_line" "$end_line")

    add_rule_id "$rule"

    $jq_bin -n \
      --arg rule "$rule" \
      --arg level "$(severity_map "$severity")" \
      --arg type "$type" \
      --arg message "$message" \
      --arg file "$file_path" \
      --argjson start_line "$start_line" \
      --argjson end_line "$end_line" \
      --argjson start_col "$start_col" \
      --argjson end_col "$end_col" \
      --arg snippet "$snippet" \
      '{
        ruleId: $rule,
        level: $level,
        message: { text: ($type + ": " + $message) },
        locations: [{
          physicalLocation: {
            artifactLocation: { uri: $file },
            region: {
              startLine: $start_line,
              startColumn: $start_col,
              endLine: $end_line,
              endColumn: $end_col,
              snippet: { text: $snippet }
            }
          }
        }]
      }'
  done < <(echo "$issues_json" | $jq_bin -c '.issues[]?')
}

map_hotspots_to_sarif() {
  local hotspots_json="$1" workspace="$2"

  while read -r hotspot; do
    local rule message file_path start_line end_line start_col end_col severity
    rule=$($jq_bin -r '.ruleKey' <<<"$hotspot")
    message=$($jq_bin -r '.message' <<<"$hotspot")
    file_path=$($jq_bin -r '.component | split(":")[1]?' <<<"$hotspot")
    start_line=$($jq_bin -r '.textRange.startLine // 1' <<<"$hotspot")
    end_line=$($jq_bin -r '.textRange.endLine // 1' <<<"$hotspot")
    start_col=$($jq_bin -r '.textRange.startOffset // 1' <<<"$hotspot")
    end_col=$($jq_bin -r '.textRange.endOffset // 1' <<<"$hotspot")
    severity=$($jq_bin -r '.vulnerabilityProbability' <<<"$hotspot")

    snippet=$(get_snippet "${workspace}/${file_path}" "$start_line" "$end_line")

    add_rule_id "$rule"

    $jq_bin -n \
      --arg rule "$rule" \
      --arg level "$(echo "$severity" | tr '[:lower:]' '[:upper:]')" \
      --arg type "HOTSPOT" \
      --arg message "$message" \
      --arg file "$file_path" \
      --argjson start_line "$start_line" \
      --argjson end_line "$end_line" \
      --argjson start_col "$start_col" \
      --argjson end_col "$end_col" \
      --arg snippet "$snippet" \
      '{
        ruleId: $rule,
        level: $level,
        message: { text: ($type + ": " + $message) },
        locations: [{
          physicalLocation: {
            artifactLocation: { uri: $file },
            region: {
              startLine: $start_line,
              startColumn: $start_col,
              endLine: $end_line,
              endColumn: $end_col,
              snippet: { text: $snippet }
            }
          }
        }]
      }'
  done < <(echo "$hotspots_json" | $jq_bin -c '.hotspots[]?')
}

# ------------------------------------------------------------------------------
# Rules section
# ------------------------------------------------------------------------------
make_rules_for_sarif() {
  local host="$1" token="$2"
  for rule_id in $(sort -u "$RULE_IDS_FILE"); do
    resp=$(fetch_sonar_rule "$host" "$token" "$rule_id")
    mapped_precision="$(severity_map "$(echo "$resp" | $jq_bin -r '.rule.severity')")"
    $jq_bin -c --arg host "$host" --arg precision "$mapped_precision" '
    .rule? 
    | select(. != null)
    | {
        id: .key,
        name: .name,
        shortDescription: { text: .name },
        fullDescription: { text: .htmlDesc },
        help: {
            text: (.mdDesc // .htmlDesc),
            uri: ($host + "/coding_rules?open=" + .key)
        },
        properties: {
            tags: .tags,
            severity: .severity,
            type: .type,
            lang: .lang,
            precision: $precision
        }
    }' <<<"$resp"
  done
}

# ------------------------------------------------------------------------------
# SARIF generation
# ------------------------------------------------------------------------------
get_sarif_output() {
  local url="$1" token="$2" project="$3" workspace="$4" version="$5"

  issues_json=$(fetch_sonar_issues "$url" "$token" "$project")
  hotspots_json=$(fetch_sonar_hotspots "$url" "$token" "$project")

  # Clear rule IDs file before mapping
  > "$RULE_IDS_FILE"
  issues_sarif=$(map_issues_to_sarif "$issues_json" "$workspace" | $jq_bin -s .)
  hotspots_sarif=$(map_hotspots_to_sarif "$hotspots_json" "$workspace" | $jq_bin -s .)

  combined=$($jq_bin -s '.[0] + .[1]' <<<"$issues_sarif $hotspots_sarif")

  rules=$(make_rules_for_sarif "$url" "$token" | $jq_bin -s .)

  $jq_bin -n \
    --arg version "$version" \
    --argjson results "$combined" \
    --argjson rules "$rules" \
    '{
      "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/main/sarif-2.1/schema/sarif-schema-2.1.0.json",
      version: "2.1.0",
      runs: [{
        tool: {
          driver: {
            name: "SonarQube",
            version: $version,
            rules: $rules
          }
        },
        results: $results
      }]
    }'
}

# ------------------------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------------------------
if [[ "${1:-}" == "get_sarif_output" ]]; then
  shift
  get_sarif_output "$@"
fi
