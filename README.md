# migration-bootstrap

## What to type on a fresh Mac

After clean macOS install, in Terminal.app:

```sh
curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step1-homebrew.sh | bash
curl -fsSL https://raw.githubusercontent.com/donbox/migration-bootstrap/main/step2-claude-code.sh | bash
```

Step 2 ends with Claude Code launched and the provision prompt on your
clipboard. Sign in to Claude Code, open a new conversation, and **Cmd+V**.

---

# Background

Everything below is reference material. The two commands above are what
you actually type.

## What each script does

- **[step1-homebrew.sh](step1-homebrew.sh)** — installs Homebrew and
  wires `brew shellenv` into `~/.zprofile`. ~10 min. Asks for your
  password and offers to install Xcode Command Line Tools.
- **[step2-claude-code.sh](step2-claude-code.sh)** — installs Claude
  Code via `brew install --cask claude-code`, installs `gh`, runs
  `gh auth login --web` (you sign in to GitHub via browser), clones
  the private `donbox/how-I-work` repo to `~/repos/wp/how-I-work`,
  pipes `machine-setup/provision-machine.md` to `pbcopy`, and
  launches Claude Code.

Both scripts support `--help` for a full description.

## Why a separate public repo

The migration workflow itself (provision prompt, decommission prompt,
bundle script, runbook) lives in the private
[donbox/how-I-work](https://github.com/donbox/how-I-work) repo. But
`curl | bash` doesn't work against a private repo until you've
authenticated with `gh`, which is itself referenced from inside the
private repo. This public repo solves the chicken-and-egg: two
public scripts that the fresh Mac can reach, and step 2 handles
`gh auth login` before any private content is needed.

## Re-running

Both scripts are idempotent. Each step checks before acting:

- step1 detects existing Homebrew and existing shellenv line, skips
  both.
- step2 detects existing Claude Code install, existing gh auth,
  existing how-I-work clone — skips each that's already done.

Safe to re-run anytime to recover from a partial install.
