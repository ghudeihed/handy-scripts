# **Initial Ubuntu Setup Guide**

This guide provides the essential steps to set up a new Ubuntu system, including verifying system details, installing applications, setting up CUDA, and configuring Docker.

---

## **1. Verify System Information**

### Check Ubuntu Version:
```bash
lsb_release -a
```

### Check System Architecture:
```bash
uname -m
```
- Output Example: `x86_64` (indicates 64-bit architecture)

---

## **2. Install Timeshift (Backup Tool)**

Timeshift is a system restore tool that allows you to take snapshots of your system for backup purposes.

```bash
sudo apt install timeshift
```

---

## **3. Install Essential Applications**

### Applications to Install:
1. **Visual Studio Code**: IDE for development.
2. **Postman**: API testing tool.
3. **1Password**: Password manager.
4. **Slack**: Team communication.
5. **Discord**: Chat and community platform.

#### Install Applications:
Visit their official websites or use the Snap Store:
```bash
sudo snap install code --classic     # Visual Studio Code
sudo snap install postman           # Postman
sudo snap install 1password         # 1Password
sudo snap install slack             # Slack
sudo snap install discord           # Discord
```

---

## **4. Install CUDA Toolkit 12.6 and NVIDIA Drivers**

### CUDA Toolkit:
Download and install the CUDA Toolkit to enable GPU-accelerated applications.

#### Steps:
1. Download and add the keyring:
   ```bash
   wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
   sudo dpkg -i cuda-keyring_1.1-1_all.deb
   sudo apt-get update
   ```

2. Install the CUDA Toolkit:
   ```bash
   sudo apt-get -y install cuda-toolkit-12-6
   ```

### NVIDIA Drivers:
Install the latest NVIDIA drivers for optimal GPU performance.

#### Steps:
```bash
sudo apt-get install -y nvidia-open
```

### Verify Installation:
After installation, reboot the system and verify:
```bash
nvidia-smi
```

---

## **5. Install Docker Desktop on Ubuntu**

Docker Desktop simplifies container management. Follow these steps to install Docker.

### Steps:
1. **Update System**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y ca-certificates curl
   ```

2. **Add Docker GPG Key**:
   ```bash
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   ```

3. **Add Docker Repository**:
   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update
   ```

4. **Install Docker**:
   ```bash
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

5. **Verify Docker Installation**:
   ```bash
   sudo docker run hello-world
   ```

---

### **Notes:**
- **Backups**: Regularly back up your system using Timeshift or another backup tool.
- **System Updates**: Ensure your system is up-to-date by running:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
