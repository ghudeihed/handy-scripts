# **Setting Up NVIDIA Drivers, CUDA Toolkit, and Swap Space on Ubuntu**

This guide provides a structured approach to install and configure Java 8, NVIDIA drivers, CUDA Toolkit 12.6, and encrypted swap space while addressing potential conflicts and troubleshooting issues.

---

## **1. Install and Configure Java 8**

### Install OpenJDK 8:
```bash
sudo apt install openjdk-8-jdk
```

### Set `JAVA_HOME` to Java 8:
1. Open `.bashrc`:
   ```bash
   nano ~/.bashrc
   ```
2. Add the following lines:
   ```bash
   export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
   export PATH=$JAVA_HOME/bin:$PATH
   ```
3. Reload `.bashrc`:
   ```bash
   source ~/.bashrc
   ```

---

## **2. Remove Old NVIDIA Drivers and CUDA Versions**

### Uninstall Existing Drivers:
```bash
sudo apt purge '^nvidia.*'
sudo apt autoremove
sudo apt autoclean
```

### Remove Old CUDA Versions:
```bash
sudo apt remove --purge cuda-12-0
sudo apt remove --purge cuda
```

---

## **3. Install Latest NVIDIA Drivers**

### Add the NVIDIA PPA:
```bash
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
```

### Install Recommended Driver:
1. Check available drivers:
   ```bash
   ubuntu-drivers devices
   ```
2. Install the recommended driver:
   ```bash
   sudo apt install nvidia-driver-535  # Replace with your recommended version
   ```

### Reboot and Verify:
1. Reboot:
   ```bash
   sudo reboot
   ```
2. Verify the installation:
   ```bash
   nvidia-smi
   ```

---

## **4. Install and Configure CUDA Toolkit 12.6**

### Add the CUDA Repository:
1. Add the GPG key:
   ```bash
   sudo curl https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/nvidia-cuda-keyring.gpg
   ```
2. Add the repository:
   ```bash
   sudo bash -c 'echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" > /etc/apt/sources.list.d/cuda.list'
   ```

### Install CUDA Toolkit and Drivers:
```bash
sudo apt update
sudo apt install cuda-12-6 nvidia-driver-535
```

### Configure Environment Variables:
1. Open `.bashrc`:
   ```bash
   nano ~/.bashrc
   ```
2. Add the following lines:
   ```bash
   export PATH=/usr/local/cuda-12.6/bin:$PATH
   export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH
   ```
3. Reload `.bashrc`:
   ```bash
   source ~/.bashrc
   ```

### Verify CUDA Installation:
1. Check `nvcc` version:
   ```bash
   nvcc --version
   ```
2. Test drivers:
   ```bash
   nvidia-smi
   ```

### Test CUDA Functionality:
1. Install CUDA samples:
   ```bash
   cuda-install-samples-12.6.sh ~/
   ```
2. Compile and run a sample:
   ```bash
   cd ~/NVIDIA_CUDA-12.6_Samples/0_Simple/matrixMul
   make
   ./matrixMul
   ```

---

## **5. Configure and Verify Swap Space**

### View Current Swap Configuration:
1. **Using `swapon`**:
   ```bash
   sudo swapon --show
   ```
2. **Using `free`**:
   ```bash
   free -h
   ```
3. **Using `/proc/swaps`**:
   ```bash
   cat /proc/swaps
   ```

### Set Up Encrypted Swap:
1. Disable and remove the old swap:
   ```bash
   sudo swapoff /swap.img
   sudo rm /swap.img
   ```
2. Create and encrypt a new swap file:
   ```bash
   sudo dd if=/dev/zero of=/swap.img bs=1M count=8192
   sudo chmod 600 /swap.img
   sudo cryptsetup luksFormat /swap.img
   sudo cryptsetup open /swap.img cryptswap
   sudo mkswap /dev/mapper/cryptswap
   sudo swapon /dev/mapper/cryptswap
   ```
3. Persist configuration in `/etc/fstab` and `/etc/crypttab`:
   ```fstab
   /dev/mapper/cryptswap none swap sw 0 0
   ```
   ```crypttab
   cryptswap /swap.img /dev/urandom swap,cipher=aes-xts-plain64,size=256
   ```

---

## **6. Troubleshoot NVIDIA Drivers**

### Driver Not Detected:
1. Reinstall the driver:
   ```bash
   sudo ubuntu-drivers autoinstall
   ```
2. Load the NVIDIA module:
   ```bash
   sudo modprobe nvidia
   ```

### Regenerate Initramfs:
```bash
sudo update-initramfs -u
sudo reboot
```

### Fix Resolution Issues:
1. Delete `xorg.conf`:
   ```bash
   sudo rm /etc/X11/xorg.conf
   sudo reboot
   ```
2. Use `xrandr` to set resolution:
   ```bash
   xrandr --output <display_name> --mode <resolution>
   ```

### Use NVIDIA Settings:
```bash
sudo apt install nvidia-settings
nvidia-settings
```

---

## **7. Verify and Maintain System Configuration**

1. **Check Logs**:
   ```bash
   journalctl -u nvidia
   ```
2. **Update System**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
3. **Verify Drivers and CUDA**:
   ```bash
   nvidia-smi
   nvcc --version
   ```

---

## **Summary**

1. Installed and configured Java 8 for compatibility.
2. Removed outdated NVIDIA drivers and installed the latest versions.
3. Installed and configured CUDA Toolkit 12.6.
4. Set up encrypted swap for secure operations.
5. Troubleshot common issues with NVIDIA drivers and display resolution.