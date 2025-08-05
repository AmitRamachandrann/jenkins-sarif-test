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
                    # Install Go if not present
                    if ! command -v go >/dev/null 2>&1; then
                        GO_VERSION=1.22.3
                        curl -LO https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
                        rm -rf "$HOME/go" && mkdir -p "$HOME/go"
                        tar -C "$HOME" -xzf go$GO_VERSION.linux-amd64.tar.gz
                        export PATH="$HOME/go/bin:$PATH"
                    else
                        export PATH="$HOME/go/bin:$PATH"
                    fi
                    # Install gosec if not present
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