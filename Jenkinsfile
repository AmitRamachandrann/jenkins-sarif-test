pipeline {
    agent any

    environment {
        BRIDGE_CLI_VERSION = "latest" 
        BRIDGE_CLI_DIR = "${WORKSPACE}/bridge-cli"
        DETECT_PROJECT_NAME = "my-blackduck-project"
        DETECT_VERSION_NAME = "1.0.0"
        BD_URL = credentials('BLACKDUCK_URL')        // Jenkins credential: Black Duck server URL
        BD_TOKEN = credentials('BLACKDUCK_API_TOKEN') // Jenkins credential: Black Duck API token
    }

    stages {
        stage('Download Bridge CLI') {
            steps {
                sh """
                    apk add --no-cache unzip
                    mkdir -p ${BRIDGE_CLI_DIR}
                    curl -sL https://detect.synopsys.com/bridge/ci/latest/linux64.zip -o bridge.zip
                    unzip -o bridge.zip -d ${BRIDGE_CLI_DIR}
                    chmod +x ${BRIDGE_CLI_DIR}/synopsys-bridge
                """
            }
        }

        stage('Run Black Duck Bridge CLI with SARIF Output') {
            steps {
                sh """
                    ${BRIDGE_CLI_DIR}/synopsys-bridge \
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
