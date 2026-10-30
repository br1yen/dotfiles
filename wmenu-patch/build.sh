#!/bin/sh
set -e
here="$(dirname "$(readlink -f "$0")")"
src="${XDG_CACHE_HOME:-$HOME/.cache}/wmenu-src"

sudo pacman -S --needed wmenu meson ninja
rm -rf "$src"
git clone "$(pacman -Qi wmenu | awk '/^URL/{print $3}')" "$src"
cd "$src"
git apply "$here/border.patch"
meson setup build --prefix="$HOME/.local"
ninja -C build install
