pipeline {
    agent any

    environment {
        PYTHON_HOME = "${env.WORKSPACE}/python"
        VENV_DIR = "${env.WORKSPACE}/venv"
        SCAN_DIR = "${env.WORKSPACE}/test-nodejs-code"
        SARIF_FILE = "${env.WORKSPACE}/njsscan-report.sarif"
    }

    stages {
        stage('Create Virtual Environment') {
            steps {
                echo '🐍 Creating virtual environment if missing...'
                sh '''
                    if [ ! -d "${VENV_DIR}" ]; then
                        ${PYTHON_HOME}/bin/python3 -m venv ${VENV_DIR}
                    else
                        echo "✅ Virtualenv already exists."
                    fi
                '''
            }
        }

        stage('Install njsscan if missing') {
            steps {
                echo '📦 Checking for njsscan in venv...'
                sh '''
                    source ${VENV_DIR}/bin/activate
                    if ! "${VENV_DIR}/bin/njsscan" --version >/dev/null 2>&1; then
                        echo "⏬ Installing njsscan..."
                        pip install njsscan
                    else
                        echo "✅ njsscan already installed in venv."
                    fi
                '''
            }
        }

        stage('Install semgrep if missing') {
            steps {
                echo '📦 Checking for semgrep in venv...'
                sh '''
                    source ${VENV_DIR}/bin/activate
                    if ! "${VENV_DIR}/bin/semgrep" --version >/dev/null 2>&1; then
                        echo "⏬ Installing semgrep..."
                        pip install semgrep
                    else
                        echo "✅ semgrep already installed in venv."
                    fi
                '''
            }
        }

        stage('Run njsscan and Output SARIF') {
            steps {
                echo "🚨 Running njsscan on ${SCAN_DIR}..."
                sh '''
                    source ${VENV_DIR}/bin/activate
                    njsscan --sarif "${SCAN_DIR}" > "${SARIF_FILE}"
                    echo "📄 SARIF Output:"
                    cat "${SARIF_FILE}"
                '''
            }
        }
    }
}
