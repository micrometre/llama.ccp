#!/bin/bash

################################################################################
# llama-cpp Installer for Ubuntu 24.04
# 
# This script installs llama-cpp on Ubuntu 24.04 systems
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation directories
INSTALL_PREFIX="/opt/llama-cpp"
BIN_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib"
SHARE_DIR="/usr/local/share/llama-cpp"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (sudo)"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    print_header "Checking System Requirements"
    
    # Check OS
    if [ ! -f /etc/os-release ]; then
        print_error "Cannot determine OS"
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]] || [[ "$VERSION_ID" != "24.04" ]]; then
        print_warning "This system is $ID $VERSION_ID (not Ubuntu 24.04)"
        print_info "The installer may still work, but compatibility is not guaranteed"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Ubuntu 24.04 detected"
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" ]] && [[ "$ARCH" != "aarch64" ]]; then
        print_error "Unsupported architecture: $ARCH (only x86_64 and aarch64 are supported)"
        exit 1
    fi
    print_success "Architecture: $ARCH"
    
    # Check for required tools
    for cmd in tar gzip; do
        if ! command -v $cmd &> /dev/null; then
            print_error "$cmd is not installed"
            exit 1
        fi
    done
    print_success "Required tools found"
}

# Install dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    print_info "Updating package manager..."
    apt-get update -qq
    
    # Core dependencies
    DEPS=(
        "build-essential"
        "cmake"
        "git"
        "curl"
        "wget"
        "libopenblas-dev"
        "pkg-config"
    )
    
    # Optional GPU support
    read -p "Install GPU support (CUDA)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DEPS+=(
            "nvidia-cuda-toolkit"
            "libcublas-dev"
        )
        print_info "CUDA support will be installed"
    fi
    
    print_info "Installing dependencies..."
    for dep in "${DEPS[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$dep"; then
            print_info "Installing $dep..."
            apt-get install -y -qq "$dep" || print_warning "Could not install $dep"
        else
            print_success "$dep already installed"
        fi
    done
}

# Extract and install binaries
install_binaries() {
    print_header "Installing llama-cpp Binaries"
    
    # Create installation directory
    mkdir -p "$INSTALL_PREFIX"
    
    # Try to download latest release from GitHub
    print_info "Attempting to download latest llama-cpp release from GitHub..."
    
    # Temporary directory for download
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    DOWNLOADED=false
    
    # Try different download methods
    if command -v curl &> /dev/null; then
        # Using curl with redirect follow
        print_info "Fetching latest release information..."
        RELEASE_PAGE=$(curl -sL https://github.com/ggerganov/llama.cpp/releases/latest 2>/dev/null || echo "")
        
        # Extract download URL from release page (looks for bin-ubuntu pattern)
        if [ -n "$RELEASE_PAGE" ]; then
            DOWNLOAD_URL=$(echo "$RELEASE_PAGE" | grep -o 'href="[^"]*bin-ubuntu-x64[^"]*\.tar\.gz"' | head -1 | cut -d'"' -f2)
            
            if [ -z "$DOWNLOAD_URL" ]; then
                DOWNLOAD_URL=$(echo "$RELEASE_PAGE" | grep -o 'href="[^"]*llama.*ubuntu.*x64[^"]*\.tar\.gz"' | head -1 | cut -d'"' -f2)
            fi
            
            # Prepend github.com if path is relative
            if [[ "$DOWNLOAD_URL" == /* ]]; then
                DOWNLOAD_URL="https://github.com${DOWNLOAD_URL}"
            fi
        fi
    fi
    
    # Download if URL found
    if [ -n "$DOWNLOAD_URL" ] && [ "$DOWNLOAD_URL" != "/" ]; then
        TAR_FILE="$TEMP_DIR/llama-cpp-bin.tar.gz"
        print_info "Downloading from: $DOWNLOAD_URL"
        
        if curl -L -# -o "$TAR_FILE" "$DOWNLOAD_URL" 2>/dev/null; then
            print_success "Downloaded successfully"
            DOWNLOADED=true
        else
            print_warning "Failed to download from GitHub"
        fi
    else
        print_warning "Could not find download link on GitHub"
    fi
    
    # Fallback to local tar file if download failed
    if [ "$DOWNLOADED" = false ]; then
        print_info "Looking for local binary package..."
        TAR_FILE=$(find . -maxdepth 1 -name "*.tar.gz" -type f 2>/dev/null | head -1)
        
        if [ -z "$TAR_FILE" ]; then
            print_error "Failed to download from GitHub and no local .tar.gz file found"
            print_info "You can download manually from: https://github.com/ggerganov/llama.cpp/releases"
            exit 1
        fi
        print_info "Using local binary package: $TAR_FILE"
    fi
    
    # Extract binaries
    print_info "Extracting to $INSTALL_PREFIX..."
    tar -xzf "$TAR_FILE" -C "$INSTALL_PREFIX" --strip-components=1 2>/dev/null || \
        tar -xzf "$TAR_FILE" -C "$INSTALL_PREFIX"
    
    # Make binaries executable
    find "$INSTALL_PREFIX/bin" -type f -executable 2>/dev/null | while read bin; do
        chmod +x "$bin"
    done
    
    # Create symlinks in /usr/local/bin
    if [ -d "$INSTALL_PREFIX/bin" ]; then
        for binary in "$INSTALL_PREFIX/bin"/*; do
            if [ -f "$binary" ] && [ -x "$binary" ]; then
                BIN_NAME=$(basename "$binary")
                ln -sf "$binary" "$BIN_DIR/$BIN_NAME"
                print_success "Installed $BIN_NAME"
            fi
        done
    fi
    
    # Copy libraries if they exist
    if [ -d "$INSTALL_PREFIX/lib" ]; then
        cp -r "$INSTALL_PREFIX/lib"/* "$LIB_DIR/" 2>/dev/null || true
        ldconfig
        print_success "Libraries installed"
    fi
}

# Create configuration file
create_config() {
    print_header "Creating Configuration"
    
    mkdir -p "$SHARE_DIR"
    
    cat > "$SHARE_DIR/config.sh" << 'EOF'
#!/bin/bash
# llama-cpp Configuration

# Installation directory
export LLAMA_CPP_HOME="/opt/llama-cpp"

# Add to PATH
export PATH="$LLAMA_CPP_HOME/bin:$PATH"

# Library path
export LD_LIBRARY_PATH="$LLAMA_CPP_HOME/lib:$LD_LIBRARY_PATH"

EOF
    
    chmod +x "$SHARE_DIR/config.sh"
    print_success "Configuration file created"
}

# Create systemd service (optional)
create_service() {
    print_header "Creating Systemd Service"
    
    read -p "Create systemd service for llama-cpp? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cat > /etc/systemd/system/llama-cpp.service << EOF
[Unit]
Description=llama-cpp Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_PREFIX
ExecStart=$INSTALL_PREFIX/bin/llama-server
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target

EOF
        
        systemctl daemon-reload
        print_success "Systemd service created"
    fi
}

# Create uninstaller script
create_uninstaller() {
    print_header "Creating Uninstaller"
    
    cat > "$INSTALL_PREFIX/uninstall.sh" << 'EOF'
#!/bin/bash
# llama-cpp Uninstaller

echo "Removing llama-cpp..."

# Remove systemd service if exists
if [ -f /etc/systemd/system/llama-cpp.service ]; then
    systemctl disable llama-cpp.service 2>/dev/null || true
    systemctl stop llama-cpp.service 2>/dev/null || true
    rm /etc/systemd/system/llama-cpp.service
    systemctl daemon-reload
fi

# Remove symlinks
rm -f /usr/local/bin/llama-*

# Remove installation directory
rm -rf /opt/llama-cpp

echo "llama-cpp has been uninstalled"

EOF
    
    chmod +x "$INSTALL_PREFIX/uninstall.sh"
    print_success "Uninstaller created at $INSTALL_PREFIX/uninstall.sh"
}

# Print system information
print_system_info() {
    print_header "System Information"
    print_info "Installation prefix: $INSTALL_PREFIX"
    print_info "Binary directory: $BIN_DIR"
    print_info "Library directory: $LIB_DIR"
    print_info "Configuration directory: $SHARE_DIR"
}

# Main installation process
main() {
    print_header "llama-cpp Installer for Ubuntu 24.04"
    echo
    
    check_root
    check_requirements
    print_system_info
    
    print_header "Installation Steps"
    echo "1. Install system dependencies"
    echo "2. Extract binaries"
    echo "3. Create configuration"
    echo "4. Setup systemd service (optional)"
    echo
    
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
    
    install_dependencies
    install_binaries
    create_config
    create_service
    create_uninstaller
    
    print_header "Installation Complete!"
    print_success "llama-cpp has been successfully ili -talled"
    echo
    print_info "To verify installation, run: llama-cpp-version"
    print_info "Configuration file: $SHARE_DIR/config.sh"
    print_info "To uninstall: $INSTALL_PREFIX/uninstall.sh"
    echo
    print_info "For more information, visit the llama-cpp documentation"
}

# Run main function
main "$@"
