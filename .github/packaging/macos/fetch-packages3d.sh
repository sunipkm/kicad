#!/bin/bash
# fetch-packages3d.sh <tag> <dir>: KiCad's 3D models of a tag into <dir>/3dmodels, as
# kicad-packages3D's own install lays them out, with the libraries' credits.
set -euo pipefail

tag=$1
out=$2/3dmodels
url=https://gitlab.com/kicad/libraries/kicad-packages3D/-/archive/$tag/kicad-packages3D-$tag.tar.gz

for try in 1 2 3 4; do
    rm -rf "$out"
    mkdir -p "$out"
    if curl -fsSL "$url" | tar -xz -f - -C "$out" --strip-components=1; then
        break
    elif [ "$try" = 4 ]; then
        exit 1
    fi
    sleep $((try * 20))
done

find "$out" -mindepth 1 -maxdepth 1 ! -name '*.3dshapes' -exec rm -rf {} +
find "$out" -type f ! -name '*.step' ! -name '*.md' -delete
echo "$(find "$out" -name '*.step' | wc -l) 3D models"
