#!/bin/bash

UPDATE_RC="${UPDATE_RC:-"true"}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh


updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/bash.bashrc
        fi
        if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}


apt-get remove -y neovim

set -e

apt-get update
apt-get install -y curl

NVIM_VERSION=${VERSION:-"stable"}
curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage
chmod +x nvim.appimage
rm -rf /opt/nvim
mkdir -p /opt/nvim
mv nvim.appimage /opt/nvim/
cd /opt/nvim
./nvim.appimage --appimage-extract

NEOVIM_HOME=/opt/nvim/squashfs-root/usr
export PATH=${NEOVIM_HOME}/bin:${PATH}
updaterc "$(cat << EOF
export NEOVIM_HOME=${NEOVIM_HOME}
if [[ "\${PATH}" != *"\${NEOVIM_HOME}/bin"* ]]; then export PATH="\${NEOVIM_HOME}/bin:\${PATH}"; fi
EOF
)"

echo "Done!"
