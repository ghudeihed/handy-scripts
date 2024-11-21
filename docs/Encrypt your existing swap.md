# **Managing and Encrypting Swap Space on Ubuntu**

This guide provides a step-by-step approach to view, configure, and encrypt your swap file on Ubuntu, ensuring secure and efficient system operations.

---

## **1. Viewing Current Swap Space**

Use any of the following methods to check your system's current swap configuration:

### **Method 1: Using `swapon` Command**
Displays active swap files and partitions:
```bash
sudo swapon --show
```
- **Output**: Includes details such as location, type, size, and priority.

### **Method 2: Using `free` Command**
Shows memory usage, including swap space:
```bash
free -h
```
- **Look at the "Swap" row** for total, used, and available swap space.

### **Method 3: Using `/proc/swaps` File**
Provides detailed swap information:
```bash
cat /proc/swaps
```
- **Output**: Lists the filename (location), type, size, and usage of the swap space.

---

## **2. Encrypting an Existing Swap File**

Follow these steps to securely encrypt your swap file (`/swap.img`) for enhanced data protection.

### **Step 1: Disable and Remove the Current Swap File**

1. Disable the existing swap:
   ```bash
   sudo swapoff /swap.img
   ```
2. Remove the swap file:
   ```bash
   sudo rm /swap.img
   ```

---

### **Step 2: Create a New Encrypted Swap File**

1. **Generate a New Swap File**:
   - Create an 8GB swap file (adjust size as needed):
     ```bash
     sudo dd if=/dev/zero of=/swap.img bs=1M count=8192
     ```
   - Set appropriate permissions:
     ```bash
     sudo chmod 600 /swap.img
     ```

2. **Encrypt the Swap File**:
   - Initialize encryption using `cryptsetup`:
     ```bash
     sudo cryptsetup --verbose --type luks1 --cipher aes-xts-plain64 --key-size 256 --hash sha256 --iter-time 5000 luksFormat /swap.img
     ```
   - Open and map the encrypted file:
     ```bash
     sudo cryptsetup open --type luks /swap.img cryptswap
     ```

3. **Format and Enable the Encrypted Swap**:
   - Format as swap:
     ```bash
     sudo mkswap /dev/mapper/cryptswap
     ```
   - Enable the swap:
     ```bash
     sudo swapon /dev/mapper/cryptswap
     ```

---

### **Step 3: Configure Persistent Encrypted Swap**

1. **Update `/etc/fstab`**:
   - Edit the file:
     ```bash
     sudo nano /etc/fstab
     ```
   - Add the following entry for the encrypted swap:
     ```fstab
     /dev/mapper/cryptswap none swap sw 0 0
     ```

2. **Update `/etc/crypttab`**:
   - Edit the file:
     ```bash
     sudo nano /etc/crypttab
     ```
   - Add this configuration for auto-mapping:
     ```crypttab
     cryptswap /swap.img /dev/urandom swap,cipher=aes-xts-plain64,size=256
     ```

---

### **Step 4: Verify the Configuration**

1. **Reboot the System**:
   ```bash
   sudo reboot
   ```

2. **Verify Swap Status**:
   - Check the active swap:
     ```bash
     sudo swapon --show
     ```
   - Confirm the encryption status:
     ```bash
     sudo cryptsetup status cryptswap
     ```

---

## **3. Summary**

- **Adjustable Swap Size**: Configure during creation (`count` value in `dd`).
- **Secure Encryption**: Uses AES encryption for secure data handling.
- **Persistent Configuration**: Ensured via `/etc/fstab` and `/etc/crypttab`.