set(gen_kconfig_cmd ${python}  ${SDK_SOURCE_DIR}/tools/kconfig/kconfig.py
                        --kconfig "${SDK_SOURCE_DIR}/tools/kconfig/Kconfig"
                        --menuconfig True
                        )
message("gen_kconfig_cmd ${python}  ${SDK_SOURCE_DIR}/tools/kconfig/kconfig.py
                        --kconfig "${SDK_SOURCE_DIR}/tools/kconfig/Kconfig"
                        --menuconfig True")
add_custom_target(menuconfig COMMAND ${gen_kconfig_cmd})