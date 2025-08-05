pipeline {
    agent any

    stages {
        stage('Detect OS Info') {
            steps {
                echo 'Gathering OS and environment info...'
                sh '''
                    echo "Hostname:"
                    hostname || echo "hostname not found"

                    echo "\n OS Info:"
                    uname -a || echo "uname not found"

                    echo "\n Current Directory:"
                    pwd

                    echo "\n Directory Listing:"
                    ls -alh

                    echo "\n Environment Variables:"
                    env
                '''
            }
        }
    }
}
