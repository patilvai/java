@Library('my-shared-library') _

pipeline {

    agent any

    parameters {
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "Tag of the docker build", defaultValue: 'javapp')
        string(name: 'DockerHubUser', description: "Name of the DockerHub user", defaultValue: 'patilvai')
        string(name: 'aws_account_id', description: "Your AWS account ID", defaultValue: '730335534667') // New parameter for AWS account
        string(name: 'ECR_REPO_NAME', description: "ECR repository name", defaultValue: 'javasession2') // New parameter for ECR repo
        string(name: 'Region', description: "AWS region", defaultValue: 'us-east-1') // New parameter for AWS region
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

        stage('Docker Image Build : ECR'){
          when { expression {  params.action == 'create' } }
             steps{
                script{
                   
                   dockerBuild("${params.aws_account_id}","${params.Region}","${params.ECR_REPO_NAME}")
                }
             }
         }
        stage('Docker Image Push: DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerImagePush("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                }
            }
        }

        stage('Docker Image Cleanup: DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerImageCleanup("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                }
            }
        }

        stage('Connect to EKS') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: '730335534667', // Ensure this matches your Jenkins credentials ID
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
                        sh """
                        kubectl apply -f .
                        """
                }
            }
        }
    }
}
