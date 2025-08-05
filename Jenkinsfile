pipeline {
    agent any

    stages {
        stage('Check Java Installation') {
            steps {
                script {
                    def javaInstalled = sh(script: 'command -v java', returnStatus: true) == 0

                    if (javaInstalled) {
                        echo "✅ Java is installed."
                        sh 'java -version'
                    } else {
                        echo "❌ Java is NOT installed."
                        // Optionally, fail the build
                        error("Java is not installed on this agent.")
                    }
                }
            }
        }
    }
}
