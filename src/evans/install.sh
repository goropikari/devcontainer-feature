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
apt-get install -y curl

EVANS_VERSION=${VERSION:-"latest"}
EVANS_HOME=/opt/evans
if [[ $EVANS_VERSION -eq "latest" ]]; then
    s=$(curl -s --head https://github.com/ktr0731/evans/releases/latest | grep location)
    [[ ${s} =~ tag\/(v[0-9]+\.[0-9]+\.[0-9]+) ]]
    EVANS_VERSION=${BASH_REMATCH[1]}
fi
curl -LO https://github.com/ktr0731/evans/releases/download/${EVANS_VERSION}/evans_linux_amd64.tar.gz
mkdir -p /opt/evans/bin
tar xf evans_linux_amd64.tar.gz -C ${EVANS_HOME}/bin

export PATH=${EVANS_HOME}/bin:${PATH}
updaterc "$(cat << EOF
export EVANS_HOME=${EVANS_HOME}
if [[ "\${PATH}" != *"\${EVANS_HOME}/bin"* ]]; then export PATH="\${EVANS_HOME}/bin:\${PATH}"; fi
EOF
)"

echo "Done!"
