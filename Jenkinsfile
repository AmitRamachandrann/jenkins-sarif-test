pipeline {
    agent any

    environment {
        SARIF_FILE = "gitleaks-report.sarif"
    }

    stages {

        stage('Install Gitleaks') {
            steps {
                sh '''
                    mkdir -p $WORKSPACE/bin
                    if ! [ -x "$WORKSPACE/bin/gitleaks" ]; then
                        echo "Installing gitleaks locally in $WORKSPACE/bin ..."
                        GITLEAKS_VERSION=8.18.1
                        curl -sSL https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz \
                        -o gitleaks.tar.gz
                        tar -xzf gitleaks.tar.gz -C $WORKSPACE/bin gitleaks
                        chmod +x $WORKSPACE/bin/gitleaks
                    fi
                    export PATH=$WORKSPACE/bin:$PATH
                    $WORKSPACE/bin/gitleaks version
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
