#!/bin/bash
# Build the patched KiCad as a .deb. Runs as root in a clean ubuntu:26.04 container:
#   docker run --rm -v <repo>:/src:ro -v <dir>:/out -v <dir>:/ccache \
#     -e VERSION=10.0.8+refresh1 ubuntu:26.04 bash /src/.github/packaging/linux/build-deb.sh
set -euo pipefail

: "${VERSION:?the package version, such as 10.0.8+refresh1}"
export DEBIAN_FRONTEND=noninteractive

apt-get update -q
apt-get install -yq --no-install-recommends build-essential devscripts equivs rsync

mkdir -p /work
rsync -a --exclude=/.git --exclude='/build*' --exclude=.gradle /src/ /work/kicad/
cp -r /src/.github/packaging/linux/debian /work/debian
cd /work

cat > debian/changelog <<CHANGELOG
kicad (${VERSION}) resolute; urgency=low

  * KiCad with the RefreshLibraries API command.

 -- KiCad RefreshLibraries build <noreply@localhost>  $(date -R)
CHANGELOG

mk-build-deps --install --remove \
    --tool 'apt-get -o Debug::pkgProblemResolver=yes -yq --no-install-recommends' debian/control

export CCACHE_DIR=/ccache CCACHE_MAXSIZE=2G CCACHE_BASEDIR=/work CCACHE_COMPRESS=1
export CCACHE_SLOPPINESS=pch_defines,time_macros,include_file_mtime,include_file_ctime
export CMAKE_C_COMPILER_LAUNCHER=ccache CMAKE_CXX_COMPILER_LAUNCHER=ccache

dpkg-buildpackage -b -uc -us ${JOBS:+-j"$JOBS"}
ccache --show-stats || true

cp /kicad_"${VERSION}"_amd64.deb /out/

# The package installs on a clean system, and runs.
apt-get install -yq --no-install-recommends ./../kicad_"${VERSION}"_amd64.deb
HOME=/tmp kicad-cli version --format about | tee /tmp/version
grep -qF "${VERSION/+/-}" /tmp/version
grep -qF RefreshLibraries /usr/lib/x86_64-linux-gnu/libkiapi.so* /usr/lib/libkiapi.so* 2>/dev/null
