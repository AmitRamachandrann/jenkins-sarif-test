pipeline {
    agent any

    stages {
        stage('Check apt Availability') {
            steps {
                echo '🔍 Checking if apt is available...'
                sh '''
                    echo "Looking for apt:"
                    if command -v apt >/dev/null 2>&1; then
                        echo "✅ apt is available"
                        apt --version
                    else
                        echo "❌ apt is NOT available"
                    fi
                '''
            }
        }
    }
}
