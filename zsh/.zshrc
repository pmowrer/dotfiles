# User-specific overrides
if [[ -f "$HOME/.zshrc.$(whoami)" ]]; then
  source "$HOME/.zshrc.$(whoami)"
fi

# Path
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Aliases
alias ls='ls -la'

# Terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Use vi editing mode
bindkey -v

# cd into whatever is the forefront Finder window.
# from: https://github.com/paulirish/dotfiles/commit/e67d1bc03
cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Powerlevel10k theme configuration
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
