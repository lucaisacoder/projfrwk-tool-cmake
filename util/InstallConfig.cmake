# This "exports" all targets which have been put into the export set
install(EXPORT ${PROJECT_EXPORT}
  DESTINATION ${INSTALL_CMAKE_DIR}
  FILE ${PROJECT_NAME}Targets.cmake)

# Create the <package>Config.cmake.in
configure_file(${SDK_SOURCE_DIR}/tools/cmake/util/Config.cmake.in
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}Config.cmake" @ONLY)

# Create the <package>ConfigVersion.cmake.in
configure_file(${SDK_SOURCE_DIR}/tools/cmake/util/ConfigVersion.cmake.in
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}ConfigVersion.cmake" @ONLY)

# Install inc_pub header files.
file(GLOB inc_files 
  "${CMAKE_SOURCE_DIR}/code/inc_pub/*.h"
  "${CMAKE_SOURCE_DIR}/code/inc_pub/*.hpp"
  "${CMAKE_SOURCE_DIR}/code/inc_pub/*.hxx")
install(FILES ${inc_files} DESTINATION "${INSTALL_INCLUDE_DIR}")

# Install <package>Config.cmake and <package>ConfigVersion.cmake files
install(FILES
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}Config.cmake"
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION "${INSTALL_CMAKE_DIR}" COMPONENT dev)

# Uninstall targets
configure_file("${SDK_SOURCE_DIR}/tools/cmake/util/Uninstall.cmake.in"
  "${PROJECT_CMAKE_FILES}/Uninstall.cmake"
  IMMEDIATE @ONLY)
add_custom_target(uninstall
  COMMAND ${CMAKE_COMMAND} -P ${PROJECT_CMAKE_FILES}/Uninstall.cmake)
