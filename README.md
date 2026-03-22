# llama-cpp - Build, Install & Run

A complete installation and deployment solution for llama-cpp on Ubuntu 24.04 LTS systems with cache-based model management.

## 📦 What's Included

This repository contains everything needed to install and manage llama-cpp on Ubuntu 24.04:

### Installation Scripts
- **`install.sh`** - Interactive installer with dependency management, optional GPU support, and systemd service setup
- **`Makefile`** - Convenient make targets for model management and server operations

### Documentation
- **`INSTALL.md`** - Comprehensive installation guide with troubleshooting
- **`SETUP_COMPLETE.md`** - Post-installation guide and quick reference

## 🚀 Quick Start

### Installation
```bash
# Interactive installation (recommended)
make install

# Manual setup (if needed)
make setup_bashrc
source ~/.bashrc
```

### Model Management
```bash
# Download and run popular models
make run-hf-gemma      # Gemma 3 1B (lightweight, ~800MB)
make run-qwen-coder    # Qwen2.5 Coder 7B (coding focused, ~5GB)
make run-phi-4         # Phi-4 Mini (latest, ~2.3GB)

# View cached models
ls -lh ~/.cache/llama.cpp/*.gguf

# Clean cache
make clean
```

### Server Operations
```bash
# Start server with default model (Qwen2.5-Coder-7B)
make server

# Start server with UI support (shows all cached models)
make server-ui

# Custom port and threads
make server PORT=9000 THREADS=8

# Check service status
sudo systemctl status llama-cpp

# View service logs
sudo journalctl -u llama-cpp -f
```

## 📋 Available Binaries

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
├── bin/          → Executable binaries (18+ files)
├── lib/          → Shared libraries (27+ files)
└── uninstall.sh  → Removal script

/usr/local/bin/
└── llama-*       → Symlinks to executables

/etc/
├── ld.so.conf.d/
│   └── llama-cpp.conf  → Library path config
└── systemd/system/
    └── llama-cpp.service → Service configuration

~/.cache/llama.cpp/
└── *.gguf → Downloaded models (managed automatically)
```

## 🔧 System Configuration

### Libraries
- **Location:** `/opt/llama-cpp/lib`
- **Configuration:** `/etc/ld.so.conf.d/llama-cpp.conf`
- **27+ shared libraries** including:
  - `libllama.so` (main library)
  - `libggml.so` (compute engine)
  - `libmtmd.so` (multi-threaded support)
  - CPU-optimized variants (SSE4.2, AVX, AVX2, AVX-512, etc.)

### Systemd Service
- **Service File:** `/etc/systemd/system/llama-cpp.service`
- **Status:** Enabled and Running
- **Default Model:** Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf
- **Port:** 8080 (default, configurable)
- **Logs:** `journalctl -u llama-cpp`
- **User:** ubuntu (proper permissions)

### Environment Variables
```bash
# Automatically set by library configuration
LD_LIBRARY_PATH=/opt/llama-cpp/lib:$LD_LIBRARY_PATH

# Optional runtime configurations
LLAMA_THREADS=8              # Number of CPU threads
LLAMA_GPU=1                  # Enable GPU (if available)
```

## 🎯 Usage Examples

### Server Mode (Systemd Service)
```bash
# View current service status
sudo systemctl status llama-cpp

# Restart service with new model
sudo systemctl restart llama-cpp

# View real-time logs
sudo journalctl -u llama-cpp -f

# Service management
sudo systemctl start llama-cpp      # Start service
sudo systemctl stop llama-cpp       # Stop service
sudo systemctl enable llama-cpp     # Enable on boot
sudo systemctl disable llama-cpp    # Disable on boot
```

### Command-Line Mode
```bash
# Interactive chat with cached model
make run-hf-gemma

# Generate text with specific model
llama-cli -m ~/.cache/llama.cpp/model.gguf -p "Hello world" -n 256

# Benchmark performance
llama-bench -m ~/.cache/llama.cpp/model.gguf

# Download new model from Hugging Face
llama-cli -hf org/model-name-GGUF
```

### API Mode (Server Running)
```bash
# Health check
curl http://localhost:8080/

# Chat completion (OpenAI-compatible)
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Hello"}], "max_tokens": 100}'

# Load specific model
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "model-name.gguf", "messages": [{"role": "user", "content": "Hello"}]}'
```

## 📚 Model Management

### Popular Models (via Makefile)
| Model | Size | Use Case | Download Command |
|-------|------|----------|-----------------|
| Gemma 3 1B | ~800MB | General chat | `make run-hf-gemma` |
| Qwen2.5 Coder 7B | ~5GB | Coding tasks | `make run-qwen-coder` |
| Phi-4 Mini | ~2.3GB | Latest model | `make run-phi-4` |

### Manual Model Downloads
```bash
# From Hugging Face (requires SSL support)
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF
llama-cli -hf bartowski/Qwen2.5-Coder-7B-Instruct-GGUF
llama-cli -hf unsloth/Phi-4-mini-instruct-GGUF

# Direct download URLs
wget https://huggingface.co/TheBloke/model-name-GGUF/resolve/main/model.Q4_K_M.gguf
```

### Cache Management
```bash
# Models are stored in ~/.cache/llama.cpp/
# Automatic cleanup
make clean

# Manual cleanup
rm ~/.cache/llama.cpp/*.gguf
```

## 🛠️ Management

### Service Control
```bash
# Start/Stop/Restart service
sudo systemctl start llama-cpp
sudo systemctl stop llama-cpp
sudo systemctl restart llama-cpp

# Enable/Disable on boot
sudo systemctl enable llama-cpp
sudo systemctl disable llama-cpp

# Configuration
sudo nano /etc/systemd/system/llama-cpp.service
sudo systemctl daemon-reload
sudo systemctl restart llama-cpp
```

### Configuration
```bash
# Change default model (edit service file)
MODEL_PATH="$HOME/.cache/llama.cpp/your-model.gguf"
sudo nano /etc/systemd/system/llama-cpp.service

# Update service configuration
sudo systemctl daemon-reload
sudo systemctl restart llama-cpp
```

## 🐛 Troubleshooting

### When to Use Systemd Service vs Direct Commands

**Use Systemd Service for:**
- Production/24-7 operation
- Background server on boot
- Remote management via `systemctl` commands
- No terminal required for operation

**Use Direct Commands for:**
- Development and testing
- Real-time interaction and debugging
- Easy start/stop control
- Better resource management

### Service Issues (Systemd Users)
```bash
# Check service status
sudo systemctl status llama-cpp

# View recent logs
sudo journalctl -u llama-cpp -n 50

# Test binary directly
/opt/llama-cpp/bin/llama-server --help

# Verify libraries
ldd /opt/llama-cpp/bin/llama-server
```

### Common Problems
- **Service won't start:** Check model exists in `~/.cache/llama.cpp/`
- **Command not found:** Run `make setup_bashrc` and `source ~/.bashrc`
- **Permission denied:** Ensure service runs as `ubuntu` user
- **Port already in use:** Change port in service config or use `make server PORT=9000`
- **SSL errors:** Install `libssl-dev` and reinstall with `make install`

### Performance Issues
- **Slow inference:** Ensure GPU drivers are installed and working
- **High memory usage:** Reduce context size or threads
- **Model loading errors:** Verify model integrity with `file model.gguf`

## 📊 System Requirements

### Minimum Requirements
- **OS:** Ubuntu 24.04 LTS
- **Architecture:** x86_64 or aarch64
- **RAM:** 8GB minimum, 16GB+ recommended
- **Storage:** 10GB minimum free space
- **Dependencies:** Installed automatically via installer

### Recommended Requirements
- **RAM:** 16GB+ for large models (7B+ parameters)
- **GPU:** NVIDIA GPU with CUDA support (optional)
- **Storage:** 50GB+ for multiple models

## 🔗 Resources

- **GitHub:** https://github.com/ggerganov/llama.cpp
- **Documentation:** https://github.com/ggerganov/llama.cpp/blob/master/README.md
- **Issues:** https://github.com/ggerganov/llama.cpp/issues
- **Discussions:** https://github.com/ggerganov/llama.cpp/discussions
- **Hugging Face Models:** https://huggingface.co/models?library=gguf

## � Version Information

- **llama-cpp Build:** b8464
- **Installation Date:** 2026-03-22
- **Platform:** Ubuntu 24.04.3 LTS
- **Kernel:** 6.17.0+
- **Architecture:** x86_64

---

**Status:** ✅ Installation Complete and Operational

For detailed installation steps, see [INSTALL.md](INSTALL.md) and [SETUP_COMPLETE.md](SETUP_COMPLETE.md).
