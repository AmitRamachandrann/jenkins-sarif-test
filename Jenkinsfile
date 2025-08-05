pipeline {
    agent any

    environment {
        PYTHON_DIR = "${env.WORKSPACE}/python"
        VENV_DIR = "${env.WORKSPACE}/venv"
    }

    stages {
        stage('Setup Virtualenv and Install njsscan if Missing') {
            steps {
                sh '''
                    if [ ! -d "$VENV_DIR" ]; then
                        echo "🐍 Creating virtualenv at $VENV_DIR"
                        $PYTHON_DIR/bin/python3.11 -m venv $VENV_DIR
                    else
                        echo "✅ Virtualenv already exists at $VENV_DIR"
                    fi

                    source $VENV_DIR/bin/activate

                    if ! $VENV_DIR/bin/pip show njsscan > /dev/null 2>&1; then
                        echo "📦 Installing njsscan..."
                        $VENV_DIR/bin/pip install --upgrade pip
                        $VENV_DIR/bin/pip install njsscan
                    else
                        echo "✅ njsscan is already installed"
                    fi
                '''
            }
        }
    }
}
