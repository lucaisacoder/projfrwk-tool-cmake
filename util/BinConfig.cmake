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
#set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${REQ_LIBS_PATH})
#message("000000 CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${REQ_LIBS_PATH}")
set(CMAKE_PREFIX_PATH ${REQ_LIBS_PATH})
#message("0000000 CMAKE_PREFIX_PATH = ${CMAKE_PREFIX_PATH}")
set(REQ_LIBS_FOUND "")
foreach(lib ${REQ_LIBS})
  string(TOLOWER ${lib} LIB_LOWERCASE)
  string(TOUPPER ${lib} LIB_UPPERCASE)
  #message("debug: --- all libs : ${lib} ${LIB_LOWERCASE}")
  find_package(${LIB_LOWERCASE} REQUIRED)
  if(NOT ${LIB_LOWERCASE}_FOUND)
    message("ERROR: cannot found lib ${LIB_LOWERCASE}")
  else()
    list(APPEND REQ_LIBS_FOUND ${LIB_LOWERCASE})
    list(APPEND REQ_INC_FOUND ${${LIB_UPPERCASE}_INCLUDE_DIRS})
  endif()
endforeach()

include_directories(${DIR_INCS} ${REQ_INC_FOUND})
#message("REQ_INC_FOUND = ${REQ_INC_FOUND}")
add_definitions(${DEFINITION})
add_executable(${LIBRARY_NAME} ${SOURCES})
target_link_libraries(${LIBRARY_NAME} ${REQ_LIBS_FOUND})

# Install library
install(TARGETS ${LIBRARY_NAME}
  EXPORT ${PROJECT_EXPORT}
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT bin
  COMPONENT dev)
