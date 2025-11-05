pipeline {
    agent {
        docker { image 'node:20' }
    }

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
                sh 'npm install'
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

    post {
        success {
            echo 'Build and start completed successfully!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}
