#!/bin/bash

set -e

source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "tree-sitter-cli version" tree-sitter -V

reportResults
