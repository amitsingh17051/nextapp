pipeline {
    agent any

    environment {
        NODE_ENV = 'production'
        // Configure these variables in Jenkins or set them here
        VM_HOST = '192.168.56.11'  // Your Vagrant VM IP address
        VM_USER = 'vagrant'         // SSH username (usually 'vagrant')
        VM_DEPLOY_PATH = '/home/vagrant/nextapp'  // Deployment directory on VM
        VM_PORT = '22'              // SSH port (default: 22)
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

        stage('Deploy to Vagrant VM') {
            steps {
                script {
                    // Create deployment archive
                    sh '''
                        echo "Creating deployment package..."
                        tar -czf deploy.tar.gz \
                            .next \
                            app \
                            public \
                            package.json \
                            package-lock.json \
                            next.config.js \
                            postcss.config.mjs \
                            tsconfig.json \
                            next-env.d.ts \
                            --exclude=node_modules
                    '''
                    
                    // Transfer files to VM
                    // Note: You'll need to configure SSH credentials in Jenkins
                    // Option 1: Using SSH key (recommended)
                    // Add your SSH private key as a Jenkins credential with ID 'vagrant-ssh-key'
                    sh """
                        echo "Transferring files to Vagrant VM..."
                        ssh -o StrictHostKeyChecking=no -p ${VM_PORT} ${VM_USER}@${VM_HOST} 'mkdir -p ${VM_DEPLOY_PATH}'
                        scp -o StrictHostKeyChecking=no -P ${VM_PORT} deploy.tar.gz ${VM_USER}@${VM_HOST}:${VM_DEPLOY_PATH}/
                    """
                    
                    // Deploy on VM
                    sh """
                        echo "Deploying application on VM..."
                        ssh -o StrictHostKeyChecking=no -p ${VM_PORT} ${VM_USER}@${VM_HOST} '''
                            cd ${VM_DEPLOY_PATH}
                            
                            # Stop existing application if running
                            pkill -f 'next start' || true
                            
                            # Extract new files
                            tar -xzf deploy.tar.gz
                            
                            # Install/update dependencies
                            npm install --production
                            
                            # Start the application
                            nohup npm start > app.log 2>&1 &
                            
                            # Wait a moment and check if it started
                            sleep 3
                            if pgrep -f 'next start' > /dev/null; then
                                echo "Application started successfully"
                            else
                                echo "Warning: Application may not have started. Check app.log"
                                exit 1
                            fi
                        '''
                    """
                    
                    // Cleanup
                    sh 'rm -f deploy.tar.gz'
                }
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

