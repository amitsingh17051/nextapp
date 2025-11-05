pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/amitsingh17051/nextapp.git', 
                    credentialsId: 'your-credentials-id'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'apt-get update && apt-get install -y nodejs npm && npm install'
            }
        }
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        stage('Start App') {
            steps {
                sh 'nohup npm start &'
            }
        }
    }
}
