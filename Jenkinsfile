pipeline {
    agent {
        docker {
            image 'python:3.11-slim'
        }
    }

    stages {
        stage('Check Python & Pip') {
            steps {
                echo '🔍 Checking Python & Pip inside Docker container...'
                sh '''
                    echo "Python version:"
                    python3 --version

                    echo "\nPip version:"
                    pip3 --version
                '''
            }
        }
    }
}
