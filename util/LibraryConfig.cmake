# Select library type
#set(_PN ${PROJECT_NAME})
#option(BUILD_SHARED_LIBS "Build ${_PN} as a shared library." ON)
#if(BUILD_SHARED_LIBS)
#  set(LIBRARY_TYPE SHARED)
#else()
#  set(LIBRARY_TYPE STATIC)
#endif()

# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release'.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)

  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Target
set(CMAKE_PREFIX_PATH ${REQ_LIBS_PATH})
set(REQ_LIBS_FOUND "")
foreach(lib ${REQ_LIBS})
  string(TOLOWER ${lib} LIB_LOWERCASE)
  string(TOUPPER ${lib} LIB_UPPERCASE)
  #message("debug: --- find lib: ${lib}")

  find_package(${lib} REQUIRED)
  if(NOT ${lib}_FOUND)
    message("ERROR: cannot found lib ${lib}")
  else()
    foreach(sublib ${${LIB_UPPERCASE}_REQ_LIBRARIES})
      string(TOLOWER ${sublib} SUBLIB_LOWERCASE)
      string(TOUPPER ${sublib} SUBLIB_UPPERCASE)
      set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${${LIB_UPPERCASE}_REQ_LIBRARIES_PATH})
      find_package(${sublib} REQUIRED)
      if(NOT ${sublib}_FOUND)
        message("ERROR: cannot found lib ${sublib} for ${lib}")
      else()
        list(APPEND REQ_SUBLIBS_FOUND ${sublib})
        list(APPEND REQ_SUBINC_FOUND ${${SUBLIB_UPPERCASE}_INCLUDE_DIRS})
      endif()
    endforeach()

    list(APPEND REQ_LIBS_FOUND ${lib} ${REQ_SUBLIBS_FOUND})
    list(APPEND REQ_INC_FOUND ${${LIB_UPPERCASE}_INCLUDE_DIRS} ${REQ_SUBINC_FOUND})
  endif()
endforeach()

include_directories(${DIR_INCS} ${REQ_INC_FOUND})
add_definitions(${DEFINITION})
add_library(${LIBRARY_NAME} ${LIBRARY_TYPE} ${SOURCES})
target_link_libraries(${LIBRARY_NAME} ${REQ_LIBS_FOUND})

# Install library
install(TARGETS ${LIBRARY_NAME}
  EXPORT ${PROJECT_EXPORT}
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT bin
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT shlib
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}" COMPONENT stlib
  COMPONENT dev)

# Create 'version.h'
configure_file(${SDK_SOURCE_DIR}/tools/cmake/util/version.h.in
  "${CMAKE_CURRENT_BINARY_DIR}/version.h" @ONLY)
set(HEADERS ${DIR_INC_PUBS} ${CMAKE_CURRENT_BINARY_DIR}/version.h)

# Install headers
install(FILES ${HEADERS}
  DESTINATION "${INSTALL_INCLUDE_DIR}" )