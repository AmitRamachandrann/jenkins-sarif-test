pipeline {
    agent any

    stages {
        stage('Build and Test') {
            parallel {
                stage('Build') {
                    stages {
                        stage('Compile') {
                            steps {
                                echo 'Compiling...'
                                sleep 5
                            }
                        }
                        stage('Package') {
                            steps {
                                echo 'Packaging...'
                                sleep 5
                            }
                        }
                    }
                }
                stage('Test') {
                    stages {
                        stage('Unit Tests') {
                            steps {
                                echo 'Running Unit Tests...'
                                sleep 5
                            }
                        }
                        stage('Integration Tests') {
                            steps {
                                echo 'Running Integration Tests...'
                                sleep 5
                            }
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sleep 5
            }
        }
    }
} 