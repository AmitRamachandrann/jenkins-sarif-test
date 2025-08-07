pipeline {
    agent any

    environment {
        GRYPE_BINARY_DIR = "${env.WORKSPACE}/bin"
        GRYPE_SCAN_TARGET = "${env.WORKSPACE}/test-workflow-ninja"
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
        
        stage('List Files') {
            steps {
                sh '''
                echo "📁 Current workspace contents:"
                ls -la ${WORKSPACE}
                '''
            }
        }

        stage('Scan Folder with Grype') {
            steps {
                sh '''
                echo "Scanning folder '${GRYPE_SCAN_TARGET}' with Grype..."
                ${GRYPE_BINARY_DIR}/grype ${GRYPE_SCAN_TARGET} -o sarif > ${GRYPE_REPORT}
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