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

set -e

apt-get update
apt-get install -y curl jq

ZELLIJ_VERSION=${VERSION:-"latest"}
if [ "${ZELLIJ_VERSION}" = "latest" ]; then
    ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | jq -r '.tag_name')
fi
ASSET=zellij-x86_64-unknown-linux-musl.tar.gz 
curl -L https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/${ASSET} -o zellij.tar.gz


rm -rf /opt/zellij
mkdir -p /opt/zellij/bin
tar xf zellij.tar.gz -C /opt/zellij/bin

ZELLIJ_HOME=/opt/zellij
export PATH=${ZELLIJ_HOME}/bin:${PATH}
updaterc "$(cat << EOF
export ZELLIJ_HOME=${ZELLIJ_HOME}
if [[ "\${PATH}" != *"\${ZELLIJ_HOME}/bin"* ]]; then export PATH="\${ZELLIJ_HOME}/bin:\${PATH}"; fi
EOF
)"

echo "Done!"
