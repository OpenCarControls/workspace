# Open Car Workspace 🧰

A development workspace for working on the whole Open Car Controls project at once: [contracts](https://github.com/OpenCarControls/contracts), [firmware](https://github.com/OpenCarControls/firmware) and [mobile-app](https://github.com/OpenCarControls/mobile-app) side by side, in one dev container with every toolchain.

This repo holds no product code and pins no versions. The three repos stay independent, each with its own CI and releases. If you only work on one of them, clone it directly and use its own dev container.

## 🚀 Getting Started

1.  Clone this repo and open it in VS Code:
    ```sh
    git clone https://github.com/OpenCarControls/workspace.git OpenCarControls
    code OpenCarControls
    ```
2.  Run **Dev Containers: Reopen in Container**. Before the container starts, `setup.sh` clones any missing repo next to this README.

VS Code's Source Control view lists each repo separately.

### Working from forks

Fork the repos you want to push to, then run the setup yourself before opening the container:

```sh
./setup.sh --fork <your-github-user>
```

Each repo is cloned from your fork as `origin`, with `OpenCarControls/<repo>` added as `upstream`. Use `--ssh` or `--https` to choose the protocol; by default it matches how you cloned this repo.

## 🔗 One Shared Contracts Copy

Firmware and the app both consume `contracts` as a git submodule. Inside the dev container, `./contracts` is bind-mounted over `firmware/contracts` and `mobile-app/contracts`, so all three paths are the same working copy:

*   Edit a `.proto` or TOML file once; both the firmware and the app build against it immediately, with no commit or fetch.
*   `git status` in firmware or the app shows `contracts (new commits)` while `./contracts` differs from that repo's pin. Commit `contracts` there to bump the pin once the contracts change is pushed.
*   Don't run `git submodule update` inside firmware or the app: it would check out their pinned commit in the shared copy.

Outside the container the mounts don't exist, so the two submodule paths stay empty.

## 🧱 What's in the Container

*   Rust with every firmware target (PC, Raspberry Pi, ESP32 RISC-V and Xtensa), `protoc`, espflash and probe-rs, plus USB access for flashing.
*   Flutter (the version in `mobile-app/.flutter-version`), the Android SDK and `protoc-gen-dart` for the app.
*   `buf` for the contracts, and Node for the app's 3D viewer.

Which firmware board rust-analyzer analyses comes from `firmware/config.toml`. Switch it with `cargo xtask ide` in `firmware/`, or the **Firmware IDE** tasks. Here it writes the rust-analyzer settings and the **Firmware: debug …** config to this folder's `.vscode/`, since that's VS Code's workspace root (see the firmware README).

## 🤖 AI Agents

`AGENTS.md` (loaded by `CLAUDE.md`) describes the layout and the cross-repo workflow. Each repo's own `AGENTS.md` still applies inside that repo.
