#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt-get update
apt-get install -y curl gzip

VERSION=${VERSION:-"latest"}

if [ "$VERSION" = "latest" ]; then
    VERSION=$(curl -sL https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
fi

VERSION=${VERSION#v}

ARCHITECTURE=""
case "$(dpkg --print-architecture)" in
    amd64) ARCHITECTURE="x64";;
    arm64) ARCHITECTURE="arm64";;
    *) echo "unsupported architecture"; exit 1 ;;
esac

curl -L https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-linux-${ARCHITECTURE}.gz -o tree-sitter.gz
echo $VERSION
echo $ARCHITECTURE
ls -l tree-sitter.gz
gzip -d tree-sitter.gz

mv tree-sitter /usr/local/bin/tree-sitter
chmod +x /usr/local/bin/tree-sitter

echo "Done!"
