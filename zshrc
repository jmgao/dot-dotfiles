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

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

alias mosh='mosh --ssh="ssh -o ProxyUseFdpass=no -o UseProxyIf=true -o GSSAPITrustDns=no"'

if [[ "$TERM" == "xterm" ]]; then
  TERM=xterm-256color
fi

PATH="$PATH:$HOME/.bin"
PATH="$PATH:$HOME/.local/bin"
PATH="$PATH:$HOME/.ellipsis/bin"

# Rust environment
[ -d $HOME/.rustsrc/1.8.0/src ] && export RUST_SRC_PATH=$HOME/.rustsrc/1.8.0/src
if [ -d $HOME/.multirust/toolchains/stable/cargo/bin ]; then
  PATH="$PATH:$HOME/.multirust/toolchains/stable/cargo/bin"
fi

# Powerline
PYTHONPATH=~/.powerline ~/.powerline/scripts/powerline-daemon -q
source ~/.powerline/powerline/bindings/zsh/powerline.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.android.zsh ] && source ~/.android.zsh
