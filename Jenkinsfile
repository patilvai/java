@Library('my-shared-library') _

pipeline {

    agent any

    parameters {
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "Tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "Name of the DockerHub user", defaultValue: 'patilvai')
        string(name: 'aws_account_id', description: "AWS Account ID", defaultValue: '730335534667')
        string(name: 'Region', description: "Region of ECR", defaultValue: 'us-east-1')
        string(name: 'ECR_REPO_NAME', description: "Name of the ECR repository", defaultValue: 'javasession2')
        string(name: 'cluster', description: "Name of the EKS Cluster", defaultValue: 'eks_cluster')
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
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_account']]) {
                    script {
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
                    def apply = false

                    try {
                        input message: 'Please confirm to deploy on EKS', ok: 'Ready to apply the config?'
                        apply = true
                    } catch (err) {
                        apply = false
                        currentBuild.result = 'UNSTABLE'
                    }

                    if (apply) {
                        sh """
                        kubectl apply -f .
                        """
                    }
                }
            }
        }
    }
}
