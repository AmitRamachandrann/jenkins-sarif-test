pipeline {
    agent any

    stages {
        stage('Check yum Availability') {
            steps {
                echo '🔍 Checking if yum is available...'
                sh '''
                    echo "Looking for yum:"
                    if command -v yum >/dev/null 2>&1; then
                        echo "✅ yum is available"
                        yum --version
                    else
                        echo "❌ yum is NOT available"
                    fi
                '''
            }
        }
    }
}
