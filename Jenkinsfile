pipeline {
    agent any

    environment {
        SPOTBUGS_URL = "https://github.com/spotbugs/spotbugs/releases/download/4.9.3/spotbugs-4.9.3.zip"
        FINDBUGS_URL = "https://github.com/find-sec-bugs/find-sec-bugs/archive/refs/tags/version-1.14.0.zip"
        SPOTBUGS_ZIP = "spotbugs-4.9.3.zip"
        FINDBUGS_ZIP = "version-1.14.0.zip"
    }

    stages {
        stage('Download SpotBugs & FindSecBugs') {
            steps {
                sh '''
                    if [ ! -f "$SPOTBUGS_ZIP" ]; then
                      echo "Downloading SpotBugs..."
                      curl -LO "$SPOTBUGS_URL"
                    fi

                    if [ ! -f "$FINDBUGS_ZIP" ]; then
                      echo "Downloading FindSecBugs..."
                      curl -LO "$FINDBUGS_URL"
                    fi
                '''
            }
        }

        stage('Extract Tools (jar instead of unzip)') {
            steps {
                sh '''
                    if [ ! -d "spotbugs-4.9.3" ]; then
                      echo "Extracting SpotBugs with jar..."
                      mkdir spotbugs-4.9.3
                      cd spotbugs-4.9.3
                      jar xf ../$SPOTBUGS_ZIP
                      cd ..
                    fi

                    if [ ! -d "find-sec-bugs-version-1.14.0" ]; then
                      echo "Extracting FindSecBugs with jar..."
                      mkdir find-sec-bugs-version-1.14.0
                      cd find-sec-bugs-version-1.14.0
                      jar xf ../$FINDBUGS_ZIP
                      cd ..
                    fi
                '''
            }
        }

        stage('Run SpotBugs + FindSecBugs (SARIF)') {
            steps {
                sh '''
                    java -jar spotbugs-4.9.3/lib/spotbugs.jar \
                      -textui \
                      -pluginList find-sec-bugs-version-1.14.0/findsecbugs-plugin-1.14.0.jar \
                      -sarif \
                      -output findsecbugs-report.sarif \
                      vulnearblesqlapp-0.0.1-SNAPSHOT.jar
                '''
            }
        }

        stage('Print SARIF Report') {
            steps {
                sh 'cat findsecbugs-report.sarif'
            }
        }
    }
}
