set(LOG_INCLUDE_DIR ${SDK_PATH}/public/include/log")

find_library(LOG_LIBRARIES
    NAMES "liblog.a"
    HINTS "${SDK_PATH}/public/lib/*")

if(LOG_LIBRARIES)
    set(LOG_FOUND true)
    set(LOG_INCLUDE_DIRS ${LOG_INCLUDE_DIR})
endif()

