# Minimal Powerlevel10k configuration placeholder.
# Replace with `p10k configure` output as needed.

# Show a concise left prompt with current path, host name, and vcs status.
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir context vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)

# Always show the current host in the prompt.
typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%m'
