#!/bin/bash

# Deployment script for Vagrant VM
# This script can be used standalone or called from Jenkins

set -e

# Configuration - override these with environment variables
VM_HOST="${VM_HOST:-192.168.33.10}"
VM_USER="${VM_USER:-vagrant}"
VM_DEPLOY_PATH="${VM_DEPLOY_PATH:-/home/vagrant/nextapp}"
VM_PORT="${VM_PORT:-22}"
SSH_KEY="${SSH_KEY:-}"

echo "=== Starting deployment to Vagrant VM ==="
echo "VM: ${VM_USER}@${VM_HOST}:${VM_PORT}"
echo "Deploy Path: ${VM_DEPLOY_PATH}"

# Build the application
echo "Building application..."
npm run build

# Create deployment archive
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

# Prepare SSH command
SSH_CMD="ssh -o StrictHostKeyChecking=no -p ${VM_PORT}"
SCP_CMD="scp -o StrictHostKeyChecking=no -P ${VM_PORT}"

if [ -n "$SSH_KEY" ]; then
    SSH_CMD="${SSH_CMD} -i ${SSH_KEY}"
    SCP_CMD="${SCP_CMD} -i ${SSH_KEY}"
fi

# Transfer files to VM
echo "Transferring files to VM..."
${SSH_CMD} ${VM_USER}@${VM_HOST} "mkdir -p ${VM_DEPLOY_PATH}"
${SCP_CMD} deploy.tar.gz ${VM_USER}@${VM_HOST}:${VM_DEPLOY_PATH}/

# Deploy on VM
echo "Deploying application on VM..."
${SSH_CMD} ${VM_USER}@${VM_HOST} << EOF
    set -e
    cd ${VM_DEPLOY_PATH}
    
    # Stop existing application if running
    echo "Stopping existing application..."
    pkill -f 'next start' || true
    sleep 2
    
    # Backup current deployment (optional)
    if [ -d ".next" ]; then
        echo "Backing up current deployment..."
        tar -czf backup-\$(date +%Y%m%d-%H%M%S).tar.gz .next app public package.json 2>/dev/null || true
    fi
    
    # Extract new files
    echo "Extracting new deployment..."
    tar -xzf deploy.tar.gz
    
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
EOF

# Cleanup
echo "Cleaning up..."
rm -f deploy.tar.gz

echo "=== Deployment completed successfully ==="

