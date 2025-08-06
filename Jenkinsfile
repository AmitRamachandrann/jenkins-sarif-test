pipeline {
    agent any

    environment {
        GRYPE_VERSION = 'v0.97.1' // or latest
        GRYPE_BINARY_DIR = "${env.WORKSPACE}/bin"
        TARGET_IMAGE = 'ubuntu:20.04'
        GRYPE_REPORT = 'grype-report.sarif'
    }

    stages {
        stage('Install Grype') {
            steps {
                script {
                    sh '''
                    echo "Installing Grype..."
                    mkdir -p ${GRYPE_BINARY_DIR}
                    export PATH=${GRYPE_BINARY_DIR}:$PATH
                    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ${GRYPE_BINARY_DIR}
                    grype version
                    '''
                }
            }
        }

        stage('Pull Vulnerable Docker Image') {
            steps {
                sh '''
                echo "Pulling image: ${TARGET_IMAGE}"
                docker pull ${TARGET_IMAGE}
                '''
            }
        }

        stage('Run Grype and Generate SARIF') {
            steps {
                sh '''
                echo "Running Grype scan on ${TARGET_IMAGE}"
                ${GRYPE_BINARY_DIR}/grype ${TARGET_IMAGE} -o sarif > ${GRYPE_REPORT}
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