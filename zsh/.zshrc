# Check the terminal capabilities Zsh actually uses before initializing the
# prompt. Homebrew's infocmp can find entries that system Zsh cannot load.
if [[ -n "${SSH_CONNECTION:-}" ]]; then
  zmodload zsh/terminfo
  if [[ -z "${terminfo[cup]-}" ]]; then
    export TERM=xterm-256color
  fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git gh vi-mode zsh-autosuggestions zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# Ensure backspace works reliably across SSH terminal variants.
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Workaround for a Coder workspace template bug: a startup script
# `grep -Fxq`s ~/.zshrc for the literal line `eval "$(direnv hook zsh)"`
# and appends it if absent. Since our ~/.zshrc is a stow symlink into
# this repo, that append lands here, and combined with flaky workspace
# restores it can clobber the file. Keeping the line verbatim, on its
# own line and unindented, makes the grep match so nothing is written.
# The `command -v` guard lets the same config work on machines without
# direnv. Remove this block once the upstream template is fixed.
if command -v direnv >/dev/null 2>&1; then
eval "$(direnv hook zsh)"
fi
