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
                            --exclude=node_modules \
                            --exclude=.git \
                            --exclude=.next/cache \
                            .next \
                            app \
                            public \
                            package.json \
                            package-lock.json \
                            next.config.js \
                            postcss.config.mjs \
                            tsconfig.json \
                            next-env.d.ts
                    '''
                    
                    // Transfer files to VM using SSH
                    // Make sure passwordless SSH is set up or use SSH agent
                    sh """
                        echo "Transferring files to Vagrant VM..."
                        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${VM_PORT} ${VM_USER}@${VM_HOST} 'mkdir -p ${VM_DEPLOY_PATH}' || {
                            echo "Error: Cannot connect to VM. Please ensure:"
                            echo "1. VM is running and accessible"
                            echo "2. SSH key is set up for passwordless access"
                            echo "3. VM_HOST, VM_USER, VM_PORT are correct"
                            exit 1
                        }
                        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${VM_PORT} deploy.tar.gz ${VM_USER}@${VM_HOST}:${VM_DEPLOY_PATH}/
                    """
                    
                    // Deploy on VM
                    sh """
                        echo "Deploying application on VM..."
                        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${VM_PORT} ${VM_USER}@${VM_HOST} << 'ENDSSH'
                            set -e
                            cd ${VM_DEPLOY_PATH}
                            
                            # Stop existing application if running
                            echo "Stopping existing application..."
                            pkill -f 'next start' || true
                            sleep 2
                            
                            # Backup current deployment (optional)
                            if [ -d ".next" ]; then
                                echo "Backing up current deployment..."
                                BACKUP_FILE="backup-\$(date +%Y%m%d-%H%M%S).tar.gz"
                                tar -czf "\${BACKUP_FILE}" .next app public package.json 2>/dev/null || true
                                echo "Backup created: \${BACKUP_FILE}"
                            fi
                            
                            # Extract new files
                            echo "Extracting new deployment..."
                            tar -xzf deploy.tar.gz
                            rm -f deploy.tar.gz
                            
                            # Install/update dependencies
                            echo "Installing dependencies..."
                            npm install --production
                            
                            # Start the application
                            echo "Starting application..."
                            nohup npm start > app.log 2>&1 &
                            
                            # Wait and verify
                            sleep 3
                            if pgrep -f 'next start' > /dev/null; then
                                echo "✓ Application started successfully"
                                echo "Application is running on port 3000"
                            else
                                echo "✗ Error: Application failed to start. Check app.log for details"
                                tail -20 app.log || true
                                exit 1
                            fi
ENDSSH
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

