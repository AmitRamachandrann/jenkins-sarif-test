pipeline {
    agent {
        docker {
            image 'gcr.io/kaniko-project/executor:latest'
            args "-v ${env.WORKSPACE}:/workspace"
        }
    }

    stages {
        stage('Trivy Image Scan with Kaniko') {
            steps {
                sh '''
                # Build image with Kaniko and output as tarball
                /kaniko/executor --dockerfile=Dockerfile --context=/workspace --no-push --tar-path=/workspace/image.tar

                # Download Trivy if not present
                if ! command -v trivy > /dev/null; then
                  echo "Installing Trivy..."
                  curl -sL https://github.com/aquasecurity/trivy/releases/download/v0.65.0/trivy_0.65.0_Linux-64bit.tar.gz | tar zxvf - -C /tmp
                  mv /tmp/trivy ./trivy
                  chmod +x ./trivy
                fi

                # Scan tarball with Trivy
                ./trivy image --input /workspace/image.tar --format sarif
                '''
            }
        }
    }
}
