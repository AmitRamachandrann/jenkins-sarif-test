pipeline {
    agent any

    environment {
        SNYK_TOKEN = credentials('snyk-api-token') 
    }

    stages {
        stage('Install Snyk CLI') {
            steps {
                sh '''
                    curl -sL https://static.snyk.io/cli/latest/snyk-linux -o snyk
                    chmod +x snyk
                    mv snyk /usr/local/bin/
                    snyk --version
                '''
            }
        }

        stage('Run Snyk Code Scan') {
            steps {
                sh '''
                    mkdir -p reports
                    export PATH="$HOME/.snyk/bin:$PATH"
                    snyk auth "$SNYK_TOKEN"
                    snyk code test --sarif > reports/snyk-code.sarif
                '''
            }
        }

        stage('Add Snippet to SARIF') {
            steps {
                sh '''
                    # Ensure Python 3 is installed
                    python3 --version || (apt-get update && apt-get install -y python3)

                    # Python script to add snippet data
                    python3 << 'EOF'
import json, os

sarif_path = "reports/snyk-code.sarif"

with open(sarif_path, "r", encoding="utf-8") as f:
    data = json.load(f)

for run in data.get("runs", []):
    for result in run.get("results", []):
        for loc in result.get("locations", []):
            phys_loc = loc.get("physicalLocation", {})
            region = phys_loc.get("region", {})
            start_line = region.get("startLine")
            end_line = region.get("endLine", start_line)

            # Get file path
            file_uri = phys_loc.get("artifactLocation", {}).get("uri")
            if not file_uri or not os.path.exists(file_uri):
                continue

            try:
                with open(file_uri, "r", encoding="utf-8", errors="ignore") as src:
                    lines = src.readlines()
                    snippet_text = "".join(lines[start_line-1:end_line])
                    phys_loc["contextRegion"] = {
                        "startLine": start_line,
                        "endLine": end_line,
                        "snippet": {"text": snippet_text}
                    }
            except Exception as e:
                print(f"Warning: Could not read {file_uri} - {e}")

with open(sarif_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)

print(f"Updated SARIF with snippet data: {sarif_path}")
print(json.dumps(data, indent=2))
EOF
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'reports/*.sarif', fingerprint: true
        }
    }
}
