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
                    set -e
                    BRIDGE_DIR="${WORKSPACE}/bridge-cli"
                    mkdir -p "$BRIDGE_DIR"

                    # Download with error check
                    curl -f -L "https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/bridge/binaries/bridge-cli-bundle/latest/bridge-cli-bundle-linux64.zip" \
                        -o bridge.zip

                    # Extract with jar (no unzip needed)
                    (cd "$BRIDGE_DIR" && jar -xf ../bridge.zip)

                    # Verify
                    "$BRIDGE_DIR/synopsys-bridge" --version
                '''
            }
        }

        stage('Check the binary') {
            steps {
                sh """
                    echo "Checking Bridge CLI binary..."
                    ls -l ${BRIDGE_CLI_DIR}
                """
            }
        }

        stage('Run Black Duck Bridge CLI with SARIF Output') {
            steps {
                sh """
                    "${BRIDGE_CLI_DIR}/bridge" \
                        --stage detect \
                        --detect.project.name="${DETECT_PROJECT_NAME}" \
                        --detect.project.version.name="${DETECT_VERSION_NAME}" \
                        --detect.output.path="${WORKSPACE}/output" \
                        --detect.blackduck.url="${BD_URL}" \
                        --detect.blackduck.api.token="${BD_TOKEN}" \
                        --detect.output.format=SARIF
                """
            }
        }

        stage('Archive SARIF Report') {
            steps {
                archiveArtifacts artifacts: 'output/*.sarif', fingerprint: true
            }
        }
    }
}
