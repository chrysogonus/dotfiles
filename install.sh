#!/usr/bin/env bash
# Wire this repo into ~/.bashrc.  Safe to run repeatedly; re-run after moving
# the repo.  The stock distro ~/.bashrc stays in place and sources bash/bashrc
# as its last step.
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target=$repo/bash/bashrc
rc=${BASHRC:-$HOME/.bashrc}
marker='# dotfiles (managed by install.sh)'
legacy='Everything above this line is the stock Ubuntu file.'

[ -r "$target" ] || { echo "install: $target not found" >&2; exit 1; }

if [ ! -e "$rc" ]; then
    if [ -r /etc/skel/.bashrc ]; then cp /etc/skel/.bashrc "$rc"; else : > "$rc"; fi
fi

tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp.2"' EXIT
cp "$rc" "$tmp"

# One-time migration: the config used to live inline in ~/.bashrc under a
# banner comment.  Cut from that banner to the end of the file.
if n=$(grep -nF "$legacy" "$tmp" | head -n1 | cut -d: -f1) && [ -n "$n" ]; then
    start=$n
    if [ "$n" -gt 1 ] && sed -n "$((n - 1))p" "$tmp" | grep -qE '^# =+$'; then
        start=$((n - 1))
    fi
    head -n "$((start - 1))" "$tmp" > "$tmp.2" && mv "$tmp.2" "$tmp"
    echo "install: moved the inline config out of $rc"
fi

# Drop a previous managed block (marker line plus the source line after it),
# then trailing blank lines, and append a fresh one.
awk -v m="$marker" '$0 == m { skip = 2 } skip > 0 { skip--; next } { print }' "$tmp" |
    awk '{ line[NR] = $0 } /[^[:space:]]/ { last = NR }
         END { for (i = 1; i <= last; i++) print line[i] }' > "$tmp.2"
mv "$tmp.2" "$tmp"

path=$target
case "$path" in "$HOME"/*) path="\$HOME${path#"$HOME"}" ;; esac
printf '\n%s\n[ -r "%s" ] && . "%s"\n' "$marker" "$path" "$path" >> "$tmp"

if cmp -s "$tmp" "$rc"; then
    echo "install: $rc already sources $target"
else
    backup=$rc.bak.$(date +%Y%m%d-%H%M%S)
    cp -p "$rc" "$backup"
    cat "$tmp" > "$rc"          # write through a symlink, keep permissions
    echo "install: updated $rc (backup: $backup)"
fi

[ -e "$HOME/.bashrc.local" ] ||
    echo "install: optional ~/.bashrc.local is sourced last, for machine-specific settings"
echo "install: open a new shell, or run: source $rc"
