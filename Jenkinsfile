@Library('my-shared-library') _

pipeline {

    agent any

    parameters {
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "Tag of the docker build", defaultValue: 'latest')
        string(name: 'aws_account_id', description: "Your AWS account ID", defaultValue: '730335534667') // AWS account ID
        string(name: 'ECR_REPO_NAME', description: "ECR repository name", defaultValue: 'javasession2') // ECR repo name
        string(name: 'Region', description: "AWS region", defaultValue: 'us-east-1') // AWS region
    }

    environment {
        ACCESS_KEY = credentials('AWS_ACCESS_KEY_ID')
        SECRET_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION = "${params.Region}"
        ECR_REPO_URL = "${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com/${params.ECR_REPO_NAME}"
    }

    stages {

        stage('Git Checkout') {
            when { expression { params.action == 'create' } }
            steps {
                gitCheckout(
                    branch: "main",
                    url: "https://github.com/praveen1994dec/Java_app_3.0.git"
                )
            }
        }

        stage('Maven Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnBuild()
                }
            }
        }

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerBuild("${params.ImageName}", "${params.ImageTag}")
                    sh 'docker images'
                }
            }
        }

        stage('Authenticate Docker to ECR') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    sh """
                    aws configure set aws_access_key_id "$ACCESS_KEY"
                    aws configure set aws_secret_access_key "$SECRET_KEY"
                    aws configure set region "${params.Region}"
                    aws ecr get-login-password --region ${params.Region} | docker login --username AWS --password-stdin ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com
                    """
                }
            }
        }

        stage('Tag Docker Image for ECR') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    sh """
                    docker tag ${params.ImageName}:${params.ImageTag} ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com/${params.ECR_REPO_NAME}:${params.ImageTag}
                    """
                }
            }
        }

        stage('Push Docker Image to ECR') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    sh """
                    docker push ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com/${params.ECR_REPO_NAME}:${params.ImageTag}
                    """
                }
            }
        }
    }
}
