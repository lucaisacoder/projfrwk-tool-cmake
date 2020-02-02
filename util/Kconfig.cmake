





set(gen_kconfig_cmd ${python}  ${SDK_PATH}/tools/kconfig/genconfig.py
                        --kconfig "${SDK_PATH}/Kconfig"
                        ${kconfig_defaults_files_args}
                        --menuconfig True
                        --env "SDK_PATH=${SDK_PATH}"
                        --env "PROJECT_PATH=${PROJECT_SOURCE_DIR}"
                        --output makefile ${PROJECT_BINARY_DIR}/config/global_config.mk
                        --output cmake  ${PROJECT_BINARY_DIR}/config/global_config.cmake
                        --output header ${PROJECT_BINARY_DIR}/config/global_config.h
                        )






add_custom_target(menuconfig COMMAND ${gen_kconfig_cmd})