#!/usr/bin/env bash
# Clones the project repositories next to this script. Safe to re-run: existing
# clones are left untouched. Runs automatically on the host before the dev
# container starts (initializeCommand), so a plain "Reopen in Container" works.
set -euo pipefail

UPSTREAM_OWNER="OpenCarControls"
REPOS=(contracts firmware mobile-app)

usage() {
    cat <<EOF
Usage: ./setup.sh [--fork OWNER] [--ssh | --https]

  --fork OWNER  Clone OWNER/<repo> as "origin" and add $UPSTREAM_OWNER/<repo>
                as "upstream". Fork every repo you plan to push to first.
  --ssh         Clone over SSH.
  --https       Clone over HTTPS.

Without --ssh/--https, the protocol matches how this workspace repo was
cloned (HTTPS if it can't tell).
EOF
}

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fork_owner=""
protocol=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --fork) fork_owner="${2:?--fork needs an owner}"; shift 2 ;;
        --ssh) protocol="ssh"; shift ;;
        --https) protocol="https"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

if [[ -z "$protocol" ]]; then
    case "$(git -C "$root" remote get-url origin 2>/dev/null || true)" in
        git@*|ssh://*) protocol="ssh" ;;
        *) protocol="https" ;;
    esac
fi

repo_url() {
    if [[ "$protocol" == "ssh" ]]; then
        echo "git@github.com:$1/$2.git"
    else
        echo "https://github.com/$1/$2.git"
    fi
}

for repo in "${REPOS[@]}"; do
    dir="$root/$repo"
    if [[ -e "$dir/.git" ]]; then
        echo "✓ $repo already cloned"
        continue
    fi

    if [[ -n "$fork_owner" ]]; then
        echo "→ Cloning $fork_owner/$repo"
        git clone "$(repo_url "$fork_owner" "$repo")" "$dir"
        git -C "$dir" remote add upstream "$(repo_url "$UPSTREAM_OWNER" "$repo")"
    else
        echo "→ Cloning $UPSTREAM_OWNER/$repo"
        git clone "$(repo_url "$UPSTREAM_OWNER" "$repo")" "$dir"
    fi
done

# The nested contracts submodules are deliberately left uninitialized: inside
# the dev container, ./contracts is mounted over firmware/contracts and
# mobile-app/contracts so all three share one working copy.
for repo in firmware mobile-app; do
    if [[ -e "$root/$repo/contracts/.git" ]]; then
        echo "! $repo/contracts is an initialized submodule. Inside the dev container it is" >&2
        echo "  hidden behind the shared ./contracts mount, so edits made there won't be used." >&2
    fi
done
