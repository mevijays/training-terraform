pipeline {
    agent any
    
    environment {
        TF_TOKEN_app_terraform_io = credentials('terraform-cloud-token')
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/mevijays/tf-action-workflow.git'
            }
        }
        
        stage('Terraform Init') {
            steps {
                // Install Terraform
                sh 'curl -LO https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip'
                sh 'unzip terraform_1.6.5_linux_amd64.zip'
            // Initialize Terraform
                sh './terraform init'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                // Run Terraform plan
                sh './terraform plan'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                // Run Terraform apply
                sh './terraform apply -auto-approve'
            }
        }
    }
}
