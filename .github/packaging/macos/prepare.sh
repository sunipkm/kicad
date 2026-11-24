#!/bin/bash
# Fetch KiCad's macOS builder (MAC_BUILDER_COMMIT) into ~/kmb, adapt it to a hosted runner, and
# install what it needs from Homebrew. Its build directory is ~/kmb/build.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
mkdir -p ~/kmb/builder
cd ~/kmb/builder
git init -q
git fetch -q --depth 1 https://gitlab.com/kicad/packaging/kicad-mac-builder.git "$MAC_BUILDER_COMMIT"
git checkout -q FETCH_HEAD

# The libraries without their history, and the 3D models once on the disk (cp -c clones): it is
# small.
cp "$here/packages3d.cmake" kicad-mac-builder/packages3d.cmake
cp "$here/fetch-packages3d.sh" kicad-mac-builder/bin/
perl -0pi -e 's/cp -r (\$\{packages3d_INSTALL_DIR\})/cp -Rc $1/ or die' kicad-mac-builder/kicad.cmake
for lib in symbols footprints templates; do
    perl -0pi -e 's/(GIT_TAG \$\{\w+\})/$1\n    GIT_SHALLOW TRUE/ or die' "kicad-mac-builder/$lib.cmake"
done

# The build steps depend on some of these files: as old as can be, or a restored build directory
# would be built again.
find . -path ./.git -prune -o -type f -exec touch -t 200001010000 {} +

# --skip-docs-update takes the offline help from here; it is left out.
mkdir -p ~/kmb/build/docs/src/docs/share/doc/kicad/help

# wxPython's build runs a doxygen that only exists for x86-64.
softwareupdate --install-rosetta --agree-to-license || true

# shellcheck disable=SC1091
source ci/src/brew_deps.sh
export HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
brew install --quiet "${BREW_DEPS[@]}" ccache
df -h ~
