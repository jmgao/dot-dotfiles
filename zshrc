export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
# export UPDATE_ZSH_DAYS=13
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
# HIST_STAMPS="mm/dd/yyyy"
# ZSH_CUSTOM=/path/to/new-custom-folder
plugins=()

# User configuration
source $ZSH/oh-my-zsh.sh

setopt no_share_history
unsetopt cdablevars
unsetopt autopushd

export LANG=en_US.UTF-8

alias pbcopy='xclip -selection clipboard -i'
alias pbpaste='xclip -selection clipboard -o'

alias mosh='mosh --ssh="ssh -o ProxyUseFdpass=no -o UseProxyIf=true -o GSSAPITrustDns=no"'

TERM=xterm-256color

alias vim=nvim
EDITOR=nvim

PATH="$PATH:$HOME/.bin"
PATH="$PATH:$HOME/.local/bin"
PATH="$PATH:$HOME/.ellipsis/bin"
[ -d $HOME/.pt ] && PATH="$PATH:$HOME/.pt"
[ -d /opt/wine/bin ] && PATH="$PATH:/opt/wine/bin"
[ -d $HOME/.gcloud/bin ] && PATH="$PATH:$HOME/.gcloud/bin"

# Rust environment
if [ -d $HOME/.cargo/bin ]; then
  PATH="$PATH:$HOME/.cargo/bin"
  export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi

# Powerline
PYTHONPATH=~/.powerline ~/.powerline/scripts/powerline-daemon -q
source ~/.powerline/powerline/bindings/zsh/powerline.zsh

# Don't complete user directories.
zstyle ':completion:*' users `whoami` root

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.android.zsh ] && source ~/.android.zsh
[ -f ~/.cargo/env ] && source ~/.cargo/env
[ -d ~/.depot_tools ] && PATH="$PATH:$HOME/.depot_tools"
