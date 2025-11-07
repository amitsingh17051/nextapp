# Deployment Guide for Vagrant VM

This guide explains how to deploy your Next.js application to a Vagrant VM using Jenkins.

## Prerequisites

1. **Vagrant VM is running and accessible**
2. **SSH access configured** - Passwordless SSH should be set up between Jenkins and the VM
3. **Node.js installed on VM** - The VM should have Node.js installed (version 18+ recommended)

## Configuration

### 1. Update Jenkinsfile Environment Variables

Edit the `Jenkinsfile` and update these environment variables:

```groovy
VM_HOST = '192.168.33.10'  // Your Vagrant VM IP address
VM_USER = 'vagrant'         // SSH username (usually 'vagrant')
VM_DEPLOY_PATH = '/home/vagrant/nextapp'  // Deployment directory on VM
VM_PORT = '22'              // SSH port (default: 22)
```

### 2. Set Up Passwordless SSH

On your Jenkins server, generate an SSH key pair (if you don't have one):

```bash
ssh-keygen -t rsa -b 4096 -C "jenkins@your-server"
```

Copy the public key to your Vagrant VM:

```bash
ssh-copy-id vagrant@192.168.33.10
```

Or manually:

```bash
cat ~/.ssh/id_rsa.pub | ssh vagrant@192.168.33.10 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Test the connection:

```bash
ssh vagrant@192.168.33.10
```

### 3. Prepare the Vagrant VM

On your Vagrant VM, ensure Node.js is installed:

```bash
# Check Node.js version
node --version

# If not installed, install Node.js (example for Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Create the deployment directory:

```bash
mkdir -p /home/vagrant/nextapp
```

## Deployment Process

The Jenkins pipeline will:

1. **Build** the Next.js application
2. **Create** a deployment archive with necessary files
3. **Transfer** files to the VM via SCP
4. **Deploy** on the VM by:
   - Stopping the existing application
   - Extracting new files
   - Installing dependencies
   - Starting the application

## Manual Deployment

You can also deploy manually using the provided script:

```bash
# Set environment variables
export VM_HOST=192.168.33.10
export VM_USER=vagrant
export VM_DEPLOY_PATH=/home/vagrant/nextapp

# Run deployment script
./deploy.sh
```

## Accessing the Application

After deployment, your application will be available at:

```
http://<VM_IP>:3000
```

## Troubleshooting

### SSH Connection Issues

- Verify VM is running: `vagrant status`
- Check VM IP: `vagrant ssh-config`
- Test SSH connection: `ssh vagrant@<VM_IP>`
- Verify SSH key is in `~/.ssh/authorized_keys` on VM

### Application Not Starting

- Check logs on VM: `tail -f /home/vagrant/nextapp/app.log`
- Verify Node.js is installed: `node --version`
- Check if port 3000 is available: `netstat -tulpn | grep 3000`
- Verify dependencies: `cd /home/vagrant/nextapp && npm list`

### Build Failures

- Check Jenkins build logs
- Verify all dependencies are in `package.json`
- Ensure build completes successfully before deployment stage

## Advanced Configuration

### Using PM2 for Process Management

For better process management, you can use PM2:

1. Install PM2 on VM: `npm install -g pm2`
2. Update deployment script to use PM2:
   ```bash
   pm2 stop nextapp || true
   pm2 start npm --name "nextapp" -- start
   pm2 save
   ```

### Using Systemd Service

Create a systemd service for automatic startup:

```bash
# Create service file
sudo nano /etc/systemd/system/nextapp.service
```

Add:
```ini
[Unit]
Description=Next.js App
After=network.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=/home/vagrant/nextapp
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable nextapp
sudo systemctl start nextapp
```

