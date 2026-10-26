pipeline {
    agent any

    stages{
        stage('Build'){
            steps{
                sh 'docker build -t flask-app:v$BUILD_NUMBER .'
            }
        }
        stage('Test'){
            steps{
                 sh '''
                    docker run -d --name flask -p 8083:8080 flask-app:v$BUILD_NUMBER 
                    sleep 3
                    curl -f http://host.docker.internal:8083/health 
                    curl -f http://host.docker.internal:8083
            '''
            }
            post{
                always {
                    sh 'docker rm -f flask || true' 
                }
            }
        }

    }
}