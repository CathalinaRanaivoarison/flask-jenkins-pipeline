pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages{
        stage('Code quality'){
            steps{
                sh '''
                    docker run --rm -i hadolint/hadolint < Dockerfile
                    docker run --rm --volumes-from jenkins -w "$WORKSPACE" python:3.14-slim sh -c "pip install -q flake8 && flake8 ."

                '''
            }
        }
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