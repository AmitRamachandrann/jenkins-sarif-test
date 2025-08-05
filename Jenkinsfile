pipeline {
    agent any
    stages {
        stage('Check Curl and Wget') {
            steps {
                echo '🌐 Checking for curl or wget...'
                sh '''
                    echo "Checking for curl:"
                    command -v curl && echo "✅ curl is available" || echo "❌ curl is NOT available"

                    echo ""
                    echo "Checking for wget:"
                    command -v wget && echo "✅ wget is available" || echo "❌ wget is NOT available"
                '''
            }
        }
    }
}
