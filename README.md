# llama-cpp Installer for Ubuntu 24.04

A complete installation and deployment solution for llama-cpp on Ubuntu 24.04 LTS systems.

## 📦 What's Included

This repository contains everything needed to install and manage llama-cpp on Ubuntu 24.04:

### Installation Scripts
- **`install.sh`** - Interactive installer with dependency management, optional GPU support, and systemd service setup
- **`Makefile`** - Convenient make targets for installation and management

### Documentation
- **`INSTALL.md`** - Comprehensive installation guide with troubleshooting
- **`SETUP_COMPLETE.md`** - Post-installation guide and quick reference

## ✅ Installation Status

The llama-cpp installation on this system is **complete and operational**:

- ✓ 18 binaries installed to `/opt/llama-cpp/bin`
- ✓ 27 libraries installed to `/opt/llama-cpp/lib`
- ✓ Systemd service running on port 8000
- ✓ Library paths configured via ldconfig
- ✓ Symlinks created in `/usr/local/bin`

## 🚀 Quick Start

### View Available Binaries
```bash
ls /opt/llama-cpp/bin/
```

### Check Service Status
```bash
sudo systemctl status llama-cpp
```

### View Service Logs
```bash
sudo journalctl -u llama-cpp -f
```

### Use the CLI
```bash
llama-cli --version
llama-cli --help
```

### Access the Server API
```bash
# Health check
curl http://localhost:8000/health

# Check models
curl http://localhost:8000/models
```

## 📋 Installed Binaries

| Binary | Description |
|--------|-------------|
| `llama-server` | API server for inference |
| `llama-cli` | Command-line interface |
| `llama-quantize` | Model quantization |
| `llama-bench` | Performance benchmarking |
| `llama-perplexity` | Perplexity calculation |
| `llama-completion` | Text completion |
| `llama-imatrix` | Importance matrix |
| `rpc-server` | RPC server for distributed inference |
| And 10+ more tools... | See `/opt/llama-cpp/bin/` |

## 📁 Installation Structure

```
/opt/llama-cpp/
├── bin/          → Executable binaries (18 files)
├── lib/          → Shared libraries (27 files)
└── uninstall.sh  → Removal script

/usr/local/bin/
└── llama-*       → Symlinks to executables

/etc/
├── ld.so.conf.d/
│   └── llama-cpp.conf  → Library path config
└── systemd/system/
    └── llama-cpp.service → Service configuration
```

## 🔧 System Configuration

### Libraries
- Location: `/opt/llama-cpp/lib`
- Configuration: `/etc/ld.so.conf.d/llama-cpp.conf`
- 27 shared libraries including:
  - libllama.so (main library)
  - libggml.so (compute engine)
  - libmtmd.so (multi-threaded support)
  - CPU-optimized variants (SSE4.2, AVX, AVX2, AVX-512, etc.)

### Systemd Service
- Service File: `/etc/systemd/system/llama-cpp.service`
- Status: Enabled and Running
- Port: 8000 (default, configurable)
- Logs: `journalctl -u llama-cpp`

### Environment Variables
```bash
# Automatically set by library configuration
LD_LIBRARY_PATH=/opt/llama-cpp/lib:$LD_LIBRARY_PATH

# Optional runtime configurations
LLAMA_THREADS=8              # Number of CPU threads
LLAMA_GPU=1                  # Enable GPU (if available)
```

## 🎯 Usage Examples

### Server Mode (Already Running)
```bash
# View current service status
systemctl status llama-cpp

# Restart service
sudo systemctl restart llama-cpp

# View logs with tail
sudo journalctl -u llama-cpp -n 100
```

### Command-Line Mode
```bash
# See available options
llama-cli --help

# Generate text with a model
llama-cli -m model.gguf -p "Hello world" -n 256

# Benchmark your system
llama-bench
```

### API Mode (Server Already Listening)
```bash
# Load a model
curl -X POST http://localhost:8000/load \
  -H "Content-Type: application/json" \
  -d '{"model": "/path/to/model.gguf"}'

# Generate completions
curl -X POST http://localhost:8000/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Once upon a time",
    "n_predict": 128
  }'
```

## 📚 Getting Models

Download GGUF format models from:
- [Hugging Face GGUF Models](https://huggingface.co/models?library=gguf)
- [TheBloke's Collections](https://huggingface.co/TheBloke)
- [Ollama Model Library](https://ollama.ai/library)

### Method 1: Using Makefile (Recommended)

```bash
make download-mistral     # Mistral 7B (5GB)
make download-code-llama  # Code Llama 34B (20GB) - for coding
make download-deepseek    # DeepSeek Coder 33B (19GB)
```

### Method 2: Manual Download via URL

```bash
mkdir -p models
cd models

# Download Mistral 7B (generic, recommended)
wget https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/Mistral-7B-Instruct-v0.1.Q4_K_M.gguf -O Mistral-7B.gguf

# Download Code Llama 34B (for coding tasks, 32GB RAM)
wget https://huggingface.co/TheBloke/CodeLlama-34B-Instruct-GGUF/resolve/main/CodeLlama-34B-Instruct.Q4_K_M.gguf -O CodeLlama-34B.gguf

# Download Phi-3 3.8B (lightweight, 6GB)
wget https://huggingface.co/TheBloke/phi-3-medium-4k-instruct-GGUF/resolve/main/phi-3-medium-4k-instruct.Q4_K_M.gguf -O Phi-3.gguf
```

### Method 3: Using curl with authentication

If you have a HuggingFace token, use it for authenticated downloads:

```bash
curl -H "Authorization: Bearer YOUR_HF_TOKEN" \
  -L -o model.gguf \
  https://huggingface.co/TheBloke/model-name-GGUF/resolve/main/model.Q4_K_M.gguf
```

### ⚠️ Important Notes

- **Model sizes:** Q4_K_M models are 4-bit quantized (smaller, faster)
  - Phi-3 3.8B: ~2-3GB
  - Mistral 7B: ~5GB  
  - Code Llama 34B: ~20GB
  - DeepSeek Coder 33B: ~19GB

- **Authentication:** Direct HuggingFace URLs may require authentication
- **Speed:** Downloads are typically 1-10 MB/s depending on your connection
- **Storage:** Ensure sufficient disk space before downloading

## 🛠️ Management

### Service Control
```bash
# Start
sudo systemctl start llama-cpp

# Stop
sudo systemctl stop llama-cpp

# Restart
sudo systemctl restart llama-cpp

# Enable on boot
sudo systemctl enable llama-cpp

# Disable on boot
sudo systemctl disable llama-cpp
```

### Configuration
Edit the service to change settings:
```bash
sudo nano /etc/systemd/system/llama-cpp.service
sudo systemctl daemon-reload
sudo systemctl restart llama-cpp
```

### Uninstallation
```bash
# Method 1: If installer script exists
sudo /opt/llama-cpp/uninstall.sh

# Method 2: Manual removal
sudo systemctl stop llama-cpp
sudo systemctl disable llama-cpp
sudo rm /etc/systemd/system/llama-cpp.service
sudo rm /etc/ld.so.conf.d/llama-cpp.conf
sudo rm -rf /opt/llama-cpp
sudo rm -f /usr/local/bin/llama-* /usr/local/bin/rpc-server
sudo systemctl daemon-reload
sudo ldconfig
```

## 🐛 Troubleshooting

### Service Won't Start
```bash
# Check logs
sudo journalctl -u llama-cpp -n 50 -e

# Test binary directly
/opt/llama-cpp/bin/llama-server --help

# Verify libraries
ldd /opt/llama-cpp/bin/llama-server
```

### Command Not Found
```bash
# Verify binary exists
which llama-cli

# Check PATH
echo $PATH

# Manually run if not in PATH
/opt/llama-cpp/bin/llama-cli --help
```

### Library Errors
```bash
# Update library cache
sudo ldconfig

# Verify configuration
cat /etc/ld.so.conf.d/llama-cpp.conf

# Check library dependencies
ldd /opt/llama-cpp/bin/llama-server
```

### Port Already in Use
```bash
# Find process using port 8000
sudo lsof -i :8000

# Kill process (if needed)
sudo kill -9 <PID>

# Or use different port in service config
```

## 📊 System Requirements

- **OS:** Ubuntu 24.04 LTS
- **Architecture:** x86_64 or aarch64
- **RAM:** 8GB minimum, 16GB+ recommended
- **Storage:** 10GB minimum free space
- **Dependencies:** Installed automatically via installer

## 🔗 Resources

- **GitHub:** https://github.com/ggerganov/llama.cpp
- **Documentation:** https://github.com/ggerganov/llama.cpp/blob/master/README.md
- **Issues:** https://github.com/ggerganov/llama.cpp/issues
- **Discussions:** https://github.com/ggerganov/llama.cpp/discussions

## 📝 Version Information

- **llama-cpp Build:** b7966
- **Installation Date:** 2026-02-07
- **Platform:** Ubuntu 24.04.3 LTS
- **Kernel:** 6.17.0+
- **Architecture:** x86_64

## 📄 License

llama-cpp is licensed under the MIT License. See the official repository for details.

---

**Status:** ✅ Installation Complete and Operational

For detailed documentation, see [INSTALL.md](INSTALL.md) and [SETUP_COMPLETE.md](SETUP_COMPLETE.md).
