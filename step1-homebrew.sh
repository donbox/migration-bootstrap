#!/usr/bin/env bash
# step1-homebrew.sh — install Homebrew and wire it into ~/.zprofile

set -euo pipefail

show_help() {
  cat <<'HELP'
step1-homebrew.sh — Bootstrap step 1 of 2

WHAT IT DOES
  1. Runs the official Homebrew installer (curl ... install.sh).
  2. Appends `eval "$(/opt/homebrew/bin/brew shellenv)"` to ~/.zprofile
     so future Terminal sessions pick up brew on PATH automatically.
  3. Activates brew in the current shell.
  4. Prints `brew --version` to verify.

REQUIRES
  - Apple Silicon Mac (installs to /opt/homebrew, not /usr/local).
  - Internet connection.
  - Your macOS login password (for sudo during Homebrew install).
  - Permission to install Xcode Command Line Tools when prompted.

PRODUCES
  - Homebrew installed at /opt/homebrew.
  - ~/.zprofile contains the brew shellenv line (idempotent — only
    appends if not already present).
  - `brew` command available in this shell and all future ones.

USAGE
  curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step1-homebrew.sh | bash
  # or, after fetching locally:
  bash step1-homebrew.sh

NEXT
  Run step2-claude-code.sh to install Claude Code, authenticate with
  GitHub, and clone the private how-I-work repo containing the rest
  of the migration workflow.

SAFE TO RE-RUN
  Yes. Detects existing Homebrew install and skips. Detects existing
  ~/.zprofile shellenv line and skips. Use to recover from a partial
  install.
HELP
}

case "${1:-}" in
  -h|--help|help)
    show_help
    exit 0
    ;;
esac

echo "=========================================="
echo "Step 1: Install Homebrew"
echo "=========================================="
echo

if command -v brew >/dev/null 2>&1; then
  echo "✓ Homebrew already installed: $(brew --version | head -1)"
else
  echo "Installing Homebrew."
  echo
  echo "What to expect:"
  echo "  1. You'll be asked to press RETURN to confirm."
  echo "  2. You'll be asked for your macOS login password (sudo)."
  echo "  3. A pop-up may ask to install Xcode Command Line Tools — click Install."
  echo "  4. The install itself takes ~5-10 minutes after CLT is in place."
  echo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Wire brew into the login shell so future terminals get it on PATH.
# Only append if not already there.
BREW_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'
if ! grep -qF "$BREW_LINE" "$HOME/.zprofile" 2>/dev/null; then
  echo "" >> "$HOME/.zprofile"
  echo "$BREW_LINE" >> "$HOME/.zprofile"
  echo "✓ Appended brew shellenv to ~/.zprofile"
else
  echo "✓ ~/.zprofile already has brew shellenv"
fi

# Activate brew in THIS shell too, so the verify below works
eval "$(/opt/homebrew/bin/brew shellenv)"

echo
echo "✓ Verify: $(brew --version | head -1)"
echo

echo "=========================================="
echo "✓ Step 1 of 2 complete: Homebrew installed."
echo
echo "WHAT'S NEXT"
echo "  Run step 2 to install Claude Code, authenticate with GitHub,"
echo "  and clone the private how-I-work repo. Copy and paste:"
echo
echo "    curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step2-claude-code.sh | bash"
echo "=========================================="
