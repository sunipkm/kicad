#!/bin/bash
# Put the built KiCad.app (build.sh kicad) into out/*.dmg, and check it.
set -euo pipefail

src=$(cd "$(dirname "$0")/../../.." && pwd)
dest=~/kmb/build/kicad-dest
app=$dest/KiCad.app

# Only the app is needed from here on.
rm -rf ~/kmb/build/packages3d/output ~/kmb/build/kicad/src/kicad-build
df -h ~

mkdir -p "$src/out"
hdiutil create -volname KiCad -srcfolder "$dest" -format ULFO -ov \
    "$src/out/kicad-${KICAD_VERSION}-${REFRESH}-macos-arm64.dmg"

# Nothing loaded from Homebrew or the build directory: those do not exist on another Mac.
bad=$(find "$app" -type f \( -name '*.dylib' -o -name '*.kiface' -o -path '*/MacOS/*' \) -print0 |
    xargs -0 otool -L 2>/dev/null | grep -E '^[[:space:]]+(/opt/homebrew|/usr/local|/Users)' | sort -u || true)
if [ -n "$bad" ]; then
    echo "::error::KiCad.app loads libraries from outside the app"
    echo "$bad"
    exit 1
fi

models=$(find "$app/Contents/SharedSupport/3dmodels" -name '*.step' | wc -l)
if [ "$models" -lt 7000 ]; then
    echo "::error::only $models 3D models in KiCad.app"
    exit 1
fi

codesign --verify --deep "$app"
"$app/Contents/MacOS/kicad-cli" version | tee /tmp/version
grep -qF "$KICAD_VERSION" /tmp/version
grep -rqF RefreshLibraries "$app/Contents/Frameworks"
