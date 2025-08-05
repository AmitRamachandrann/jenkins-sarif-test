pipeline {
    agent any

    stages {
        stage('Check Python and Pip Versions') {
            steps {
                echo 'Checking Python and Pip versions...'
                sh '''
                    which python || true
                    which python3 || true
                    which pip || true
                    which pip3 || true

                    python --version || true
                    python3 --version || true

                    pip --version || true
                    pip3 --version || true
                '''
            }
        }
    }
}
