#!/usr/bin/env bash
# step2-claude-code.sh — install Claude Code, authenticate with GitHub,
# clone the private how-I-work repo, copy provision prompt to clipboard,
# and launch Claude Code

set -euo pipefail

show_help() {
  cat <<'HELP'
step2-claude-code.sh — Bootstrap step 2 of 2

WHAT IT DOES
  1. Confirms Homebrew is reachable (sources shellenv if needed).
  2. Installs the `claude-code` Homebrew cask (CLI binary only —
     Claude Code is a TUI launched with `claude` in your terminal,
     NOT a Mac app).
  3. Installs `gh` Homebrew formula if not present.
  4. Runs `gh auth login --web` (browser-based — you authenticate
     in the browser, gh stores the token in macOS Keychain).
  5. Clones the private donbox/how-I-work repo to ~/repos/wp/how-I-work.
  6. Copies the contents of provision-machine.md to the clipboard via
     pbcopy.
  7. Prints the next-action: type `claude` in your terminal to launch.

REQUIRES
  - Homebrew installed (run step1-homebrew.sh first if not).
  - Internet connection.
  - A GitHub account with read access to donbox/how-I-work (the user
    running this bootstrap).
  - A web browser for the gh auth login flow.

PRODUCES
  - `claude` and `gh` commands on PATH at /opt/homebrew/bin/.
  - gh authenticated against github.com.
  - ~/repos/wp/how-I-work/ clone of the private how-I-work repo.
  - Provision prompt text on the clipboard, ready to Cmd+V.

USAGE
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step2-claude-code.sh)"
  # or, after fetching locally:
  bash step2-claude-code.sh

  DO NOT use `curl ... | bash`. Piping disconnects stdin from the
  terminal, and gh auth login can't complete the interactive flow.

NEXT
  1. In your terminal, type `claude` and press Return — that launches
     the Claude Code TUI.
  2. Sign in to your Anthropic account (one-time).
  3. Cmd+V to paste the provision prompt into a new conversation.
  4. Claude Code drives the rest of the migration (Steps 0-15).

SAFE TO RE-RUN
  Yes. Each step checks before acting:
  - brew install --cask claude-code is a no-op if already installed
  - gh auth login is skipped if already authenticated (status check first)
  - gh repo clone is skipped if the directory already exists
HELP
}

case "${1:-}" in
  -h|--help|help)
    show_help
    exit 0
    ;;
esac

echo "=========================================="
echo "Step 2: Install Claude Code + clone how-I-work"
echo "=========================================="
echo

# Make sure brew is on PATH in this shell, even if step1 ran in a
# different terminal and we haven't re-logged-in yet.
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "✗ Homebrew not found. Run step 1 first:"
    echo
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step1-homebrew.sh)"'
    exit 1
  fi
fi

# --- Claude Code (CLI binary, not a Mac app) ---
if command -v claude >/dev/null 2>&1; then
  echo "✓ Claude Code already installed: $(claude --version 2>&1 | head -1)"
else
  echo "Installing Claude Code via Homebrew cask..."
  brew install --cask claude-code
  # Verify it actually landed on PATH — the cask installs `claude` to
  # /opt/homebrew/bin which is already on PATH from step1's shellenv.
  if ! command -v claude >/dev/null 2>&1; then
    echo "✗ Installed but claude not on PATH. Try a fresh terminal, or:"
    echo "    eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    exit 1
  fi
  echo "✓ Claude Code installed: $(claude --version 2>&1 | head -1)"
fi

# --- gh CLI ---
if command -v gh >/dev/null 2>&1; then
  echo "✓ gh already installed: $(gh --version | head -1)"
else
  echo "Installing gh CLI..."
  brew install gh
fi

# --- gh auth ---
if gh auth status >/dev/null 2>&1; then
  echo "✓ gh already authenticated"
else
  echo
  echo "Authenticating with GitHub. A browser window will open."
  echo "Sign in to the account that has access to donbox/how-I-work."
  echo
  gh auth login --hostname github.com --git-protocol https --web
fi

# --- Clone how-I-work ---
HIW_DIR="$HOME/repos/wp/how-I-work"
if [[ -d "$HIW_DIR/.git" ]]; then
  echo "✓ how-I-work already cloned at $HIW_DIR"
else
  echo "Cloning donbox/how-I-work to $HIW_DIR..."
  mkdir -p "$HOME/repos/wp"
  gh repo clone donbox/how-I-work "$HIW_DIR"
fi

# --- Copy provision prompt to clipboard ---
PROVISION_PROMPT="$HIW_DIR/machine-setup/provision-machine.md"
if [[ -f "$PROVISION_PROMPT" ]]; then
  pbcopy < "$PROVISION_PROMPT"
  echo "✓ Provision prompt copied to clipboard ($(wc -l < "$PROVISION_PROMPT") lines)"
else
  echo "⚠ Provision prompt not found at $PROVISION_PROMPT — clone may have failed"
fi

echo
echo "=========================================="
echo "✓ Step 2 of 2 complete."
echo
echo "WHAT'S NEXT"
echo "  1. In THIS terminal, type:    claude"
echo "     and press Return. That launches the Claude Code TUI."
echo "     (Claude Code is a terminal app, not a Mac app — there is"
echo "     no Claude.app to open from /Applications.)"
echo "  2. Sign in with your Anthropic account (one-time)."
echo "  3. Cmd+V to paste the provision prompt — it's on your clipboard."
echo "     (Source: $PROVISION_PROMPT)"
echo "  4. Claude Code starts with Step 0 — telling you which App Store"
echo "     and Safari downloads to kick off in the background (Xcode is"
echo "     ~3 hr, start it first)."
echo "  5. Claude Code drives the rest of the migration through Step 15."
echo "=========================================="
