pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="278584405699"
        AWS_DEFAULT_REGION="us-east-1" 
        IMAGE_REPO_NAME="nodeapplication"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
    stages{
        stage("SCM checkout-Git"){
            steps{
                echo " checking out application"
                git credentialsId: 'gitToken', url: 'https://github.com/angelin-mariya/nodeApplication.git'
            }
        }
        stage('Build') {
            steps{
                echo " docker is running"
                sh '''
                docker build . -t ${IMAGE_REPO_NAME}:${IMAGE_TAG} 
                '''
            }
        }
        stage('Pushing to ECR') {
            steps{  
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
				}
            }
        }
        stage("Deploy in app host"){
            steps{
                 sshagent (credentials: ['shhKey']) {
                    withAWS(credentials: 'AWSCredentials', region: 'us-east-1') {
                        sh ' ssh -tt -o StrictHostKeyChecking=no  ubuntu@10.0.3.208  " docker rm -f nodeapp || true && docker pull ${REPOSITORY_URI}:latest && docker run -itd -p 8080:8081 --name nodeapp ${REPOSITORY_URI}:latest"  ' 
                    }
                }   
            }
        }
    }
}