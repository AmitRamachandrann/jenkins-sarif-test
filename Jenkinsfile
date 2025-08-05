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
                    else
                      echo "✅ SpotBugs zip already exists. Skipping download."
                    fi

                    if [ ! -f "$FINDBUGS_ZIP" ]; then
                      echo "Downloading FindSecBugs..."
                      curl -LO "$FINDBUGS_URL"
                    else
                      echo "✅ FindSecBugs zip already exists. Skipping download."
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
                    SPOTBUGS_JAR=$(find spotbugs-4.9.3 -name spotbugs.jar | head -n 1)
                    FINDBUGS_PLUGIN_JAR=$(find find-sec-bugs-version-1.14.0 -name 'findsecbugs-plugin-*.jar' | head -n 1)

                    if [ ! -f "$SPOTBUGS_JAR" ]; then
                      echo "❌ spotbugs.jar not found!"
                      find spotbugs-4.9.3
                      exit 1
                    fi

                    if [ ! -f "$FINDBUGS_PLUGIN_JAR" ]; then
                      echo "❌ findsecbugs plugin JAR not found!"
                      find find-sec-bugs-version-1.14.0
                      exit 1
                    fi

                    echo "✅ Running SpotBugs with plugin..."
                    java -jar "$SPOTBUGS_JAR" \
                      -textui \
                      -pluginList "$FINDBUGS_PLUGIN_JAR" \
                      -sarif \
                      -output findsecbugs-report.sarif \
                      vulnearblesqlapp-0.0.1-SNAPSHOT.jar
                '''
            }
        }

        stage('Print SARIF Report') {
            steps {
                sh '''
                    echo "📄 SARIF Report Output:"
                    cat findsecbugs-report.sarif
                '''
            }
        }
    }
}
