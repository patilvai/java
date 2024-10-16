@Library('my-shared-library') _

pipeline {

    agent any

    parameters {
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "Tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "Name of the DockerHub user", defaultValue: 'patilvai')
        string(name: 'aws_account_id', description: "Your AWS account ID", defaultValue: '730335534667') // New parameter for AWS account
        string(name: 'ECR_REPO_NAME', description: "ECR repository name", defaultValue: 'javasession2') // New parameter for ECR repo
        string(name: 'Region', description: "AWS region", defaultValue: 'us-east-1') // New parameter for AWS region
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

        stage('Unit Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnTest()
                }
            }
        }

        stage('Integration Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnIntegrationTest()
                }
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
                    dockerBuild("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                    sh 'docker images'
                }
            }
        }

        stage('Docker Image Scan: trivy') {
            when { expression { params.action == 'create' } }
            steps {
                retry(3) {
                    script {
                        dockerImageScan("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                    }
                }
            }
        }

        stage('Docker Image Push: DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    withAWS(credentials: "${params.aws_account_id}", region: "${params.Region}") {
                        // Use double quotes to allow variable substitution
                        sh "aws ecr get-login-password --region ${params.Region} | docker login --username AWS --password-stdin ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com"
                        // Tag the image properly
                        sh "docker tag ${params.ImageName}:${params.ImageTag} ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com/${params.ECR_REPO_NAME}:${params.ImageTag}"
                        // Push the image
                        sh "docker push ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com/${params.ECR_REPO_NAME}:${params.ImageTag}"
                    }
                }
            }
        }
    }
}
