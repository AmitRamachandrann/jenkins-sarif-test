pipeline {
    agent any

    environment {
        VENV_DIR = "${env.WORKSPACE}/venv"
        NJSSCAN = "${VENV_DIR}/bin/njsscan"
        TARGET_DIR = "${WORKSPACE}/test-nodejs-code"
        SARIF_FILE = "${WORKSPACE}/njsscan-results.sarif"
    }

    stages {
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
