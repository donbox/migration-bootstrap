# migration-bootstrap

Public on-ramp to a private Mac migration workflow.

These two scripts get a freshly-installed Mac to the point where Claude
Code is running with the full migration prompt on the clipboard, ready
to drive everything else. The rest of the workflow lives in the private
[donbox/how-I-work](https://github.com/donbox/how-I-work) repo, which
step 2 clones after `gh auth login`.

## Usage

On a freshly installed Mac, open Terminal.app and run:

```sh
curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step1-homebrew.sh | bash
curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step2-claude-code.sh | bash
```

Both scripts support `--help` if you want to read what they do before
running them.

### What step 1 does

[`step1-homebrew.sh`](step1-homebrew.sh) installs Homebrew and wires
the `brew shellenv` into `~/.zprofile`. ~10 min, asks for your password
and offers to install Xcode Command Line Tools.

### What step 2 does

[`step2-claude-code.sh`](step2-claude-code.sh):

1. Installs Claude Code via `brew install --cask claude-code`.
2. Installs `gh` via `brew install gh`.
3. Runs `gh auth login --web` so you can sign in via browser.
4. Clones the private `donbox/how-I-work` repo to `~/repos/wp/how-I-work`.
5. Pipes `machine-setup/provision-machine.md` to `pbcopy`.
6. Launches Claude Code.

When it finishes, switch to Claude Code, sign in to your Anthropic
account, and `Cmd+V` to paste the provision prompt. Claude Code drives
the rest.

## Why a separate public repo

The `how-I-work` repo is private (workflow notes, machine config,
machine-licensed software list, etc.). But `curl | bash` doesn't work
on a private repo until you've authenticated with `gh`, which is itself
inside the private repo. This bootstrap solves the chicken-and-egg by
keeping the two scripts public so `curl | bash` reaches them, and
having step 2 handle the gh auth + clone before exposing any of the
private content.

## Re-running

Both scripts are idempotent. Re-running detects what's already installed
or already cloned and skips it. Useful if something fails partway.
