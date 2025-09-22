#!/usr/bin/env bash
set -euo pipefail

# Dependencies
jq_bin=$(command -v $jq || echo "$jq")
if [[ -z "$jq_bin" ]]; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# Utility functions
# ------------------------------------------------------------------------------
severity_map() {
  local sev="$1"
  case "$sev" in
    MINOR) echo "LOW" ;;
    MAJOR|HIGH) echo "HIGH" ;;
    CRITICAL|BLOCKER) echo "VERY_HIGH" ;;
    MEDIUM) echo "MEDIUM" ;;
    LOW) echo "LOW" ;;
    *) echo "INFORMATION" ;;
  esac
}

get_snippet() {
  local file="$1" start_line="$2" end_line="$3"
  [[ -f "$file" ]] || { echo ""; return; }
  sed -n "${start_line},${end_line}p" "$file"
}

# ------------------------------------------------------------------------------
# Fetch from SonarQube API
# ------------------------------------------------------------------------------
fetch_sonar_issues() {
  local host="$1" token="$2" project="$3"
  curl -s -u "${token}:" "${host}/api/issues/search?componentKeys=${project}&ps=500"
}

fetch_sonar_hotspots() {
  local host="$1" token="$2" project="$3"
  curl -s -u "${token}:" "${host}/api/hotspots/search?projectKey=${project}&ps=500"
}

fetch_sonar_rule() {
  local host="$1" token="$2" rule_id="$3"
  curl -s -u "${token}:" "${host}/api/rules/show?key=${rule_id}"
}

# ------------------------------------------------------------------------------
# Map issues/hotspots to SARIF
# ------------------------------------------------------------------------------
map_issues_to_sarif() {
  local issues_json="$1" workspace="$2" rule_file="${3:-}"
  if [[ -z "$rule_file" ]]; then
    rule_file=$(mktemp)
  fi

  while read -r issue; do
    local rule message file_path start_line end_line start_col end_col severity type snippet
    rule=$($jq_bin -r '.rule' <<<"$issue")
    message=$($jq_bin -r '.message' <<<"$issue")
    file_path=$($jq_bin -r '.component | split(":")[1]?' <<<"$issue")
    start_line=$($jq_bin -r '.textRange.startLine // 1' <<<"$issue")
    end_line=$($jq_bin -r '.textRange.endLine // 1' <<<"$issue")
    start_col=$($jq_bin -r '.textRange.startOffset // 1' <<<"$issue")
    end_col=$($jq_bin -r '.textRange.endOffset // 1' <<<"$issue")
    severity=$($jq_bin -r '.severity' <<<"$issue")
    type=$($jq_bin -r '.type' <<<"$issue")

    snippet=$(get_snippet "${workspace}/${file_path}" "$start_line" "$end_line" | $jq_bin -Rs .)

    # Store rule ID
    echo "$rule" >>"$rule_file"

    # Output SARIF result object
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
  local issues_json="$1" workspace="$2" rule_file="${3:-}"
  if [[ -z "$rule_file" ]]; then
    rule_file=$(mktemp)
  fi

  while read -r hotspot; do
    local rule message file_path start_line end_line start_col end_col severity snippet
    rule=$($jq_bin -r '.ruleKey' <<<"$hotspot")
    message=$($jq_bin -r '.message' <<<"$hotspot")
    file_path=$($jq_bin -r '.component | split(":")[1]?' <<<"$hotspot")
    start_line=$($jq_bin -r '.textRange.startLine // 1' <<<"$hotspot")
    end_line=$($jq_bin -r '.textRange.endLine // 1' <<<"$hotspot")
    start_col=$($jq_bin -r '.textRange.startOffset // 1' <<<"$hotspot")
    end_col=$($jq_bin -r '.textRange.endOffset // 1' <<<"$hotspot")
    severity=$($jq_bin -r '.vulnerabilityProbability' <<<"$hotspot")

    snippet=$(get_snippet "${workspace}/${file_path}" "$start_line" "$end_line" | $jq_bin -Rs .)

    # Store rule ID
    echo "$rule" >>"$rule_file"

    # Output SARIF result object
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
# Generate SARIF rules
# ------------------------------------------------------------------------------
make_rules_for_sarif() {
  local issues_json="$1" workspace="$2" rule_file="${3:-}"
  if [[ -z "$rule_file" ]]; then
    rule_file=$(mktemp)
  fi
  sort -u "$rule_file" | while read -r rule_id; do
    resp=$(fetch_sonar_rule "$host" "$token" "$rule_id")
    $jq_bin -c '
      .rule? 
      | select(. != null)
      | {
          id: .key,
          name: .name,
          shortDescription: { text: .name },
          fullDescription: { text: .htmlDesc },
          help: {
            text: (.mdDesc // .htmlDesc),
            uri: ("'"$host"'/coding_rules?open=" + .key)
          },
          properties: {
            tags: .tags,
            severity: .severity,
            type: .type,
            lang: .lang,
            precision: .severity
          }
        }' <<<"$resp"
  done
}

# ------------------------------------------------------------------------------
# Generate SARIF output
# ------------------------------------------------------------------------------
get_sarif_output() {
  local url="$1" token="$2" project="$3" workspace="$4" version="$5"

  local rule_file
  rule_file=$(mktemp)
  trap 'rm -f "$rule_file"' EXIT

  # Fetch JSON
  issues_json=$(fetch_sonar_issues "$url" "$token" "$project")
  hotspots_json=$(fetch_sonar_hotspots "$url" "$token" "$project")

  # Map to SARIF results
  issues_sarif=$(map_issues_to_sarif "$issues_json" "$workspace" "$rule_file" | $jq_bin -s .)
  hotspots_sarif=$(map_hotspots_to_sarif "$hotspots_json" "$workspace" "$rule_file" | $jq_bin -s .)

  # Combine
  combined=$($jq_bin -s '.[0] + .[1]' <<<"$issues_sarif $hotspots_sarif")

  # Build rules
  rules=$(make_rules_for_sarif "$url" "$token" "$rule_file" | $jq_bin -s .)

  # Output final SARIF
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
