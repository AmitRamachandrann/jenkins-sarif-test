pipeline {
    agent any

    environment {
        SARIF_FILE = "gitleaks-report.sarif"
        GITLEAKS_BIN = "${WORKSPACE}/bin"
        PATH = "${GITLEAKS_BIN}:${env.PATH}"
    }

    stages {

        stage('Install Gitleaks') {
            steps {
                sh '''
                    mkdir -p $GITLEAKS_BIN
                    if ! [ -x "$GITLEAKS_BIN/gitleaks" ]; then
                        echo "Installing gitleaks locally in $GITLEAKS_BIN ..."
                        GITLEAKS_VERSION=8.18.1
                        curl -sSL https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz \
                        -o gitleaks.tar.gz
                        tar -xzf gitleaks.tar.gz -C $GITLEAKS_BIN gitleaks
                        chmod +x $GITLEAKS_BIN/gitleaks
                    fi
                    gitleaks version
                '''
            }
        }

        stage('Prepare SARIF File') {
            steps {
                sh """
                    if [ -f "${SARIF_FILE}" ]; then
                        rm -f "${SARIF_FILE}"
                    fi
                """
            }
        }

        stage('Run Gitleaks Scan') {
            steps {
                sh """
                    ${GITLEAKS_BIN}/gitleaks detect \
                    --source . \
                    --no-git \
                    --report-format sarif \
                    --report-path ${SARIF_FILE} || true
                """
            }
        }

        stage('Show SARIF Output') {
            steps {
                script {
                    if (fileExists("${SARIF_FILE}")) {
                        def sarifReport = readFile("${SARIF_FILE}")
                        echo "===== Gitleaks SARIF Report ====="
                        echo sarifReport
                    } else {
                        echo "No SARIF report found"
                    }
                }
            }
        }

        stage('Archive SARIF Report') {
            steps {
                archiveArtifacts artifacts: "${SARIF_FILE}", fingerprint: true
            }
        }
    }
}
