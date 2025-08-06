pipeline {
  agent any

  environment {
    VENV_DIR = "${env.WORKSPACE}/venv"
    SCAN_DIR = "${env.WORKSPACE}/test-nodejs-code"
  }

  stages {
    stage('Create Virtual Environment') {
      steps {
        echo "🐍 Creating virtual environment if missing..."
        sh '''
          if [ ! -d "$VENV_DIR" ]; then
            python3.11 -m venv "$VENV_DIR"
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
            pip3.11 install --upgrade pip
            pip3.11 install njsscan
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
            pip3.11 install semgrep
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
