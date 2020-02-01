set(OSAL_PATH ${SDK_PATH}/components/osal)
set(OSAL_INSALL_PATH ${SDK_PATH}/public)
set(OSAL_INCLUDE_DIR ${OSAL_INSALL_PATH}/include/osal)

find_library(OSAL_LIBRARIES
    NAMES "libosal.a"
    HINTS "${OSAL_INSALL_PATH}/lib/*")

if(OSAL_LIBRARIES)
    set(OSAL_FOUND true)
    set(OSAL_INCLUDE_DIRS ${OSAL_INCLUDE_DIR})
endif()

