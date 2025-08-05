pipeline {
    agent any

    environment {
        SPOTBUGS_JAR = 'spotbugs.jar'
        FINSECBUGS_PLUGIN = 'findsecbugs-plugin-1.14.0.jar'
        TARGET_JAR = 'vulnearblesqlapp-0.0.1-SNAPSHOT.jar'
        REPORT_FILE = 'findsecbugs-report.sarif'
    }

    stages {
        stage('Verify Java Installation') {
            steps {
                script {
                    def javaInstalled = sh(script: 'command -v java', returnStatus: true) == 0
                    if (!javaInstalled) {
                        error "❌ Java is not installed."
                    }
                    sh 'java -version'
                }
            }
        }

        stage('Run SpotBugs Analysis') {
            steps {
                script {
                    def filesExist = sh(
                        script: "[ -f ${SPOTBUGS_JAR} ] && [ -f ${FINSECBUGS_PLUGIN} ] && [ -f ${TARGET_JAR} ]",
                        returnStatus: true
                    ) == 0

                    if (!filesExist) {
                        error "❌ Required files not found: spotbugs.jar, plugin, or target JAR."
                    }

                    sh """
                        java -jar ${SPOTBUGS_JAR} \\
                          -textui \\
                          -pluginList ${FINSECBUGS_PLUGIN} \\
                          -sarif \\
                          -output ${REPORT_FILE} \\
                          ${TARGET_JAR}
                    """
                }
            }
        }

        stage('Show SARIF Output') {
            steps {
                sh 'cat findsecbugs-report.sarif'
            }
        }
    }
}
