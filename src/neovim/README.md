
# neovim (neovim)

Install neovim and tree-sitter-cli

## Example Usage

```json
"features": {
    "ghcr.io/goropikari/devcontainer-feature/neovim:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a neovim version to install | string | stable |
| treeSitterVersion | Select or enter a tree-sitter-cli version to install. auto uses 0.25.10 on Debian bookworm and latest elsewhere | string | auto |

## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.

## tree-sitter

This Feature also installs `tree-sitter` CLI.

`treeSitterVersion=auto` installs `0.25.10` on Debian bookworm and the latest release elsewhere. Setting `treeSitterVersion` explicitly overrides the automatic selection.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/goropikari/devcontainer-feature/blob/main/src/neovim/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
