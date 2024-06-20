export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Export bins
export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH":"$HOME/.local/bin"

# asdf
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

# Flutter
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Go
export PATH="$PATH:$(go env GOPATH)/bin"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

#Plugins
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

#Star Ship
eval "$(starship init zsh)"

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias m="multipass"
