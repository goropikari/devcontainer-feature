#!/bin/bash
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Install dependencies
apt-get update
apt-get install -y git cmake g++ make

# Clone pict repository
git clone --depth 1 -b v3.7.4 https://github.com/microsoft/pict.git /tmp/pict

# Build pict
cd /tmp/pict
cmake -DCMAKE_BUILD_TYPE=Release -S . -B build
cmake --build build

# Install pict
mv build/cli/pict /usr/local/bin/pict

# Clean up
rm -rf /tmp/pict

echo "Done!"
