pipeline {
    agent any

    stages {
        stage('Show Branch Info') {
            steps {
                script {
                    echo "🔀 Building branch: ${env.BRANCH_NAME}"
                }
            }
        }

        stage('List All Files') {
            steps {
                echo "📄 Listing all files in the repository:"
                sh 'find . -type f'
            }
        }
    }
}
