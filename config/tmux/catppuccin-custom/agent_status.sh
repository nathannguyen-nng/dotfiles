# Custom Catppuccin status-left module: aggregate agent-status summary
# (running/waiting/error counts), sourced from tmux-agent-sidebar's
# @pane_status pane options, centered across the full status bar.
#
# Requires https://github.com/hiroppy/tmux-agent-sidebar

show_agent_status() {
  echo "#[align=centre]#($HOME/.config/tmux/scripts/agent-status-summary.sh)#[align=left]"
}
