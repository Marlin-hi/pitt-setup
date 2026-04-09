#!/bin/bash
# Sage Subagent Launch Script
# Usage: subagent-launch.sh <project-dir> <task-name> <prompt-file> [signal-name]
set -euo pipefail
PROJECT_DIR="$1"
TASK_NAME="$2"
PROMPT_FILE="$3"
SIGNAL="${4:-}"
cd "$PROJECT_DIR"
BRANCH="subagent-$(date +%s)"
git worktree add ".worktrees/$BRANCH" -b "$BRANCH" 2>/dev/null || true
cd ".worktrees/$BRANCH"
unset CLAUDECODE
export SAGE_SUBAGENT=1
PROMPT=$(cat "$PROJECT_DIR/$PROMPT_FILE")
# Claude-Pfad finden
CLAUDE_BIN="claude"
[ -f "$HOME/.local/bin/claude" ] && CLAUDE_BIN="$HOME/.local/bin/claude"
[ -f "$LOCALAPPDATA/Programs/claude-code/claude.exe" ] && CLAUDE_BIN="$LOCALAPPDATA/Programs/claude-code/claude.exe"
"$CLAUDE_BIN" "$PROMPT"
cd "$PROJECT_DIR"
git merge ".worktrees/$BRANCH" --no-edit 2>/dev/null || true
git worktree remove ".worktrees/$BRANCH" --force 2>/dev/null || true
git branch -d "$BRANCH" 2>/dev/null || true
if [ -n "$SIGNAL" ]; then touch ".claude/signals/$SIGNAL.done"; fi
echo "=== SUBAGENT FERTIG ==="
