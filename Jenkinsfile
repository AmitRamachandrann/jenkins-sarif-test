pipeline {
    agent any

    environment {
        VENV_DIR = "${env.WORKSPACE}/venv"
    }

    stages {
        stage('Print njsscan Version') {
            steps {
                sh '''
                    if [ -f "$VENV_DIR/bin/njsscan" ]; then
                        source $VENV_DIR/bin/activate
                        echo "🔍 njsscan version:"
                        njsscan --version
                    else
                        echo "❌ njsscan is not installed at $VENV_DIR"
                        exit 1
                    fi
                '''
            }
        }
    }
}
