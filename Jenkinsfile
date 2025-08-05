pipeline {
    agent any

    environment {
        VENV_DIR = "${env.WORKSPACE}/venv"
        NJSSCAN = "${VENV_DIR}/bin/njsscan"
        TARGET_DIR = "${WORKSPACE}/test-nodejs-code"
        SARIF_FILE = "${WORKSPACE}/njsscan-results.sarif"
    }

    stages {
        stage('Install semgrep if missing') {
    steps {
        echo '📦 Checking for semgrep...'
        sh '''
            source ${VENV_DIR}/bin/activate
            if ! command -v semgrep >/dev/null 2>&1; then
                echo "⏬ semgrep not found. Installing..."
                pip install semgrep
            else
                echo "✅ semgrep is already installed."
            fi
        '''
    }
}
        stage('Run njsscan and Output SARIF') {
            steps {
                echo '🚨 Running njsscan on test-nodejs-code...'
                sh '''
                    ${NJSSCAN} --sarif ${TARGET_DIR} > ${SARIF_FILE}
                    echo "🔎 njsscan SARIF output:"
                    cat ${SARIF_FILE}
                '''
            }
        }
    }
}
