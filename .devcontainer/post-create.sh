#!/usr/bin/env bash
# Same first-run setup as the firmware and mobile-app dev containers, run from
# the workspace root.
set -euo pipefail

# Point rust-analyzer at the board selected in firmware/config.toml.
(cd firmware && cargo xtask ide)

cd mobile-app
flutter config --no-enable-linux-desktop
flutter pub get
cd web_3d
npm install
npm run build
