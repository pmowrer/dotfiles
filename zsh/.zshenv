# .zshenv is sourced by every zsh invocation, including the non-login shells
# that herdr panes and `ssh host <command>` run. Those never source .zprofile,
# so PATH setup they depend on has to live here or the tools go missing.
#
# typeset -U keeps PATH duplicate-free as shells nest, which also lets
# .zprofile re-run `brew shellenv` without entries piling up.
typeset -U path PATH

# Powerlevel10k starts one gitstatusd per interactive shell. Its CPU-based
# worker default can exhaust the workspace task limit across many Herdr panes.
# Keep the default small while honoring an explicit environment override.
export GITSTATUS_NUM_THREADS="${GITSTATUS_NUM_THREADS:-2}"

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

# ~/.local/bin holds user-installed binaries. It goes
# after the Homebrew block so it wins for tools that exist in both places;
# the running herdr server is the ~/.local/bin copy.
path=("$HOME/.local/bin" $path)
export PATH

# Yarn 4 derives its shared cache from globalFolder when enableGlobalCache is
# active. Keep that state on disposable storage while leaving cacheFolder free
# for projects that intentionally use a project-local cache.
typeset _yarn_global_folder="/tmp/yarn-$UID"
typeset _yarn_cache_folder="$_yarn_global_folder/cache"

(umask 077 && mkdir -m 700 -- "$_yarn_global_folder") 2>/dev/null || true
if [[ -d "$_yarn_global_folder" && ! -L "$_yarn_global_folder" && -O "$_yarn_global_folder" ]] &&
  chmod 700 "$_yarn_global_folder"
then
  (umask 077 && mkdir -m 700 -- "$_yarn_cache_folder") 2>/dev/null || true
  if [[ -d "$_yarn_cache_folder" && ! -L "$_yarn_cache_folder" && -O "$_yarn_cache_folder" ]] &&
    chmod 700 "$_yarn_cache_folder"
  then
    export YARN_GLOBAL_FOLDER="$_yarn_global_folder"
  else
    unset YARN_GLOBAL_FOLDER
  fi
else
  unset YARN_GLOBAL_FOLDER
fi
unset _yarn_global_folder _yarn_cache_folder
