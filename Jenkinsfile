pipeline {
    agent any

    stages {
        stage('Trivy Image Scan') {
            steps {
                sh '''
                # Check if Docker is installed
                if ! command -v docker > /dev/null; then
                  echo "Docker not found. Installing Docker..."
                  curl -fsSL https://get.docker.com -o get-docker.sh
                  sh get-docker.sh
                fi

                # Check if Trivy is installed
                if ! command -v trivy > /dev/null; then
                  echo "Installing Trivy..."
                  curl -sL https://github.com/aquasecurity/trivy/releases/download/v0.65.0/trivy_0.65.0_Linux-64bit.tar.gz | tar zxvf - -C /tmp
                  mv /tmp/trivy ./trivy
                  chmod +x ./trivy
                fi

                # Build Docker image
                docker build -t myapp:latest .

                # Save image as tarball
                docker save myapp:latest -o image.tar

                # Scan tarball with Trivy
                ./trivy image --input image.tar --format sarif
                '''
            }
        }       
    }
}