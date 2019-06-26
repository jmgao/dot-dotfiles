#!/usr/bin/env bash
#
# jmgao/dotfiles ellipsis package

# The following hooks can be defined to customize behavior of your package:
pkg.install() {
    git submodule init
    git submodule update --init --recursive

    sudo apt-get install build-essential cmake ninja-build

    # Make sure the vim backup directory exists.
    mkdir $PKG_PATH/vim/backup

    # Install rust, and various rust tools.
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly --no-modify-path
    $HOME/.cargo/bin/rustup component add rust-src
    $HOME/.cargo/bin/cargo install cargo-watch cargo-size

    fs.link_files $PKG_PATH
}

# pkg.push() {
#     git.push
# }

pkg.pull() {
    git.pull
    git submodule update --recursive
}

# pkg.installed() {
#     git.status
# }
#
# pkg.status() {
#     git.diffstat
# }
