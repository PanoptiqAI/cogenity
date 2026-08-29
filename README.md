# Cogenity — multi-account manager for Claude Code and Codex

Cogenity by PANOPTIQ is a vendor-neutral multi-account manager for Claude Code
and Codex. Use it to choose an account for each project or let it route a new
session by available capacity. Provider CLIs keep one active account at a time,
which makes account switching manual and easy to get wrong. Cogenity gives each
enrolled account isolated settings and credentials, then starts the provider
CLI with your chosen account or the highest-ranked account.

## Usage

```sh
cogenity                  # Pick a provider, account, or add another account
cogenity --codex          # Pick a Codex account
cogenity --account a@b.io # Start one enrolled account
cogenity --yolo           # Start with the provider's unsafe permission mode
```

A normal launch keeps the provider's permission checks unless `YOLO=1` is set.
Either `cogenity --yolo` or `YOLO=1` maps to Claude Code's
`--dangerously-skip-permissions` or Codex's `--yolo` flag.

AgentBox choices appear only in a repository with `agentbox.yaml` and Bun on
`PATH`. Local launches start in the current directory. AgentBox flows require
Bun. Other Cogenity flows do not.

## Getting started

Install the macOS standalone executable with Homebrew:

```sh
brew install PanoptiqAI/tap/cogenity
```

On Linux, or without Homebrew, use the install script:

```sh
curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/PanoptiqAI/cogenity/main/install.sh | sh
```

### Platform support

- macOS 13 or newer on arm64 or x86-64: supported.
- glibc Linux on arm64 or x86-64: experimental; smoke-tested on Debian arm64
  and x86-64.
- musl Linux: unsupported. The executable currently requires `libstdc++` and
  `libgcc`.
- Windows: unsupported.

Linux requires kernel 3.10 or newer; kernel 5.6 or newer is recommended. Linux
x86-64 processors require SSE4.2 (Intel Nehalem, AMD Bulldozer, or newer).

The script verifies the matching Cogenity release executable, then installs it
as `~/.local/bin/cogenity`. Cogenity includes its runtime and does not require a
separate Bun installation. Set `COGENITY_INSTALL_DIR` to choose another
directory. To inspect the script first, download it and run `sh install.sh`.

Install Claude Code, Codex, or both. Start Cogenity and choose **Add account**,
or enroll an account with a command:

```sh
cogenity
cogenity login claude you@example.com
cogenity doctor
```

Cogenity stores profiles under `~/.config/cogenity`. On macOS, Claude Code
credentials use the system Keychain. On Linux, credentials stay inside each
profile directory.

## Requirements

- Claude Code 2.1.144 or newer, Codex, or both must be on `PATH`.
- `git` is required only for AgentBox flows.

This repository contains the installer and generated release executables. It
does not publish the Cogenity TypeScript source or its repository history. The
executable format is not a source-secrecy boundary.

Cogenity is a PANOPTIQ product. It is not affiliated with, endorsed by, or
supported by Anthropic or OpenAI. Provider terms, account access, usage charges,
and actions taken in unsafe permission modes remain the user's responsibility.
The software is provided as-is, without warranty. Copyright PANOPTIQ AS. All
rights reserved. PANOPTIQ permits users to download and run this installer and
the official Cogenity executables. It grants no additional right to modify or
redistribute PANOPTIQ's code. Third-party components remain under their own
licenses. Each executable embeds Bun under Bun's own license.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for bundled software terms.
