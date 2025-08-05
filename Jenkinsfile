pipeline {
    agent any

    stages {
        stage('Get OS Info') {
            steps {
                echo '🖥️ Gathering OS information...'
                sh '''
                    echo "Kernel info:"
                    uname -a

                    echo ""
                    echo "OS release info:"
                    if [ -f /etc/os-release ]; then
                        cat /etc/os-release
                    elif [ -f /etc/redhat-release ]; then
                        cat /etc/redhat-release
                    else
                        echo "No known OS release file found."
                    fi
                '''
            }
        }

        stage('Check Package Managers') {
            steps {
                echo '📦 Checking for available package managers...'
                sh '''
                    echo ""
                    echo "Checking for yum:"
                    command -v yum && echo "✅ yum is available" || echo "❌ yum is NOT available"

                    echo ""
                    echo "Checking for apt:"
                    command -v apt && echo "✅ apt is available" || echo "❌ apt is NOT available"

                    echo ""
                    echo "Checking for apk:"
                    command -v apk && echo "✅ apk is available" || echo "❌ apk is NOT available"

                    echo ""
                    echo "Checking for dnf:"
                    command -v dnf && echo "✅ dnf is available" || echo "❌ dnf is NOT available"
                '''
            }
        }
    }
}
