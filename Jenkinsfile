pipeline {
    agent any

    environment {
        SPOTBUGS_JAR = 'spotbugs-4.9.3/spotbugs-4.9.3/lib/spotbugs.jar'
        FSBUGS_PLUGIN = 'fsb/lib/findsecbugs-plugin-1.14.0.jar'
        OUTPUT_SARIF = 'findsecbugs-report.sarif'
        TARGET_JAR   = 'vulnearblesqlapp-0.0.1-SNAPSHOT.jar'
    }

    stages {
        stage('Run SpotBugs + FindSecBugs') {
            steps {
                script {
                    sh '''
                    java -jar $SPOTBUGS_JAR \
                      -textui \
                      -pluginList $FSBUGS_PLUGIN \
                      -sarif \
                      -output $OUTPUT_SARIF \
                      $TARGET_JAR
                    '''
                }
            }
        }

        stage('Display SARIF Report') {
            steps {
                sh 'cat findsecbugs-report.sarif'
            }
        }
    }
}
