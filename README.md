# firejail-claude-static-profile

A static [Firejail](https://github.com/netblue30/firejail) profile for running [Claude Code](https://claude.com/claude-code) in a hardened sandbox.

Follow-up to [marekrost/firejail-claude-dynamic-profile](https://github.com/marekrost/firejail-claude-dynamic-profile) — same goal, but a single declarative profile instead of a generator.

## Requirements

The following must be available in PATH:
- Firejail
- Claude Code

## Installation

Drop `claude.profile` into `~/.config/firejail/` and add an alias:

```sh
alias claude='firejail --profile=~/.config/firejail/claude.profile --whitelist="$(pwd)" ~/.local/bin/claude'
```

The `--whitelist="$(pwd)"` part grants the sandbox access to the current working directory at launch time. Firejail profiles are incapable of doing that statically as there is no `PWD` variable.

## What it does

- Drops all capabilities, blocks privilege escalation, applies seccomp.
- Private `/tmp`, `/dev`, and `/etc` (minimal allow-list).
- No D-Bus, no audio, no GPU, no supplementary groups.
- Restricts socket families to `unix,inet,inet6`.
- Spoofs hostname and machine-id, isolates IPC, prevents namespace creation.
- Whitelists only what Claude Code needs: `~/.claude`, `~/.claude.json`, the `claude` binary, Homebrew tools (`gh`, `mise`, `uv`), and developer runtime data dirs.

See `claude.profile` for the annotated rules.

## Caveats

- Uses `allusers` so `/home/linuxbrew` is visible. Safe on single-user hosts only — move Homebrew to `~/.linuxbrew` or `/opt` if you need stricter isolation.
- **Without SUID-root Firejail, two attack surfaces remain open:**
  - **X11 is reachable.** The sandbox inherits `DISPLAY` and the host's `/tmp/.X11-unix` socket, so a compromised Claude (e.g. via prompt injection or a malicious MCP server) can keylog every keystroke on the desktop, screenshot any window, and inject input into other apps via XTEST. `x11 none` requires SUID Firejail to take effect.
  - **The host network namespace is shared.** Any service the user runs on `127.0.0.1` (databases, dev servers, internal admin panels, model runners) is directly reachable from inside the sandbox. A private network namespace via `net default` and an in-namespace `netfilter` ruleset both require SUID Firejail.
- Claude's own credentials (`~/.claude.json`, `~/.config/gh/hosts.yml`) live inside the sandbox by design — the profile protects the host from Claude, not Claude from a tool-chain compromise. Treat those tokens as reachable to anything Claude can run.

## If you need stronger isolation

If the residual risks above are unacceptable for your threat model, consider [bubblewrap](https://github.com/containers/bubblewrap) (`bwrap`) instead. Bubblewrap is the unprivileged sandbox engine used by Flatpak — it relies on user namespaces rather than SUID, so it can do things this profile cannot without elevated privileges, including:

- Creating a private network namespace (`--unshare-net`) and re-adding only a loopback or veth interface.
- Skipping the X11 socket entirely (just don't bind-mount `/tmp/.X11-unix` and drop `DISPLAY`).
- Fine-grained per-path bind mounts instead of whitelist-style hole-punching.

The trade-off is verbosity: a bubblewrap setup is typically a wrapper script with explicit `--ro-bind` / `--bind` / `--tmpfs` flags rather than a declarative profile. If you go that route, the dynamic-profile predecessor linked above is a closer fit in spirit.

## License

MIT — see `LICENSE`.
