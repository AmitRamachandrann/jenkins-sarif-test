pipeline {
    agent any

    environment {
        SONAR_HOST = "https://sonarqube.saas-preprod.beescloud.com"
        SONAR_TOKEN = credentials('sonarqube-preprod-token') 
        PROJECT_KEY = "sarif_test_${env.BUILD_NUMBER}"
        SCANNER_VERSION = "5.0.1.3006"
        SCANNER_HOME = "${WORKSPACE}/sonar-scanner-5.0.1.3006"
        JAVA_HOME = "${WORKSPACE}/jdk17"
        PATH = "${WORKSPACE}/jdk17/bin:${PATH}"
        JQ = "${WORKSPACE}/bin/jq"
    }

    stages {

        stage('Install JDK') {
            steps {
                sh '''
                    echo "Downloading JDK..."
                    curl -sLo openjdk.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.14%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.14_7.tar.gz
                    tar -xzf openjdk.tar.gz
                    rm -rf jdk17 && mv jdk-17* jdk17
                    mkdir -p ${WORKSPACE}/bin
                    if [ ! -f ${WORKSPACE}/bin/jq ]; then
                        echo "Downloading jq..."
                        curl -sLo ${WORKSPACE}/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
                        chmod +x ${WORKSPACE}/bin/jq
                    fi
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
                    if command -v unzip >/dev/null 2>&1; then
                      unzip scanner-sq.zip
                    else
                      echo "Installing unzip..."
                      apt-get update && apt-get install -y unzip
                      unzip scanner-sq.zip
                    fi
                    rm scanner-sq.zip
                    else
                    echo "SonarScanner already installed."
                    fi
                """
            }
        }

        stage('Get user token') {
            steps {
                script {
                    // Try generating a fresh token
                    def response = sh(
                        script: """curl -s -u ${SONAR_TOKEN}: \
                        -X POST "${SONAR_HOST}/api/user_tokens/generate?name=${PROJECT_KEY}" """,
                        returnStdout: true
                    ).trim()

                    echo "Raw API response: ${response}"

                    def user_token = sh(
                        script: """echo '${response}' | ${JQ} -r '.token // empty'""",
                        returnStdout: true
                    ).trim()

                    if (user_token) {
                        echo "✅ Generated user token: ${user_token}"
                        env.USER_TOKEN = user_token
                    } else {
                        echo "⚠️ Token not returned. Likely it already exists with name ${PROJECT_KEY}"
                        echo "ℹ️ SonarQube does NOT return existing tokens, only metadata."
                    }
                }
            }
        }



        // stage('Get user token') {
        //     steps {
        //         script {
        //             def user_token = sh(script: "curl -X POST -s -u ${SONAR_TOKEN}: ${SONAR_HOST}/api/user_tokens/generate?name=${PROJECT_KEY} | ${JQ} -r '.token'", returnStdout: true)
        //             echo "Generated user token: ${user_token}"
        //         }
        //     }
        // }


        stage('SonarQube Analysis') {
            steps {
                sh """
                    chmod +x ${SCANNER_HOME}/bin/sonar-scanner
                    ${SCANNER_HOME}/bin/sonar-scanner \
                      -Dsonar.projectKey=$PROJECT_KEY \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=$SONAR_HOST \
                      -Dsonar.login=$USER_TOKEN \
                      -Dsonar.report.export.path=sonar.json
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
                                script: "curl -s -u ${SONAR_TOKEN}: ${ceTaskUrl} | ${JQ} -r '.task.status'",
                                returnStdout: true
                            ).trim()
                            echo "SonarQube CE task status: ${result}"
                            return (result == "SUCCESS")
                        }
                    }
                }
            }
        }

        // stage('Fetch Issues & Hotspots') {
        //     steps {
        //         script {
        //             def issues = sh(
        //                 script: """curl -s -u ${SONAR_TOKEN}: \\
        //                   "${SONAR_HOST}/api/issues/search?componentKeys=${PROJECT_KEY}&ps=500" | ${JQ} '.'""",
        //                 returnStdout: true
        //             ).trim()
        //             echo "===== Issues ====="
        //             echo issues

        //             def hotspots = sh(
        //                 script: """curl -s -u ${SONAR_TOKEN}: \\
        //                   "${SONAR_HOST}/api/hotspots/search?projectKey=${PROJECT_KEY}&ps=500" | ${JQ} '.'""",
        //                 returnStdout: true
        //             ).trim()
        //             echo "===== Security Hotspots ====="
        //             echo hotspots

        //             // Print the library function
        //             // echo "===== Library Function ====="
        //             // def workspacePath = env.WORKSPACE
        //             // def sarifout = helper.getSarifOutput(env.SONAR_HOST, env.SONAR_TOKEN, env.PROJECT_KEY , workspacePath, SCANNER_VERSION)
        //             // echo "${sarifout}"
        //             // cat sonar.json
        //         }
        //     }
        // }

        stage('Fetch Issues & Hotspots') {
            steps {
                sh '''
                echo "Fetching issues..."
                curl -s -u ${SONAR_TOKEN}: \
                  "${SONAR_HOST}/api/issues/search?componentKeys=${PROJECT_KEY}&ps=500" \
                  -o issues.json

                echo "Fetching hotspots..."
                curl -s -u ${SONAR_TOKEN}: \
                  "${SONAR_HOST}/api/hotspots/search?projectKey=${PROJECT_KEY}&ps=500" \
                  -o hotspots.json
                '''
            }
        }

        stage('Fetch Rules') {
            steps {
                sh '''
                echo "Extracting unique rule IDs..."
                issue_rules=$(jq -r ".issues[].rule" issues.json | sort -u)
                hotspot_rules=$(jq -r ".hotspots[].ruleKey" hotspots.json | sort -u)
                all_rules=$(printf "%s\n%s" "$issue_rules" "$hotspot_rules" | sort -u)

                echo "Fetching rules from SonarQube..."
                rm -f rules.json
                echo "[]" > rules.json

                for rid in $all_rules; do
                  echo "  -> Rule: $rid"
                  resp=$(curl -s -u ${SONAR_TOKEN}: "${SONAR_HOST}/api/rules/show?key=$rid")
                  # Append to rules.json
                  echo "$resp" | jq -c '.rule' | jq -s '.[0]' | jq -c '.' >> rules.tmp
                done

                # Merge into array
                jq -s '.' rules.tmp > rules.json
                rm -f rules.tmp
                '''
            }
        }

        stage('Build SARIF File') {
            steps {
                sh '''
                echo "Mapping issues to SARIF..."
                issue_results=$(${JQ} -c '
                  .issues[]? | {
                    ruleId: .rule,
                    level: (
                      if .severity == "MINOR" then "note"
                      elif .severity == "MAJOR" then "warning"
                      elif .severity == "CRITICAL" or .severity == "BLOCKER" then "error"
                      else "note"
                      end
                    ),
                    message: { text: (.type + ": " + .message) },
                    locations: [
                      {
                        physicalLocation: {
                          artifactLocation: { uri: (.component | split(":")[1]) },
                          region: {
                            startLine: .textRange.startLine,
                            endLine: .textRange.endLine,
                            startColumn: .textRange.startOffset,
                            endColumn: .textRange.endOffset
                          }
                        }
                      }
                    ]
                  }' issues.json)

                echo "Mapping hotspots to SARIF..."
                hotspot_results=$(${JQ} -c '
                  .hotspots[]? | {
                    ruleId: .ruleKey,
                    level: (.vulnerabilityProbability | ascii_downcase),
                    message: { text: "HOTSPOT: " + .message },
                    locations: [
                      {
                        physicalLocation: {
                          artifactLocation: { uri: (.component | split(":")[1]) },
                          region: {
                            startLine: .textRange.startLine,
                            endLine: .textRange.endLine,
                            startColumn: .textRange.startOffset,
                            endColumn: .textRange.endOffset
                          }
                        }
                      }
                    ]
                  }' hotspots.json)

                echo "Mapping rules to SARIF..."
                sarif_rules=$(${JQ} -c '
                  map({
                    id: .key,
                    name: .name,
                    shortDescription: { text: .name },
                    fullDescription: { text: .htmlDesc },
                    help: {
                      text: (.mdDesc // .htmlDesc),
                      uri: "https://sonarqube.example.com/coding_rules?open=" + .key
                    },
                    properties: {
                      tags: .tags,
                      severity: .severity,
                      type: .type,
                      lang: .lang
                    }
                  })' rules.json)

                echo "Combining into SARIF..."
                ${JQ} -n \
                  --argjson issues "[$issue_results]" \
                  --argjson hotspots "[$hotspot_results]" \
                  --argjson rules "$sarif_rules" \
                  --arg scannerVersion "${SCANNER_VERSION}" '
                {
                  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/main/sarif-2.1/schema/sarif-schema-2.1.0.json",
                  "version": "2.1.0",
                  "runs": [
                    {
                      "tool": {
                        "driver": {
                          "name": "SonarQube",
                          "version": $scannerVersion,
                          "rules": $rules
                        }
                      },
                      "results": ($issues + $hotspots)
                    }
                  ]
                }' > ${SARIF_FILE}

                echo "✅ SARIF file generated: ${SARIF_FILE}"
                '''
            }
        }

        stage('Archive SARIF') {
            steps {
                archiveArtifacts artifacts: "${SARIF_FILE}", fingerprint: true
            }
        }
    }
}

