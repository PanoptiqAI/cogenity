# Cogenity

Cogenity by Panoptiq selects an enrolled Claude Code or Codex account, then
starts the provider CLI with that account's isolated settings and credentials.

## Install

The installer supports macOS 13 or newer and glibc- or musl-based Linux on
arm64 and x86-64. Linux requires kernel 3.10 or newer; kernel 5.6 or newer is
recommended. Linux x86-64 processors require SSE4.2 (Intel Nehalem, AMD
Bulldozer, or newer):

```sh
curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/PanoptiqAI/cogenity/main/install.sh | sh
```

The script verifies the Cogenity release and an official Bun 1.3.14 runtime,
then installs both under `~/.local/bin`. The `cogenity` wrapper remains the only
command you run. Set `COGENITY_INSTALL_DIR` to choose another directory. To
inspect the script first, download it and run `sh install.sh`.

## Use

Install at least one provider CLI, then enroll each account in a separate
Cogenity profile:

```sh
cogenity login claude you@example.com
cogenity login codex you@example.com
cogenity doctor
cogenity
```

A normal launch keeps the provider's permission checks. `cogenity --yolo`
explicitly maps to Claude Code's `--dangerously-skip-permissions` or Codex's
`--yolo` flag.

Cogenity stores profiles under `~/.config/cogenity`. On macOS, Claude Code
credentials use the system Keychain. On Linux, credentials stay inside each
profile directory.

AgentBox choices appear only in a repository with `agentbox.yaml` and Bun on
`PATH`. AgentBox and worktree setup require Bun. Other Cogenity flows do not.

## Requirements and support

- Claude Code 2.1.144 or newer, Codex, or both must be on `PATH`.
- `git` is required only for worktree flows.
- `unzip` is required during installation.
- Windows is not supported in this release.

This repository contains the installer and generated release bundle. It does
not publish the Cogenity TypeScript source or its repository history. The
generated bundle remains inspectable and is not a source-secrecy boundary.

Cogenity is a Panoptiq product. It is not affiliated with, endorsed by, or
supported by Anthropic or OpenAI. Provider terms, account access, usage charges,
and actions taken in unsafe permission modes remain the user's responsibility.
The software is provided as-is, without warranty. Copyright Panoptiq AS. All
rights reserved. Panoptiq permits users to download and run this installer and
the official Cogenity bundle. It grants no right to modify or redistribute that
bundle. Bun is downloaded separately under its own license.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for bundled software terms.
