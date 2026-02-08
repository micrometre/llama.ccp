# llama-cpp Installation Guide for Ubuntu 24.04

## Quick Install

For a quick installation, run:

```bash
sudo bash install.sh
```

The installer will automatically download the latest llama-cpp binary from GitHub or use a local tar.gz file if available.

## Installation Methods

### Method 1: Using the Automatic Installer (Recommended)

The `install.sh` script automates the entire installation process:

```bash
# Make the script executable
chmod +x install.sh

# Run the installer with sudo
sudo ./install.sh
```

**What it does:**
- **Downloads latest binary from GitHub** (or uses local tar.gz as fallback)
- Checks system requirements
- Installs necessary dependencies
- Extracts binary packages
- Sets up symlinks in `/usr/local/bin`
- Creates configuration files
- (Optional) Sets up systemd service
- Creates uninstaller script

### Method 2: Manual Installation

If you prefer to install manually:

1. **Extract the binary package:**
   ```bash
   sudo mkdir -p /opt/llama-cpp
   sudo tar -xzf llama-cpp-b7966-bin-ubuntu-x64.tar.gz -C /opt/llama-cpp --strip-components=1
   ```

2. **Create symlinks:**
   ```bash
   sudo ln -sf /opt/llama-cpp/bin/* /usr/local/bin/
   ```

3. **Update library cache:**
   ```bash
   sudo ldconfig
   ```

## System Requirements

- **OS:** Ubuntu 24.04 LTS
- **Architecture:** x86_64 or aarch64
- **Memory:** Minimum 8GB RAM (16GB+ recommended)
- **Disk Space:** At least 10GB free space

## Optional Dependencies

### GPU Support (NVIDIA CUDA)

For GPU acceleration with NVIDIA cards:

```bash
sudo apt-get install nvidia-cuda-toolkit libcublas-dev
```

### CPU Optimization

For better CPU performance:

```bash
sudo apt-get install libopenblas-dev
```

## Verifying Installation

After installation, verify it worked:

```bash
# Check if binaries are available
which llama-server
which llama-cli

# Check library paths
ldconfig -p | grep llama
```

## Configuration

The installation creates a configuration file at:
```
/usr/local/share/llama-cpp/config.sh
```

Source this file to set up environment variables:
```bash
source /usr/local/share/llama-cpp/config.sh
```

Or add it to your `.bashrc`:
```bash
echo "source /usr/local/share/llama-cpp/config.sh" >> ~/.bashrc
```

## Environment Variables

- `LLAMA_CPP_HOME`: Installation directory (`/opt/llama-cpp`)
- `LLAMA_CPP_THREADS`: Number of threads to use
- `LLAMA_CPP_GPU`: Enable GPU support

Example:
```bash
export LLAMA_CPP_THREADS=8
export LLAMA_CPP_GPU=1
```

## Systemd Service

If you chose to set up the systemd service during installation:

```bash
# Start the service
sudo systemctl start llama-cpp

# Enable on boot
sudo systemctl enable llama-cpp

# Check status
sudo systemctl status llama-cpp

# View logs
sudo journalctl -u llama-cpp -f
```

## Uninstallation

### If you used the automatic installer:
```bash
sudo /opt/llama-cpp/uninstall.sh
```

### If you installed via .deb package:
```bash
sudo apt remove llama-cpp
```

### If you did manual installation:
```bash
# Remove symlinks
sudo rm -f /usr/local/bin/llama-*

# Remove installation directory
sudo rm -rf /opt/llama-cpp

# Update library cache
sudo ldconfig
```

## Troubleshooting

### Command not found errors

If you get "command not found" errors:

```bash
# Check if binary exists
ls -la /opt/llama-cpp/bin/

# Verify symlinks
ls -la /usr/local/bin/llama-*

# Recreate symlinks if needed
sudo ln -sf /opt/llama-cpp/bin/* /usr/local/bin/
```

### Permission denied errors

```bash
# Make binaries executable
sudo chmod +x /opt/llama-cpp/bin/*

# Fix permissions on installation directory
sudo chown -R root:root /opt/llama-cpp
sudo chmod -R 755 /opt/llama-cpp
```

### Library not found errors

```bash
# Update library cache
sudo ldconfig

# Check if libraries are found
ldd /opt/llama-cpp/bin/llama-cpp-server

# Check library path
echo $LD_LIBRARY_PATH
```

### Missing dependencies

```bash
# Install required dependencies
sudo apt-get install build-essential libopenblas-dev pkg-config

# For GPU support:
sudo apt-get install nvidia-cuda-toolkit libcublas-dev
```

## Usage Examples

### Running the server

```bash
llama-server --model model.gguf --port 8000
```

### Using with Python

```python
from llama_cpp import Llama

llm = Llama(model_path="model.gguf")
output = llm("Q: What is AI?\nA: ", max_tokens=512)
print(output)
```

### Command-line inference

```bash
llama-cli -m model.gguf -p "Hello world" -n 256
```

## Getting Help

For more information and support:

- **GitHub:** https://github.com/ggerganov/llama.cpp
- **Documentation:** https://github.com/ggerganov/llama.cpp/blob/master/README.md
- **Issues:** https://github.com/ggerganov/llama.cpp/issues

## Version Information

- **llama-cpp Version:** 1.0.0
- **Ubuntu Version:** 24.04 LTS
- **Built for:** x86_64

---

Last updated: 2024
