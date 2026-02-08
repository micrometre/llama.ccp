#!/bin/bash
# Wrapper script for llama-cli that ensures proper library loading

export LD_LIBRARY_PATH=/opt/llama-cpp/lib:$LD_LIBRARY_PATH
export GGML_BACKENDS=cpu

exec /opt/llama-cpp/bin/llama-cli "$@"
