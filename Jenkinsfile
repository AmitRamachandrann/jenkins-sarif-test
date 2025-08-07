pipeline {
    agent any 

    environment {
        JFROG_BINARY_DIR = "${env.WORKSPACE}/bin"
    }

    stages {
        stage('Install Jfrog') {
            steps {
                sh '''
                echo "Installing Jfrog..."
                mkdir -p ${JFROG_BINARY_DIR}
                export PATH=${JFROG_BINARY_DIR}:$PATH
                curl -fL https://install-cli.jfrog.io | sh -s -- -b ${JFROG_BINARY_DIR}
                jg -v
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

        stage('Scan Folder with Jfrog') {
            steps {
                sh '''
                ${JFROG_BINARY_DIR}/jf audit --format=sarif
                '''
            }
        }

    }
}