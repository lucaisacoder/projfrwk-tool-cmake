if(EXISTS ${PROJECT_SOURCE_DIR}/config_defaults.mk)
    message(STATUS "Find project defaults config(config_defaults.mk)")
    list(APPEND kconfig_defaults_files_args --defaults "${PROJECT_SOURCE_DIR}/config_defaults.mk")
endif()
if(EXISTS ${PROJECT_SOURCE_DIR}/.config.mk)
    message(STATUS "Find project defaults config(config.mk)")
    list(APPEND kconfig_defaults_files_args --defaults "${PROJECT_SOURCE_DIR}/.config.mk")
endif()

set(gen_kconfig_cmd ${python}  ${SDK_SOURCE_DIR}/tools/kconfig/kconfig.py
        --kconfig "${CMAKE_SOURCE_DIR}/Kconfig"
        ${kconfig_defaults_files_args}
        --output makefile  ${PROJECT_BINARY_DIR}/config/global_config.mk
        --output cmake  ${PROJECT_BINARY_DIR}/config/global_config.cmake
        --output header ${PROJECT_BINARY_DIR}/config/global_config.h
        --menuconfig True
    )
add_custom_target(menuconfig COMMAND ${gen_kconfig_cmd})