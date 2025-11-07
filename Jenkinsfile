pipeline {
    agent any

    environment {
        NODE_ENV = 'production'
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull your repo from GitHub
                git branch: 'main', url: 'https://github.com/amitsingh17051/nextapp.git', credentialsId: 'your-credentials-id'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install --include=dev'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Start App') {
            steps {
                // Start the app in the background
                sh 'nohup npm start &'
            }
        }
    }

    post {
        success {
            echo 'Build and deployment completed successfully!'
        }
        failure {
            echo 'Something went wrong during the build!'
        }
    }
}

