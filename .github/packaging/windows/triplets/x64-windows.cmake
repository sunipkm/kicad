# vcpkg's x64-windows, release libraries only (half the build time), and cached whatever the
# runner image's compiler patch version is, as KiCad's own CI (tools/custom_vcpkg_triplets) does.
include( "${VCPKG_ROOT_DIR}/triplets/x64-windows.cmake" )

set( VCPKG_BUILD_TYPE release )
set( VCPKG_DISABLE_COMPILER_TRACKING ON )
