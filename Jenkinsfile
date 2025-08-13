pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
    - name: trivy
      image: aquasec/trivy:0.65.0
      command:
        - cat
      tty: true
  volumes:
    - name: workspace
      emptyDir: {}
'''
        }
    }
    stages {
        stage('Trivy Image Scan with Kaniko') {
            steps {
                container('kaniko') {
                    sh '/kaniko/executor --dockerfile=Dockerfile --context=/home/jenkins/agent/workspace --no-push --tar-path=/home/jenkins/agent/workspace/image.tar'
                }
                container('trivy') {
                    sh 'trivy image --input /home/jenkins/agent/workspace/image.tar --format sarif'
                }
            }
        }
    }
}