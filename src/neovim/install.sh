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

is_version_greater_or_equal_to_0_10_4() {
    local version1="$1"
    local version2="v0.10.4"

    if [ $version1 = "stable" ]; then
        return 0
    fi
    if [ $version1 = "latest" ]; then
        return 0
    fi

    if [ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" = "$version1" ]; then
        if [ "$version1" = "$version2" ]; then
            return 0  # true
        else
            return 1  # false
        fi
    else
        return 0  # true
    fi
}

set -e

apt-get update
apt-get install -y curl

NVIM_VERSION=${VERSION:-"stable"}
if is_version_greater_or_equal_to_0_10_4 "${NVIM_VERSION}"; then
    ASSET=nvim-linux-x86_64.tar.gz
else
    ASSET=nvim-linux64.tar.gz
fi
curl -L https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${ASSET} -o nvim.tar.gz

rm -rf /opt/nvim
mkdir -p /opt/nvim
tar --strip-components=1 -xf nvim.tar.gz -C /opt/nvim/

NEOVIM_HOME=/opt/nvim
export PATH=${NEOVIM_HOME}/bin:${PATH}
updaterc "$(cat << EOF
export NEOVIM_HOME=${NEOVIM_HOME}
if [[ "\${PATH}" != *"\${NEOVIM_HOME}/bin"* ]]; then export PATH="\${NEOVIM_HOME}/bin:\${PATH}"; fi
EOF
)"

echo "Done!"
