pipeline {
    agent any

    environment {
        SONAR_HOST = "https://sonarqube.beescloud.com"
        SONAR_TOKEN = credentials('sonarqube-token') 
        PROJECT_KEY = "sarif-test-cli-02"
        SCANNER_VERSION = "5.0.1.3006"
        SCANNER_HOME = "${WORKSPACE}/sonar-scanner-5.0.1.3006"
        JAVA_HOME = "${WORKSPACE}/jdk17"
        PATH = "${WORKSPACE}/jdk17/bin:${PATH}"
    }

    stages {

        stage('Install JDK') {
            steps {
                sh '''
                    echo "Downloading JDK..."
                    curl -sLo openjdk.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.14%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.14_7.tar.gz
                    tar -xzf openjdk.tar.gz
                    mv jdk-17* jdk17
                '''
            }
        }

        stage('Install SonarScanner CLI') {
            steps {
                sh """
                    SCANNER_VERSION=5.0.1.3006
                    SCANNER_HOME=sonar-scanner-${SCANNER_VERSION}-linux

                    if [ ! -d "${SCANNER_HOME}" ]; then
                    echo "Downloading Sonar Scanner CLI..."
                    curl -sLo scanner-sq.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006.zip
                    # Use it
                    jar -xf scanner-sq.zip
                    rm scanner-sq.zip
                    else
                    echo "SonarScanner already installed."
                    fi
                """
            }
        }


        stage('SonarQube Analysis') {
            steps {
                sh """
                    chmod +x ${SCANNER_HOME}/bin/sonar-scanner
                    ${SCANNER_HOME}/bin/sonar-scanner \
                      -Dsonar.projectKey=$PROJECT_KEY \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=$SONAR_HOST \
                      -Dsonar.login=$SONAR_TOKEN
                """
            }
        }

        stage('Wait for Analysis') {
            steps {
                script {
                    def reportTask = readFile '.scannerwork/report-task.txt'
                    def ceTaskUrl = reportTask.readLines()
                        .find { it.startsWith("ceTaskUrl=") }
                        .replace("ceTaskUrl=", "")

                    echo "Waiting for SonarQube CE task to complete: ${ceTaskUrl}"

                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            def result = sh(
                                script: "curl -s -u ${SONAR_TOKEN}: ${ceTaskUrl} | jq -r '.task.status'",
                                returnStdout: true
                            ).trim()
                            echo "SonarQube CE task status: ${result}"
                            return (result == "SUCCESS")
                        }
                    }
                }
            }
        }

        stage('Fetch Issues & Hotspots') {
            steps {
                script {
                    def issues = sh(
                        script: """curl -s -u ${SONAR_TOKEN}: \\
                          "${SONAR_HOST}/api/issues/search?componentKeys=${PROJECT_KEY}&ps=500" | jq '.'""",
                        returnStdout: true
                    )
                    echo "===== Issues ====="
                    echo issues

                    def hotspots = sh(
                        script: """curl -s -u ${SONAR_TOKEN}: \\
                          "${SONAR_HOST}/api/hotspots/search?projectKey=${PROJECT_KEY}&ps=500" | jq '.'""",
                        returnStdout: true
                    )
                    echo "===== Security Hotspots ====="
                    echo hotspots
                }
            }
        }
    }
}
