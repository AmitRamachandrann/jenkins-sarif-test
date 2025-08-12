pipeline {
    agent any

    environment {
        BRIDGE_CLI_DIR = "${WORKSPACE}/bridge-cli"
        DETECT_PROJECT_NAME = "my-blackduck-project"
        DETECT_VERSION_NAME = "1.0.0"
        BD_URL = credentials('BLACKDUCK_URL') // or use credentials if you really want
        BD_TOKEN = credentials('BLACKDUCK_API_TOKEN') // must be 'Secret text'
    }

    stages {
        stage('Download and Extract Bridge CLI') {
            steps {
                sh '''
                    mkdir -p "$BRIDGE_CLI_DIR"

                    # Download with error check
                    curl -f -L "https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/bridge/binaries/bridge-cli-bundle/latest/bridge-cli-bundle-linux64.zip" \
                        -o bridge.zip

                    # Extract with jar (no unzip needed)
                    (cd "$BRIDGE_CLI_DIR" && jar -xf ../bridge.zip)

                    # check if the binary exists
                    ls -lrt ${BRIDGE_CLI_DIR}
                    chmod +x "$BRIDGE_CLI_DIR"/bridge-cli-bundle-linux64/bridge-cli

                    # Verify
                    "$BRIDGE_CLI_DIR/bridge-cli-bundle-linux64/bridge-cli" --version
                '''
            }
        }


        stage('Run Black Duck Bridge CLI with SARIF Output') {
            steps {
                sh """
                    # Fix execute permissions for all adapter binaries
                    find bridge-cli/bridge-cli-bundle-linux64/adapters -type f -exec chmod +x {} ; true

                    "${BRIDGE_CLI_DIR}/bridge-cli-bundle-linux64/bridge-cli" \
                        --stage blackducksca \
                        blackducksca.url="${BD_URL}" \
                        blackducksca.scan.full=true \
                        blackducksca.token="${BD_TOKEN}" \
                        blackducksca_reports_sarif_create=true \
                        blackducksca_reports_sarif_file_path="output/blackduck-sarif-report.sarif"
                """
            }
        }

        stage('Check the SARIF Report') {
            steps {
                sh '''
                    echo "Checking SARIF report..."
                    ls -l output/*.sarif
                    cat output/*.sarif
                '''
            }
        }

        stage('Archive SARIF Report') {
            steps {
                archiveArtifacts artifacts: 'output/*.sarif', fingerprint: true
            }
        }
    }
}
