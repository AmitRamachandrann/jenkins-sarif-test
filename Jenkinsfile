pipeline {
    agent any

    stages {
        stage('Check Python & Pip') {
            steps {
                echo '🔍 Checking Python & Pip availability...'
                sh '''
                    echo "Python version:"
                    command -v python3 && python3 --version || echo "python3 not found"

                    echo "\nPip version:"
                    command -v pip3 && pip3 --version || echo "pip3 not found"
                '''
            }
        }
    }
}
