#!/usr/bin/env bash
# Copies the scripts into place without overwriting anything that already exists.
set -eu
cd "$(dirname "$0")"
mkdir -p ~/.local/bin ~/.local/share/sunshine-covers
cp -nv bin/* ~/.local/bin/
cp -nv covers/* ~/.local/share/sunshine-covers/
chmod +x ~/.local/bin/sunshine-res ~/.local/bin/sunshine-add
echo "Done. Set your monitor's normal settings at the top of ~/.local/bin/sunshine-res."
