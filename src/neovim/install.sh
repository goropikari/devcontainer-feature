#!/bin/sh

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi
$SUDO apt-get remove -y neovim

set -e

$SUDO apt-get update
$SUDO apt-get install -y curl

NVIM_VERSION=${VERSION:-"stable"}
curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage
chmod +x nvim.appimage
$SUDO rm -rf /opt/nvim
$SUDO mkdir -p /opt/nvim
mv nvim.appimage /opt/nvim/
cd /opt/nvim
./nvim.appimage --appimage-extract
ln -sf /opt/nvim/squashfs-root/usr/bin/nvim /usr/bin/nvim

echo "Done!"
