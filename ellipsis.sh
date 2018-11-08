#!/usr/bin/env bash
#
# jmgao/dotfiles ellipsis package

# The following hooks can be defined to customize behavior of your package:
pkg.install() {
    git submodule init
    git submodule update --init --recursive

    # Make sure the vim backup directory exists.
    mkdir $PKG_PATH/vim/backup

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
