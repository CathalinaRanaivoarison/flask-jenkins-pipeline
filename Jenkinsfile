pipeline {
    agent any

    stages{
        stage('Build'){
            steps{
                sh 'docker build -t flask-app:$BUILD_NUMBER .'
            }
        }

    }
}