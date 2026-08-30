# Cogenity for Claude Code and Codex

Cogenity by PANOPTIQ is a vendor-neutral multi-account manager for Claude Code
and Codex. It keeps each account's settings and credentials separate. Choose an
account for each project, or let Cogenity choose based on available capacity.

## Usage

After enrollment, replace these paths and emails with your own:

```sh
# Customer A: start Claude Code with the customer account
cd ~/work/customer-a
cogenity --claude --account developer@customer-a.example

# Private: start Claude Code with your private account
cd ~/code/private
cogenity --claude --account me@personal.example
```

Each command starts Claude Code in that project with the named account. Run
`cogenity` without flags to open the provider and account picker.

```sh
cogenity             # Pick or add an account
cogenity --codex     # Pick a Codex account
cogenity status      # Check account capacity
cogenity --yolo      # Use unsafe permission mode
```

Provider permission checks stay on by default. To turn them off, run
`cogenity --yolo` or set `YOLO=1`. Cogenity passes Claude Code
`--dangerously-skip-permissions` or Codex `--yolo`.

## Getting started

Install Claude Code 2.1.144 or newer, Codex, or both. Then install Cogenity and
enroll your accounts. Replace the example emails with your real login
addresses.

```sh
brew install PanoptiqAI/tap/cogenity
cogenity login claude developer@customer-a.example
cogenity login claude me@personal.example
cogenity doctor
```

You can also run `cogenity` and select **Add account**. On Linux, or without
Homebrew, use the installer:

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

The installer checks the release checksum and writes
`~/.local/bin/cogenity`. Set `COGENITY_INSTALL_DIR` to change the destination.
Local account and launch commands do not need a separate Bun installation.

Cogenity keeps profiles under `~/.config/cogenity`. On macOS, Claude Code uses
the system Keychain. On Linux, credentials stay inside each profile directory.

AgentBox choices appear only outside an AgentBox, in a repository with
`agentbox.yaml` and Bun on `PATH`. AgentBox flows also require `git`.

This repository contains the installer and release executables, not Cogenity's
TypeScript source or development history. Compiled executables can still be
inspected.

Cogenity is made by PANOPTIQ. It is not affiliated with, endorsed by, or
supported by Anthropic or OpenAI. You are responsible for complying with
provider terms, controlling account access, and paying usage charges. You are
also responsible for actions taken in unsafe mode.
The software is provided as-is, without warranty. Copyright PANOPTIQ AS. All
rights reserved. PANOPTIQ permits users to download and run this installer and
the official Cogenity executables. It grants no additional right to modify or
redistribute PANOPTIQ's code. Third-party components remain under their own
licenses. Each executable embeds Bun under Bun's own license.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for bundled software terms.
