working jenkins file

pipeline {
    agent any

    environment {
        GRYPE_BINARY_DIR = "${env.WORKSPACE}/bin"
        GRYPE_JAR_FILE = "vulnearblesqlapp-0.0.1-SNAPSHOT.jar"
        GRYPE_REPORT = "grype-report.sarif"
    }

    stages {
        stage('Install Grype') {
            steps {
                sh '''
                echo "Installing Grype..."
                mkdir -p ${GRYPE_BINARY_DIR}
                export PATH=${GRYPE_BINARY_DIR}:$PATH
                curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ${GRYPE_BINARY_DIR}
                grype version
                '''
            }
        }

        stage('Scan Local JAR with Grype') {
            steps {
                sh '''
                echo "Scanning local JAR file with Grype..."
                ${GRYPE_BINARY_DIR}/grype ${GRYPE_JAR_FILE} -o sarif > ${GRYPE_REPORT}
                '''
            }
        }

        stage('Display SARIF Report') {
            steps {
                sh '''
                echo "=== Grype SARIF Report ==="
                cat ${GRYPE_REPORT}
                '''
            }
        }

    }
}