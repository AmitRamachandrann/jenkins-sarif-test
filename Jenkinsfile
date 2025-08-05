pipeline {
    agent any

    stages {
        stage('Check apt Availability') {
            steps {
                echo '🔍 Checking if apt is available...'
                sh '''
                    whoami
                    uname -a
                    lsb_release -a
                '''
            }
        }
    }
}
