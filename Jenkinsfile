pipeline {
  agent any

  environment {
    SNYK_TOKEN = credentials('snyk-api-secret')
    PYTHON_URL = "https://github.com/indygreg/python-build-standalone/releases/download/20240107/cpython-3.11.7+20240107-x86_64-unknown-linux-gnu-install_only.tar.gz"
    PYTHON_DIR = "${env.WORKSPACE}/python"
    VENV_DIR = "${env.WORKSPACE}/venv"
  }

  stages {
    stage('Install Go and Snyk CLI') {
      steps {
        sh '''
             GO_VERSION=1.21.2
            curl -LO https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
            rm -rf /tmp/go
            tar -C /tmp -xzf go${GO_VERSION}.linux-amd64.tar.gz
            export PATH=/tmp/go/bin:$PATH

             # Install NodeJS and npm if needed for Snyk CLI (or use official Snyk binary)
            # For simplicity, download standalone Snyk binary:
            curl -Lo /tmp/snyk https://static.snyk.io/cli/latest/snyk-linux
            chmod +x /tmp/snyk
            export PATH=/tmp:$PATH

            # make scan dir
            mkdir temp_scan_dir
            cp main.go go.mod go.sum README.md Dockerfile* temp_scan_dir/
            cd temp_scan_dir
            snyk test .

            /tmp/snyk auth $SNYK_TOKEN
            /tmp/snyk code test ./temp_scan_dir --sarif-file-output=snyk-results.sarif || true
        '''
      }
    }

    stage('Display SARIF Report') {
            steps {
                sh 'ls -lrt'
            }
        }

    stage('Download Prebuilt Python') {
            steps {
                echo ":arrow_down: Downloading prebuilt Python binary..."
                sh '''
                    mkdir -p $PYTHON_DIR
                    cd $PYTHON_DIR
                    curl -L -o python.tar.gz $PYTHON_URL
                    tar -xzf python.tar.gz --strip-components=1
                    echo ":white_check_mark: Python extracted to: $PYTHON_DIR"
                '''
            }
        }

        // Step 2: Verify Python & Pip installation
    stage('Verify Python & Pip') {
            steps {
                sh '''
                    $PYTHON_DIR/bin/python3.11 --version
                    $PYTHON_DIR/bin/pip3.11 --version
                '''
            }
    }

    stage('Add Snippet to SARIF') {
      steps {
        sh '''
          $PYTHON_DIR/bin/python3.11 --version 

          $PYTHON_DIR/bin/python3.11 << EOF
import json, os

sarif_path = "snyk-results.sarif"

with open(sarif_path, "r", encoding="utf-8") as f:
    data = json.load(f)

for run in data.get("runs", []):
    for result in run.get("results", []):
        for loc in result.get("locations", []):
            phys_loc = loc.get("physicalLocation", {})
            region = phys_loc.get("region", {})
            start_line = region.get("startLine")
            end_line = region.get("endLine", start_line)

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
EOF
        '''
      }
    }

    //  stage('Display SARIF Report') {
    //         steps {
    //             sh 'cat snyk-results.sarif'
    //         }
    //     }
  }
}
