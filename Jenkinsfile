pipeline {
  agent any

  environment {
    PYTHON_DIR = "${env.WORKSPACE}/python"  // Use the same Python path as first pipeline
    PYTHON_URL = "https://github.com/indygreg/python-build-standalone/releases/download/20240107/cpython-3.11.7+20240107-x86_64-unknown-linux-gnu-install_only.tar.gz"
    VENV_DIR = "${env.WORKSPACE}/venv"
    SCAN_DIR = "${env.WORKSPACE}/test-nodejs-code"
  }

  stages {
    stage('Ensure Python 3.11') {
            steps {
                echo "🐍 Checking if Python 3.11 exists..."
                sh '''
                    if command -v python3.11 >/dev/null 2>&1; then
                        echo "✅ System Python 3.11 found: $(python3.11 --version)"
                    elif [ -x "$PYTHON_DIR/bin/python3.11" ]; then
                        echo "✅ Prebuilt Python 3.11 already installed at $PYTHON_DIR"
                        "$PYTHON_DIR/bin/python3.11" --version
                    else
                        echo "⬇️ Installing prebuilt Python 3.11..."
                        mkdir -p "$PYTHON_DIR"
                        cd "$PYTHON_DIR"
                        curl -L -o python.tar.gz "$PYTHON_URL"
                        tar -xzf python.tar.gz --strip-components=1
                        echo "✅ Python extracted to: $PYTHON_DIR"
                    fi
                '''
            }
        }
    stage('Create Virtual Environment') {
      steps {
        echo "🐍 Creating virtual environment if missing..."
        sh '''
          if [ ! -d "$VENV_DIR" ]; then
            $PYTHON_DIR/bin/python3.11 -m venv "$VENV_DIR"
          else
            echo "✅ Virtualenv already exists."
          fi
        '''
      }
    }

    stage('Install njsscan if missing') {
      steps {
        echo "📦 Checking for njsscan in venv..."
        sh '''
          source "$VENV_DIR/bin/activate"
          if ! njsscan --version > /dev/null 2>&1; then
            pip install --upgrade pip
            pip install njsscan
          else
            echo "✅ njsscan already installed in venv."
          fi
        '''
      }
    }

    stage('Install semgrep if missing') {
      steps {
        echo "📦 Checking for semgrep in venv..."
        sh '''
          source "$VENV_DIR/bin/activate"
          if ! semgrep --version > /dev/null 2>&1; then
            pip install semgrep
          else
            echo "✅ semgrep already installed in venv."
          fi
        '''
      }
    }

    stage('Run njsscan and Output SARIF') {
      steps {
        echo "🚨 Running njsscan on $SCAN_DIR..."
        sh '''
          source "$VENV_DIR/bin/activate"
          njsscan --sarif "$SCAN_DIR" > njsscan-output.sarif || true
          echo "📄 ==== SARIF Output Start ===="
          cat njsscan-output.sarif
          echo "📄 ==== SARIF Output End ===="
        '''
      }
    }
  }
}
