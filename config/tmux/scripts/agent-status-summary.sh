#!/usr/bin/env bash
# Aggregate tmux-agent-sidebar's per-pane @pane_status options (written by its
# Claude/Codex/OpenCode hooks) into a single summary string, the same idea as
# tmux-agent-status's old status-line.sh but sourced from tmux-agent-sidebar's
# documented scripting interface (@pane_status / @pane_attention pane options).

running=0
waiting=0
error=0
idle=0

while IFS= read -r status; do
    case "$status" in
        running|background) ((running++)) ;;
        waiting) ((waiting++)) ;;
        error) ((error++)) ;;
        idle) ((idle++)) ;;
    esac
done < <(tmux list-panes -a -F '#{@pane_status}' 2>/dev/null)

total=$((running + waiting + error + idle))

if [ "$total" -eq 0 ]; then
    echo ""
elif [ "$running" -eq 0 ] && [ "$waiting" -eq 0 ] && [ "$error" -eq 0 ] && [ "$idle" -gt 0 ]; then
    echo "#[fg=green,bold]✓ all ready#[default]"
else
    parts=()
    [ "$running" -gt 0 ] && parts+=("#[fg=yellow,bold]⚡ ${running} running#[default]")
    [ "$waiting" -gt 0 ] && parts+=("#[fg=cyan,bold]⏸ ${waiting} waiting#[default]")
    [ "$error" -gt 0 ] && parts+=("#[fg=red,bold]✗ ${error} error#[default]")
    [ "$idle" -gt 0 ] && parts+=("#[fg=green]✓ ${idle} ready#[default]")

    IFS=' '
    echo "${parts[*]}"
fi
