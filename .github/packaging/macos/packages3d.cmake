# Replaces kicad-mac-builder's packages3d.cmake: the models of the tag alone, in one copy. It
# clones the whole history and then copies the models twice, which a hosted runner's disk may not
# take.
set( packages3d_INSTALL_DIR ${CMAKE_BINARY_DIR}/packages3d/output )

ExternalProject_Add(
    packages3d
    PREFIX packages3d
    DOWNLOAD_COMMAND ${BIN_DIR}/fetch-packages3d.sh ${PACKAGES3D_TAG} ${packages3d_INSTALL_DIR}
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)
