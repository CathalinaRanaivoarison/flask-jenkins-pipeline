pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        STAGING_IP = '15.236.90.142'
        PROD_IP    = '15.236.55.57'
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

        stage('Unit tests'){
            steps{
                sh '''
                    docker run --rm --volumes-from jenkins -w "$WORKSPACE" python:3.14-slim \
                      sh -c "pip install -q -r requirements-dev.txt && pytest -v"
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

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                usernameVariable: 'DH_USER',
                                                passwordVariable: 'DH_TOKEN')]) {
                    sh '''
                        echo "$DH_TOKEN" | docker login -u "$DH_USER" --password-stdin
                        docker tag flask-app:v$BUILD_NUMBER cathalina/flask-app:v$BUILD_NUMBER
                        docker push cathalina/flask-app:v$BUILD_NUMBER
                    '''
                }
            }
            post {
                always {
                    sh 'docker logout || true'
                }
            }
        }

        stage('Deploy staging') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'aws-ssh-key',
                                                keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                        ansible-playbook -i ansible/inventory.ini ansible/deploy.yml --limit staging \
                          -e "image_tag=v$BUILD_NUMBER app_env=staging ansible_ssh_private_key_file=$SSH_KEY"
                        curl -f --retry 5 --retry-delay 3 --retry-connrefused --max-time 10 http://$STAGING_IP/health
                    '''
                }
            }
        }

        stage('Deploy production') {
            steps {
                input message: 'Déployer en production ?', ok: 'Déployer'
                withCredentials([sshUserPrivateKey(credentialsId: 'aws-ssh-key',
                                                keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                        ansible-playbook -i ansible/inventory.ini ansible/deploy.yml --limit production \
                          -e "image_tag=v$BUILD_NUMBER app_env=production ansible_ssh_private_key_file=$SSH_KEY"
                        curl -f --retry 5 --retry-delay 3 --retry-connrefused --max-time 10 http://$PROD_IP/health
                    '''
                }
            }
        }

    }
}