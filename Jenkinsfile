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

        stage('Install Python & Pip (if missing)') {
            steps {
                echo '🛠️ Installing Python and Pip if not available...'
                sh '''
                    if ! command -v python3 >/dev/null 2>&1 || ! command -v pip3 >/dev/null 2>&1; then
                        echo "Installing Python 3 and pip using yum..."
                        sudo yum update -y
                        sudo yum install -y python3
                    else
                        echo "Python 3 and pip are already installed."
                    fi
                '''
            }
        }
    }
}
