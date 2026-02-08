# llama-cpp Installation Complete ✓

## Installation Status

✅ **llama-cpp has been successfully installed on Ubuntu 24.04**

### Installation Details

- **Installation Path:** `/opt/llama-cpp`
- **Binary Directory:** `/opt/llama-cpp/bin`
- **Library Directory:** `/opt/llama-cpp/lib`
- **Library Configuration:** `/etc/ld.so.conf.d/llama-cpp.conf`
- **Systemd Service:** `/etc/systemd/system/llama-cpp.service`

## Installed Binaries

The following binaries are now available in your PATH:

| Binary | Purpose |
|--------|---------|
| `llama-server` | Main inference server for API requests |
| `llama-cli` | Command-line interface for text generation |
| `llama-completion` | Text completion utility |
| `llama-bench` | Performance benchmarking tool |
| `llama-quantize` | Model quantization utility |
| `llama-imatrix` | Importance matrix calculation |
| `llama-perplexity` | Perplexity calculation tool |
| `llama-gguf-split` | GGUF file splitting utility |
| `llama-tokenize` | Tokenization utility |
| `llama-batched-bench` | Batched performance benchmarking |
| `rpc-server` | RPC server for distributed inference |

## Quick Start

### Test the Installation

```bash
# Check available commands
llama-cli --help
llama-server --help

# Verify libraries are loaded correctly
ldd /opt/llama-cpp/bin/llama-server
```

### Running the Server

The llama-cpp service is already running! Check its status:

```bash
sudo systemctl status llama-cpp
```

The server is listening on **port 8000** by default.

#### Starting/Stopping the Service

```bash
# Start the service
sudo systemctl start llama-cpp

# Stop the service
sudo systemctl stop llama-cpp

# Restart the service
sudo systemctl restart llama-cpp

# View logs
sudo journalctl -u llama-cpp -f

# Enable/disable on boot
sudo systemctl enable llama-cpp
sudo systemctl disable llama-cpp
```

### Using the Command-Line Interface

```bash
# Get version and build info
llama-cli --version

# Generate text (requires a model file)
llama-cli -m model.gguf -p "Hello" -n 100
```

### Using the Server API

Once the server is running, you can make API requests:

```bash
# Check server health
curl http://localhost:8000/health

# Load a model
curl -X POST http://localhost:8000/load \
  -H "Content-Type: application/json" \
  -d '{"model": "/path/to/model.gguf"}'

# Generate completions
curl -X POST http://localhost:8000/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Hello, how are you?",
    "n_predict": 128
  }'
```

## Environment Variables

```bash
# Library path (automatically configured)
export LD_LIBRARY_PATH=/opt/llama-cpp/lib:$LD_LIBRARY_PATH

# Number of threads (optional)
export LLAMA_THREADS=8

# GPU support (if available)
export LLAMA_GPU=1
```

## Directory Structure

```
/opt/llama-cpp/
├── bin/               # Executable binaries
│   ├── llama-server
│   ├── llama-cli
│   ├── llama-quantize
│   └── ... (14+ tools)
├── lib/               # Shared libraries
│   ├── libllama.so
│   ├── libggml.so
│   ├── libmtmd.so
│   └── ... (30+ libraries)
└── uninstall.sh       # Uninstall script (if installed via installer)

/usr/local/bin/
└── llama-*            # Symlinks to executables

/etc/ld.so.conf.d/
└── llama-cpp.conf     # Library path configuration

/etc/systemd/system/
└── llama-cpp.service  # Systemd service
```

## Model Setup

To use llama-cpp effectively, you need a model file in GGUF format:

1. **Download a model** from [Hugging Face](https://huggingface.co/models?library=gguf) or similar sources:
   ```bash
   # Example: Download a small quantized model
   wget https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/Mistral-7B-Instruct-v0.1.Q4_K_M.gguf
   ```

2. **Place the model** in a accessible directory:
   ```bash
   mkdir ~/models
   mv Mistral-7B-Instruct-v0.1.Q4_K_M.gguf ~/models/
   ```

3. **Use the model**:
   ```bash
   # With CLI
   llama-cli -m ~/models/Mistral-7B-Instruct-v0.1.Q4_K_M.gguf -p "Hello" -n 100

   # With server (via API)
   curl -X POST http://localhost:8000/load \
     -H "Content-Type: application/json" \
     -d '{"model": "/home/user/models/Mistral-7B-Instruct-v0.1.Q4_K_M.gguf"}'
   ```

## Troubleshooting

### Service won't start

```bash
# Check service logs
sudo journalctl -u llama-cpp -n 50

# Check if binary exists
ls -la /opt/llama-cpp/bin/llama-server

# Test binary manually
/opt/llama-cpp/bin/llama-server --help
```

### Library errors

```bash
# Update library cache
sudo ldconfig

# Verify library path is configured
cat /etc/ld.so.conf.d/llama-cpp.conf

# Check if libraries are found
ldd /opt/llama-cpp/bin/llama-server
```

### Port already in use

Edit the systemd service to use a different port:

```bash
sudo nano /etc/systemd/system/llama-cpp.service
# Change: ExecStart=/opt/llama-cpp/bin/llama-server --port 8001
sudo systemctl daemon-reload
sudo systemctl restart llama-cpp
```

### Performance optimization

For CPU inference:

```bash
# Use multiple threads
llama-server --port 8000 -t 8
```

For GPU inference (if available):

```bash
# Use GPU acceleration
llama-server --port 8000 -ngl 33  # Use all GPU layers
```

## Uninstallation

### Method 1: Using the uninstaller script (if available)

```bash
sudo /opt/llama-cpp/uninstall.sh
```

### Method 2: Manual removal

```bash
# Stop the service
sudo systemctl stop llama-cpp
sudo systemctl disable llama-cpp

# Remove the service file
sudo rm /etc/systemd/system/llama-cpp.service
sudo systemctl daemon-reload

# Remove library configuration
sudo rm /etc/ld.so.conf.d/llama-cpp.conf
sudo ldconfig

# Remove symlinks
sudo rm -f /usr/local/bin/llama-* /usr/local/bin/rpc-server

# Remove installation directory
sudo rm -rf /opt/llama-cpp
```

## Getting Help

- **GitHub:** https://github.com/ggerganov/llama.cpp
- **Documentation:** https://github.com/ggerganov/llama.cpp/blob/master/README.md
- **Issues:** https://github.com/ggerganov/llama.cpp/issues
- **Discussions:** https://github.com/ggerganov/llama.cpp/discussions

## Version Information

- **Package:** llama-cpp (llama.cpp)
- **Version:** b7966
- **Platform:** Ubuntu 24.04 LTS
- **Architecture:** x86_64 / aarch64
- **Build Date:** 2026-02-07

---

**Installation completed successfully!** You can now start using llama-cpp for inference tasks.
