.PHONY: help install uninstall server server-ui run-hf-gemma run-qwen-coder run-phi-4 clean setup_bashrc

# Installation prefix
PREFIX = /opt/llama-cpp
PORT = 8080
THREADS = 4
HF_CLI = huggingface-cli

help:
	@echo "llama-cpp - Build, Install & Run"
	@echo "=================================="
	@echo ""
	@echo "Installation:"
	@echo "  make install          - Run the interactive installer"
	@echo "  make uninstall        - Remove llama-cpp installation"
	@echo "  make setup_bashrc     - Add llama-cpp to PATH in ~/.bashrc"
	@echo ""
	@echo "Models (downloaded to ~/.cache/llama.cpp/):"
	@echo "  CODING MODELS:"
	@echo "  make run-hf-gemma     - Run Gemma 3 1B from Hugging Face"
	@echo "  make run-qwen-coder   - Run Qwen2.5 Coder 7B from Hugging Face"
	@echo "  make run-phi-4        - Run Phi-4 Mini from Hugging Face"
	@echo ""
	@echo "Running:"
	@echo "  make server           - Start llama-server (PORT=$(PORT) THREADS=$(THREADS))"
	@echo "  make server-ui        - Start llama-server with web UI support"
	@echo "  make server PORT=9000 THREADS=4  - Custom port and threads"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean            - Remove downloaded models"
	@echo ""
	@echo "For more information, see INSTALL.md"

install:
	@chmod +x install.sh
	@sudo bash install.sh

uninstall:
	@if [ -f $(PREFIX)/uninstall.sh ]; then \
		sudo bash $(PREFIX)/uninstall.sh; \
	else \
		echo "llama-cpp does not appear to be installed"; \
	fi

run-hf-gemma:
	llama-cli -hf ggml-org/gemma-3-1b-it-GGUF
run-qwen-coder:
	llama-cli -hf bartowski/Qwen2.5-Coder-7B-Instruct-GGUF

run-phi-4:
	llama-cli -hf unsloth/Phi-4-mini-instruct-GGUF


server:
	@if [ ! -f $(PREFIX)/llama-server ]; then \
		echo "Error: llama-cpp not installed. Run 'make install' first."; \
		exit 1; \
	fi
	@if [ -z "$$(find ~/.cache/llama.cpp/ -name "*.gguf" 2>/dev/null)" ]; then \
		echo "Error: No models found in ~/.cache/llama.cpp/"; \
		echo "Download a model first: make run-hf-gemma"; \
		exit 1; \
	fi
	@MODEL=$$(find ~/.cache/llama.cpp/ -name "*.gguf" | head -1); \
	echo "Starting llama-server..."; \
	echo "  Model: $$MODEL"; \
	echo "  Port: $(PORT)"; \
	echo "  Threads: $(THREADS)"; \
	echo ""; \
	echo "API will be available at: http://localhost:$(PORT)"; \
	echo ""; \
	export LD_LIBRARY_PATH=$(PREFIX):$$LD_LIBRARY_PATH; \
	llama-server -m "$$MODEL" --port $(PORT) -t $(THREADS) --host 0.0.0.0

server-ui:
	@if [ ! -f $(PREFIX)/llama-server ]; then \
		echo "Error: llama-cpp not installed. Run 'make install' first."; \
		exit 1; \
	fi
	@if [ -z "$$(find ~/.cache/llama.cpp/ -name "*.gguf" 2>/dev/null)" ]; then \
		echo "Error: No models found in ~/.cache/llama.cpp/"; \
		echo "Download a model first: make run-hf-gemma"; \
		exit 1; \
	fi
	@echo "Available models:"; \
	find ~/.cache/llama.cpp/ -name "*.gguf" -exec ls -lh {} \;; \
	echo ""; \
	@MODEL=$$(find ~/.cache/llama.cpp/ -name "*.gguf" | head -1); \
	echo "Starting llama-server with UI support..."; \
	echo "  Model: $$MODEL"; \
	echo "  Port: $(PORT)"; \
	echo "  Threads: $(THREADS)"; \
	echo ""; \
	echo "API will be available at: http://localhost:$(PORT)"; \
	echo "To switch models, stop server and restart with: MODEL=path/to/model.gguf llama-server --port $(PORT) --host 0.0.0.0"; \
	echo ""; \
	export LD_LIBRARY_PATH=$(PREFIX):$$LD_LIBRARY_PATH; \
	llama-server -m "$$MODEL" --port $(PORT) -t $(THREADS) --host 0.0.0.0

clean:
	@echo "Removing downloaded models from cache..."
	@rm -rf ~/.cache/llama.cpp/*.gguf
	@echo "✓ Cleaned"


setup_bashrc:
	@echo "Adding llama-cpp to PATH..."
	@echo "export PATH=\$$PATH:$(PREFIX)" >> ~/.bashrc
	@echo "export LD_LIBRARY_PATH=\$$LD_LIBRARY_PATH:$(PREFIX)" >> ~/.bashrc
	@echo "✓ Added to PATH"
	@echo "Run 'source ~/.bashrc' to reload"
