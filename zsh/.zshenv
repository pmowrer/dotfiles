# .zshenv is sourced by every zsh invocation, including the non-login shells
# that herdr panes and `ssh host <command>` run. Those never source .zprofile,
# so PATH setup they depend on has to live here or the tools go missing.
#
# typeset -U keeps PATH duplicate-free as shells nest, which also lets
# .zprofile re-run `brew shellenv` without entries piling up.
typeset -U path PATH

if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
  for _brew_candidate in \
    /home/linuxbrew/.linuxbrew/bin/brew \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew
  do
    if [[ -x "$_brew_candidate" ]]; then
      eval "$("$_brew_candidate" shellenv)"
      break
    fi
  done
  unset _brew_candidate
fi

# ~/.local/bin holds user-installed binaries (hivemind, awp, herdr). It goes
# after the Homebrew block so it wins for tools that exist in both places;
# the running herdr server is the ~/.local/bin copy.
path=("$HOME/.local/bin" $path)
export PATH
