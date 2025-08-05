pipeline {
    agent any
    environment {
        PYTHON_DIR = "${env.WORKSPACE}/python"
        PYTHON_URL = "https://github.com/indygreg/python-build-standalone/releases/download/20240107/cpython-3.11.7+20240107-x86_64-unknown-linux-gnu-install_only.tar.gz"
    }
    stages {
        stage('Download Prebuilt Python') {
            steps {
                echo "⬇️ Downloading prebuilt Python binary..."
                sh '''
                    mkdir -p $PYTHON_DIR
                    cd $PYTHON_DIR

                    curl -L -o python.tar.gz $PYTHON_URL
                    tar -xzf python.tar.gz --strip-components=1

                    echo "✅ Python extracted to: $PYTHON_DIR"
                '''
            }
        }
        stage('Verify Python & Pip') {
            steps {
                sh '''
                    $PYTHON_DIR/bin/python3.11 --version
                    $PYTHON_DIR/bin/pip3.11 --version
                '''
            }
        }
    }
}
