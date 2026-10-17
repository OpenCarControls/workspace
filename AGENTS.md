# Agent rules

Rules for AI agents working across the whole project from this workspace. This repo holds no product code: it only clones the three project repos side by side and wires them together in one dev container. Each repo has its own `AGENTS.md` and `docs/`; read the relevant ones before changing that repo.

## Layout
*   `contracts/`: protobuf schemas and TOML metadata (BLE UUIDs, MQTT topics, car `meta.toml`). The single source of truth for the wire format.
*   `firmware/`: Rust firmware (ESP32, PC and Raspberry Pi boards).
*   `mobile-app/`: Flutter companion app.

Each directory is its own git repo with its own CI and releases. This workspace repo ignores them.

## Rules

### The shared contracts working copy
*   Inside the dev container, `firmware/contracts` and `mobile-app/contracts` are bind mounts of `./contracts`. All three paths are the same files and the same git repo, so a schema edit is seen by both builds straight away.
*   Never run `git submodule update` (or `--init`, `--recursive`) inside `firmware/` or `mobile-app/`. It would check out that repo's pinned commit in the shared contracts working copy and throw away the state the other side is using.
*   Outside the dev container, the mounts don't exist and those two paths are empty; work from inside it.

### Cross-repo changes
For a change that touches the wire format:
1.  Change `contracts/` first, following its append-only rules, and run `buf format -w && buf lint` there.
2.  Update the firmware and the app against it; run both sides' checks (below).
3.  Commit each repo separately, in that repo, with conventional-commit messages. Contracts changes go in the contracts repo. In firmware and mobile-app, bump the submodule pin (`git add contracts`) in its own commit.
4.  A pin may only point to a contracts commit that is pushed. Otherwise that repo's CI can't check it out.

`git status` in firmware or mobile-app shows `contracts (new commits)` whenever `./contracts` is not on that repo's pinned commit. That is expected while iterating.

### Checks per repo
*   contracts: `buf format -w`, `buf lint`, `buf breaking --against '.git#branch=main'`.
*   firmware: `cargo xtask test` (host tests). Build with `cargo xtask build --board pc` or `--board esp`. On-hardware tests and flashing need a board attached; if none is, say so rather than claiming they pass.
*   mobile-app: `dart run build_runner build` after contracts changes, then `dart format` on non-generated files, `flutter analyze --fatal-infos` and `flutter test`.

Run commands from inside the repo they belong to.

### This repo
*   Keep `.devcontainer/Dockerfile` in sync with the toolchains in `firmware/.devcontainer/Dockerfile` and `mobile-app/.devcontainer/Dockerfile` when either changes.
*   Keep the firmware build tasks in `.vscode/tasks.json` in sync with `firmware/.vscode/tasks.json`: the generated debug configs use their labels as `preLaunchTask`.
*   Commits use conventional-commit style, like the other repos.
