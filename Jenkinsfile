pipeline {
    agent any
    environment {
        PYTHON_VERSION = "3.11.9"
        PYTHON_BASE_URL = "https://www.python.org/ftp/python"
        PYTHON_DIR = "${env.WORKSPACE}/python"
    }
    stages {
        stage('Download and Extract Python') {
            steps {
                echo "🐍 Downloading Python ${env.PYTHON_VERSION}..."
                sh '''
                    mkdir -p $PYTHON_DIR
                    cd $WORKSPACE

                    curl -O ${PYTHON_BASE_URL}/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
                    tar -xzf Python-${PYTHON_VERSION}.tgz
                    cd Python-${PYTHON_VERSION}

                    ./configure --prefix=$PYTHON_DIR --enable-optimizations
                    make -j$(nproc)
                    make install
                '''
            }
        }
        stage('Verify Local Python') {
            steps {
                sh '''
                    $PYTHON_DIR/bin/python3 --version
                    $PYTHON_DIR/bin/pip3 --version
                '''
            }
        }
    }
}
