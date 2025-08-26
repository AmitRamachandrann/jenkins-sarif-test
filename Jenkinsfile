pipeline {
    agent any

    environment {
        SARIF_FILE = "gitleaks-report.sarif"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Gitleaks') {
            steps {
                sh '''
                    if ! command -v gitleaks >/dev/null 2>&1; then
                        echo "Installing gitleaks..."
                        curl -sSL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks-linux-amd64.tar.gz \
                          | tar -xz -C /usr/local/bin gitleaks
                    fi
                '''
            }
        }

        stage('Run Gitleaks Scan') {
            steps {
                sh """
                    gitleaks detect \
                      --source . \
                      --report-format sarif \
                      --report-path ${SARIF_FILE} || true
                """
            }
        }

        stage('Show SARIF Output') {
            steps {
                script {
                    def sarifReport = readFile("${SARIF_FILE}")
                    echo "===== Gitleaks SARIF Report ====="
                    echo sarifReport
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
