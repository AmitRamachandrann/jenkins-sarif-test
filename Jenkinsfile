pipeline {
    agent any

    stages {
        stage('Build and Test') {
            parallel {
                stage('Build') {
                    stages {
                        stage('Compile') {
                            steps {
                                echo 'Compiling...'
                                sleep 5
                            }
                        }
                        stage('Package') {
                            steps {
                                echo 'Packaging...'
                                sleep 5
                            }
                        }
                    }
                }
                stage('Test') {
                    stages {
                        stage('Unit Tests') {
                            steps {
                                echo 'Running Unit Tests...'
                                sleep 5
                            }
                        }
                        stage('Integration Tests') {
                            steps {
                                echo 'Running Integration Tests...'
                                sleep 5
                            }
                        }
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running gosec security scan...'
                sh '''
                    if ! command -v gosec >/dev/null 2>&1; then
                        go install github.com/securego/gosec/v2/cmd/gosec@latest
                        export PATH=$PATH:$(go env GOPATH)/bin
                    fi
                    gosec -fmt sarif -out gosec-results-sarif.json ./...
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sleep 5
            }
        }
    }
}