pipeline {
    agent any

    stages {
        stage('Trivy Image Scan with Kaniko') {
            steps {
                sh '''
                # Download Kaniko executor if not present
                if [ ! -f ./kaniko-executor ]; then
                  echo "Downloading Kaniko executor..."
                  curl -sL https://github.com/GoogleContainerTools/kaniko/releases/download/v1.22.0/kaniko-linux-amd64 -o kaniko-executor
                  chmod +x ./kaniko-executor
                fi

                # Download Trivy if not present
                if ! command -v trivy > /dev/null; then
                  echo "Installing Trivy..."
                  curl -sL https://github.com/aquasecurity/trivy/releases/download/v0.65.0/trivy_0.65.0_Linux-64bit.tar.gz | tar zxvf - -C /tmp
                  mv /tmp/trivy ./trivy
                  chmod +x ./trivy
                fi

                # Build image with Kaniko and output as tarball
                ./kaniko-executor --dockerfile=Dockerfile --context=$(pwd) --no-push --tar-path=image.tar

                # Scan tarball with Trivy
                ./trivy image --input image.tar --format sarif
                '''
            }
        }
    }
}