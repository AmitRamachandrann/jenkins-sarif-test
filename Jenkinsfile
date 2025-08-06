pipeline {
    agent any

    environment {
        GRYPE_VERSION = 'v0.97.1' // or latest
        GRYPE_BINARY_DIR = '/usr/local/bin'
        TARGET_IMAGE = 'ubuntu:20.04'
        GRYPE_REPORT = 'grype-report.sarif'
    }

    stages {
        stage('Install Grype') {
            steps {
                script {
                    sh '''
                    echo "Installing Grype..."
                    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b ${GRYPE_BINARY_DIR}
                    grype version
                    '''
                }
            }
        }

        stage('Pull Vulnerable Docker Image') {
            steps {
                sh '''
                echo "Pulling image: $TARGET_IMAGE"
                docker pull $TARGET_IMAGE
                '''
            }
        }

        stage('Run Grype and Generate SARIF') {
            steps {
                sh '''
                echo "Running Grype scan on $TARGET_IMAGE"
                grype $TARGET_IMAGE -o sarif > $GRYPE_REPORT
                '''
            }
        }

        stage('Display SARIF Report') {
            steps {
                sh '''
                echo "=== Grype SARIF Report ==="
                cat $GRYPE_REPORT
                '''
            }
        }
    }
}