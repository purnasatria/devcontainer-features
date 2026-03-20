#!/bin/sh
set -e

echo "Activating feature 'neovim'"

VERSION=${VERSION:-stable}
echo "The version to be installed is: $VERSION"

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure curl is available
if ! command -v curl > /dev/null 2>&1; then
    apt-get update -y
    apt-get install -y curl
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi

# Determine architecture
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64)  NVIM_ARCH="x86_64" ;;
    aarch64) NVIM_ARCH="arm64" ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

TARBALL="nvim-linux-${NVIM_ARCH}.tar.gz"

# Determine download URL
if [ "$VERSION" = "stable" ]; then
    DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/${TARBALL}"
elif [ "$VERSION" = "nightly" ]; then
    DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/nightly/${TARBALL}"
else
    DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/v${VERSION}/${TARBALL}"
fi

echo "Downloading neovim from ${DOWNLOAD_URL}..."

curl -fLo "/tmp/${TARBALL}" "${DOWNLOAD_URL}"
mkdir -p /usr/local/nvim
tar -C /usr/local/nvim --strip-components=1 -xzf "/tmp/${TARBALL}"
ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
rm "/tmp/${TARBALL}"

echo "Neovim $(nvim --version | head -1) installed successfully."
