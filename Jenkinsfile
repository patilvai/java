@Library('my-shared-library') _

pipeline {

    agent any

    parameters {
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "Tag of the docker build", defaultValue: 'latest')
        string(name: 'DockerHubUser', description: "Name of the DockerHub user", defaultValue: 'patilvai')
        string(name: 'aws_account_id', description: "Your AWS account ID", defaultValue: '730335534667')
        string(name: 'ECR_REPO_NAME', description: "ECR repository name", defaultValue: 'javasession2')
        string(name: 'Region', description: "AWS region", defaultValue: 'us-east-1')
        string(name: 'cluster', description: "EKS Cluster Name", defaultValue: 'eks_cluster')
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

        stage('Docker Image Build : ECR') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerBuild("${params.aws_account_id}", "${params.Region}", "${params.ECR_REPO_NAME}")
                }
            }
        }

        stage('Docker Image Push: ECR') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: '730335534667',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh """
                        sh """
                aws ecr get-login-password --region ${params.Region} | docker login --username AWS --password-stdin ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com
                docker push ${params.aws_account_id}.dkr.ecr.${params.Region}.amazonaws.com/${params.ECR_REPO_NAME}:${params.ImageTag}
                        """
                    }
                }
            }
        }

        stage('Connect to EKS') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: '730335534667',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh """
                        aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
                        aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
                        aws configure set region "${params.Region}"
                        aws eks --region ${params.Region} update-kubeconfig --name ${params.cluster}
                        """
                    }
                }
            }
        }

        stage('Deployment on EKS Cluster') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    try {
                        sh "kubectl apply -f ."
                    } catch (e) {
                        error "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Clean workspace after the pipeline run
        }
    }
}
