#!/bin/bash

set -e

source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "neovim version" nvim --version
check "tree-sitter version" tree-sitter -V
check "tree-sitter not pinned to bookworm version" sh -c '! tree-sitter -V | grep -F "0.25.10"'

reportResults
