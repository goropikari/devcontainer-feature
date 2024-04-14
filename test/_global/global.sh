#!/bin/bash

# The 'test/_global' folder is a special test folder that is not tied to a single feature.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "neovim version" nvim --version

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
