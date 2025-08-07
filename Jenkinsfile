pipeline {
    agent any 

    stages {
        stage('Install Jfrog') {
            steps {
                sh '''
                echo "Installing Jfrog..."
                curl -fL https://install-cli.jfrog.io | sh
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
                jf audit --format=sarif
                '''
            }
        }

    }
}