export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH}/custom"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  gh
  zsh-vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

[ -f "${HOME}/.p10k.zsh" ] && source "${HOME}/.p10k.zsh"
