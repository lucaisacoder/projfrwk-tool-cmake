#install(EXPORT ${PROJECT_EXPORT}
#  DESTINATION ${INSTALL_CMAKE_DIR}
#  FILE ${PROJECT_NAME}Targets.cmake)

# Create the <package>config.cmake.in
configure_file(${SDK_SOURCE_DIR}/tools/cmake/config.cmake.in
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}Config.cmake" @ONLY)

# Create the <package>configversion.cmake.in
configure_file(${SDK_SOURCE_DIR}/tools/cmake/configversion.cmake.in
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}configversion.cmake" @ONLY)

# Install <package>config.cmake and <package>configversion.cmake files
install(FILES
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}config.cmake"
  "${PROJECT_CMAKE_FILES}/${PROJECT_NAME}configversion.cmake"
  DESTINATION "${INSTALL_CMAKE_DIR}" COMPONENT dev)

# Uninstall targets
configure_file("${SDK_SOURCE_DIR}/tools/cmake/uninstall.cmake.in"
  "${PROJECT_CMAKE_FILES}/uninstall.cmake"
  IMMEDIATE @ONLY)
add_custom_target(uninstall
  COMMAND ${CMAKE_COMMAND} -P ${PROJECT_CMAKE_FILES}/uninstall.cmake)