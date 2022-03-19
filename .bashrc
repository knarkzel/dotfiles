# aliases
alias man="info"
alias nano="nano -0"
alias si="sudo pacman -S"
alias sr="sudo pacman -R"
alias ls="ls --color=always --group-directories-first"
alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

# exports
export EDITOR="nano -0"
export VISUAL="nano -0"
export BROWSER="chromium"
export HISTCONTROL=ignorespace:ignoredups:erasedups
export PATH="$PATH:$HOME/.cargo/bin/:$HOME/.local/bin:$HOME/.scripts/menu"
