#!/usr/bin/env bash
set -euo pipefail

# Globals
RULE_IDS=()

# Utility: add rule id
add_rule_id() {
  local rule_id="$1"
  RULE_IDS+=("$rule_id")
}

# Utility: severity mapping
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

# Fetch issues from SonarQube API
fetch_sonar_issues() {
  local host="$1" token="$2" project="$3"
  curl -s -u "${token}:" \
    "${host}/api/issues/search?componentKeys=${project}&ps=500"
}

# Fetch hotspots from SonarQube API
fetch_sonar_hotspots() {
  local host="$1" token="$2" project="$3"
  curl -s -u "${token}:" \
    "${host}/api/hotspots/search?projectKey=${project}&ps=500"
}

# Fetch rule details from SonarQube API
fetch_sonar_rule() {
  local host="$1" token="$2" rule_id="$3"
  curl -s -u "${token}:" \
    "${host}/api/rules/show?key=${rule_id}"
}

# Get vulnerable code snippet from file
get_snippet() {
  local file="$1" start_line="$2" end_line="$3"
  if [[ ! -f "$file" ]]; then
    echo ""
    return
  fi
  sed -n "${start_line},${end_line}p" "$file"
}

# Map issues JSON to SARIF results
map_issues_to_sarif() {
  local issues_json="$1" workspace="$2"

  echo "$issues_json" | jq -c '.issues[]?' | while read -r issue; do
    local rule message file_path start_line end_line start_col end_col severity type
    rule=$(jq -r '.rule' <<<"$issue")
    message=$(jq -r '.message' <<<"$issue")
    file_path=$(jq -r '.component | split(":")[1]?' <<<"$issue")
    start_line=$(jq -r '.textRange.startLine // 1' <<<"$issue")
    end_line=$(jq -r '.textRange.endLine // 1' <<<"$issue")
    start_col=$(jq -r '.textRange.startOffset // 1' <<<"$issue")
    end_col=$(jq -r '.textRange.endOffset // 1' <<<"$issue")
    severity=$(jq -r '.severity' <<<"$issue")
    type=$(jq -r '.type' <<<"$issue")

    snippet=$(get_snippet "${workspace}/${file_path}" "$start_line" "$end_line" | jq -Rs .)

    add_rule_id "$rule"

    jq -n \
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
  done
}

# Generate SARIF rules section
make_rules_for_sarif() {
  local host="$1" token="$2"
  for rule_id in $(printf "%s\n" "${RULE_IDS[@]}" | sort -u); do
    resp=$(fetch_sonar_rule "$host" "$token" "$rule_id")
    jq -c '.rule | {
      id: .key,
      name: .name,
      shortDescription: { text: .name },
      fullDescription: { text: .htmlDesc },
      help: {
        text: (.mdDesc // .htmlDesc),
        uri: ("https://sonarqube.example.com/coding_rules?open=" + .key)
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

# Generate SARIF output
get_sarif_output() {
  local url="$1" token="$2" project="$3" workspace="$4" version="$5"

  issues_json=$(fetch_sonar_issues "$url" "$token" "$project")
  hotspots_json=$(fetch_sonar_hotspots "$url" "$token" "$project")

  issues_sarif=$(map_issues_to_sarif "$issues_json" "$workspace" | jq -s .)
  hotspots_sarif=$(map_issues_to_sarif "$hotspots_json" "$workspace" | jq -s .)

  combined=$(jq -s '.[0] + .[1]' <<<"$issues_sarif $hotspots_sarif")

  rules=$(make_rules_for_sarif "$url" "$token" | jq -s .)

  jq -n \
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


