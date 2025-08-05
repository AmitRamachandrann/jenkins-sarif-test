pipeline {
    agent any

    stages {

        stage('Security Scan') {
            steps {
                echo 'Running gosec security scan...'
                sh '''
                    # Install Go if not present
                    if ! command -v go >/dev/null 2>&1; then
                        GO_VERSION=1.22.3
                        curl -LO https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
                        mkdir -p "$HOME/go"
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
                    gosec -fmt sarif ./...
                '''
            }
        }

    }
}