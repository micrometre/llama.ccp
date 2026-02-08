.PHONY: help install uninstall server download-deepseek  clean

# Installation prefix

help:
	@echo "llama-cpp - Build, Install & Run"
	@echo "=================================="
	@echo ""
	@echo "Installation:"
	@echo "  make install          - Run the interactive installer"
	@echo "  make uninstall        - Remove llama-cpp installation"
	@echo ""
	@echo "Models (download to ./models/):"
	@echo "  CODING MODELS:"
	@echo "  make download-deepseek-7b - DeepSeek Coder 6.7B Q4_K_M (4GB, recommended)"
	@echo ""
	@echo "Running:"
	@echo "  make server           - Start llama-server (PORT=$(PORT) THREADS=$(THREADS))"
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

models:
	@mkdir -p $(MODELS_DIR)
	@echo "✓ Models directory: $(MODELS_DIR)"


install-huggingface-cli:
	python -c "from huggingface_hub import model_info; print(model_info('gpt2'))"
	@echo "Installing Hugging Face CLI in .venv..."
	@pip install --upgrade huggingface_hub
	@echo "✓ Hugging Face CLI installed"






download-deepseek-7b: models
	@echo "Downloading DeepSeek Coder 6.7B Q4_K_M (about 4GB)..."
	@echo "This will take 10-20 minutes depending on your connection..."
	@cd $(MODELS_DIR) && \
	if [ -x $(HF_CLI) ]; then \
		$(HF_CLI) download TheBloke/deepseek-coder-6.7B-instruct-GGUF \
			deepseek-coder-6.7b-instruct.Q4_K_M.gguf --local-dir . --local-dir-use-symlinks False; \
	else \
		wget -c -q --show-progress \
		  'https://huggingface.co/TheBloke/deepseek-coder-6.7B-instruct-GGUF/resolve/main/deepseek-coder-6.7b-instruct.Q4_K_M.gguf' \
		  -O deepseek-coder-6.7b-instruct.Q4_K_M.gguf; \
	fi && \
	if file deepseek-coder-6.7b-instruct.Q4_K_M.gguf | grep -q "data"; then \
		SIZE=$$(ls -lh deepseek-coder-6.7b-instruct.Q4_K_M.gguf | awk '{print $$5}'); \
		echo "✓ Downloaded: deepseek-coder-6.7b-instruct.Q4_K_M.gguf ($$SIZE)"; \
	else \
		echo "✗ Download incomplete or corrupted"; \
		rm -f deepseek-coder-6.7b-instruct.Q4_K_M.gguf; \
		exit 1; \
	fi


server:
	@if [ ! -f $(PREFIX)/bin/llama-server ]; then \
		echo "Error: llama-cpp not installed. Run 'make install' first."; \
		exit 1; \
	fi
	@if [ -z "$$(ls $(MODELS_DIR)/*.gguf 2>/dev/null)" ]; then \
		echo "Error: No models found in $(MODELS_DIR)/"; \
		echo "Download a model first: make download-mistral"; \
		exit 1; \
	fi
	@MODEL=$$(ls -1 $(MODELS_DIR)/*.gguf | head -1); \
	echo "Starting llama-server..."; \
	echo "  Model: $$MODEL"; \
	echo "  Port: $(PORT)"; \
	echo "  Threads: $(THREADS)"; \
	echo ""; \
	echo "API will be available at: http://localhost:$(PORT)"; \
	echo ""; \
	export LD_LIBRARY_PATH=$(PREFIX)/lib:$$LD_LIBRARY_PATH; \
	llama-server -m "$$MODEL" -p $(PORT) -t $(THREADS)

clean:
	@echo "Removing downloaded models..."
	@rm -rf $(MODELS_DIR)/*.gguf
	@echo "✓ Cleaned"