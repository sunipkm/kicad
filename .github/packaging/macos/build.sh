#!/bin/bash
# Build a target of kicad-mac-builder (prepare.sh): kicad-build-deps or kicad.
set -euo pipefail

src=$(cd "$(dirname "$0")/../../.." && pwd)
target=$1

if [ "$target" = kicad ]; then
    # What `git describe` shows as KiCad's version.
    git -C "$src" -c user.name=build -c user.email=build@localhost \
        tag -f -a "${KICAD_VERSION}-${REFRESH}" -m "${KICAD_VERSION}-${REFRESH}"
    export CCACHE_DIR=~/ccache CCACHE_MAXSIZE=2G CCACHE_COMPRESS=1
    export CCACHE_SLOPPINESS=pch_defines,time_macros,include_file_mtime,include_file_ctime
    export CMAKE_C_COMPILER_LAUNCHER=ccache CMAKE_CXX_COMPILER_LAUNCHER=ccache
    export CMAKE_PREFIX_PATH=$HOME/kmb/nng
    export CXXFLAGS="-Xclang -fno-pch-timestamp"
    mkdir -p "$CCACHE_DIR"
fi

# KiCad's builder uses wxPython's own doxygen, older than wxWidgets wants.
export WX_SKIP_DOXYGEN_VERSION_CHECK=1

# The runner's Homebrew libraries are built for its own macOS, so the app needs that one too.
cd ~/kmb/builder
./build.py --arch arm64 --macos-min-version 15.0 --build-dir ~/kmb/build --build-type Release \
    --kicad-source-dir "$src" --skip-docs-update --no-retry-failed-build \
    --symbols-ref "$KICAD_VERSION" --footprints-ref "$KICAD_VERSION" \
    --templates-ref "$KICAD_VERSION" --packages3d-ref "$KICAD_VERSION" \
    --target "$target"
