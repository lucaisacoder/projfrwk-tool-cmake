function(is_path_component ret param_path)
    set(res 1)
    get_filename_component(abs_dir ${param_path} ABSOLUTE)

    if(NOT IS_DIRECTORY "${abs_dir}")
        message("${abs_dir} is not dir")
        set(res 0)
    endif()

    get_filename_component(base_dir ${abs_dir} NAME)
    string(SUBSTRING "${base_dir}" 0 1 first_char)

    if(NOT first_char STREQUAL ".")
        #message("${base_dir} not fc = .")
        if(NOT EXISTS "${abs_dir}/CMakeLists.txt")
            #message("${abs_dir}/CMakeLists.txt is not exists")
            set(res 0)
        endif()
        #message("212222222222222222222 COMPILE_UNIT_TEST = ${COMPILE_UNIT_TEST}")
        if(${COMPILE_UNIT_TEST} STREQUAL "UNIT_TEST")
            #message("22222222222222222222 COMPILE_UNIT_TEST = ${COMPILE_UNIT_TEST}")
            if(${base_dir} STREQUAL "code")
                set(res 0)
            endif()
        else()
            if(${base_dir} STREQUAL "unit_test")
                set(res 0)
            endif()
        endif()
    else()
        set(res 0)
    endif()

    set(${ret} ${res} PARENT_SCOPE)
endfunction()

function(get_python python version info_str)
    set(res 1)
    execute_process(COMMAND python3 --version RESULT_VARIABLE cmd_res OUTPUT_VARIABLE cmd_out)
    if(${cmd_res} EQUAL 0)
        set(${python} python3 PARENT_SCOPE)
        set(${version} 3 PARENT_SCOPE)
        set(${info_str} ${cmd_out} PARENT_SCOPE)
    else()
        execute_process(COMMAND python --version RESULT_VARIABLE cmd_res OUTPUT_VARIABLE cmd_out)
        if(${cmd_res} EQUAL 0)
            set(${python} python PARENT_SCOPE)
            set(${version} 2 PARENT_SCOPE)
            set(${info_str} ${cmd_out} PARENT_SCOPE)
        endif()
    endif()
endfunction(get_python python)

macro(project name)
    
    get_filename_component(current_dir ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
    set(PROJECT_SOURCE_DIR ${current_dir})
    set(PROJECT_BINARY_DIR "${current_dir}/build")

    # Find components in SDK's components folder, register components
    #file(GLOB component_dirs ${SDK_PATH}/components/*)
    #message("9999999999999999 SDK_PATH=${SDK_PATH} component_dirs=${component_dirs}")
    #foreach(component_dir ${component_dirs})
    #    is_path_component(is_component ${component_dir})
    #    #message("9999999999999999 is_component=${is_component} component_dir=${component_dir}")
    #    if(is_component)
    #        message(STATUS "Find component: ${component_dir}")
    #        get_filename_component(base_dir ${component_dir} NAME)
    #        list(APPEND components_dirs ${component_dir})
    #        if(EXISTS ${component_dir}/Kconfig)
    #            message(STATUS "Find component Kconfig of ${base_dir}")
    #            list(APPEND components_kconfig_files ${component_dir}/Kconfig)
    #        endif()
    #        if(EXISTS ${component_dir}/config_defaults.mk)
    #            message(STATUS "Find component defaults config of ${base_dir}")
    #            list(APPEND kconfig_defaults_files_args --defaults "${component_dir}/config_defaults.mk")
    #        endif()
    #    endif()
    #endforeach()

    # Find components in project folder
    file(GLOB project_component_dirs ${PROJECT_SOURCE_DIR}/*)
    message("9999999999999999 PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}  project_component_dirs=${project_component_dirs}")
    foreach(component_dir ${project_component_dirs})
        is_path_component(is_component ${component_dir})
        #message("9999999999999999 is_component=${is_component} component_dir=${component_dir}")
        if(is_component)
            message(STATUS "find component: ${component_dir}")
            get_filename_component(base_dir ${component_dir} NAME)
            list(APPEND components_dirs ${component_dir})
            message("00000000000000000 base_dir=${base_dir}")
            #if(${COMPILE_UNIT_TEST} STREQUAL "UNIT_TEST")
                if(${base_dir} STREQUAL "code")
                    set(code_component 1)
                endif()
            #else()
                if(${base_dir} STREQUAL "unit_test")
                    set(code_component 1)
                endif()
            #endif()
            if(EXISTS ${component_dir}/Kconfig)
                message(STATUS "Find component Kconfig of ${base_dir}")
                list(APPEND components_kconfig_files ${component_dir}/Kconfig)
            endif()
            if(EXISTS ${component_dir}/config_defaults.mk)
                message(STATUS "Find component defaults config of ${base_dir}")
                list(APPEND kconfig_defaults_files_args --defaults "${component_dir}/config_defaults.mk")
            endif()
        endif()
    endforeach()
    if(NOT code_component)
        message(FATAL_ERROR "=================\nCan not find code component(folder) in project folder!!\n=================")
    endif()

    # Find default config file
    if(DEFAULT_CONFIG_FILE)
        message(STATUS "Project defaults config file:${DEFAULT_CONFIG_FILE}")
        list(APPEND kconfig_defaults_files_args --defaults "${DEFAULT_CONFIG_FILE}")
    else()
        if(EXISTS ${PROJECT_SOURCE_DIR}/config_defaults.mk)
            message(STATUS "Find project defaults config(config_defaults.mk)")
            list(APPEND kconfig_defaults_files_args --defaults "${PROJECT_SOURCE_DIR}/config_defaults.mk")
        endif()
        if(EXISTS ${PROJECT_SOURCE_DIR}/.config.mk)
            message(STATUS "Find project defaults config(config.mk)")
            list(APPEND kconfig_defaults_files_args --defaults "${PROJECT_SOURCE_DIR}/.config.mk")
        endif()
    endif()

    # Generate config file from Kconfig
    get_python(python python_version python_info_str)
    if(NOT python)
        message(FATAL_ERROR "python not found, please install python firstly(python3 recommend)!")
    endif()
    message(STATUS "python command: ${python}, version: ${python_info_str}")
    string(REPLACE ";" " " components_kconfig_files "${kconfig_defaults_files_args}")
    string(REPLACE ";" " " components_kconfig_files "${components_kconfig_files}")
    set(generate_config_cmd ${python}  ${SDK_PATH}/tools/kconfig/genconfig.py
                            --kconfig "${SDK_PATH}/tools/kconfig/Kconfig"
                            ${kconfig_defaults_files_args}
                            --menuconfig False
                            --env "SDK_PATH=${SDK_PATH}"
                            --env "PROJECT_PATH=${PROJECT_SOURCE_DIR}"
                            --output makefile ${PROJECT_BINARY_DIR}/config/global_config.mk
                            --output cmake  ${PROJECT_BINARY_DIR}/config/global_config.cmake
                            --output header ${PROJECT_BINARY_DIR}/config/global_config.h
                            )
    set(generate_config_cmd2 ${python}  ${SDK_PATH}/tools/kconfig/genconfig.py
                            --kconfig "${SDK_PATH}/tools/kconfig/Kconfig"
                            ${kconfig_defaults_files_args}
                            --menuconfig True
                            --env "SDK_PATH=${SDK_PATH}"
                            --env "PROJECT_PATH=${PROJECT_SOURCE_DIR}"
                            --output makefile ${PROJECT_BINARY_DIR}/config/global_config.mk
                            --output cmake  ${PROJECT_BINARY_DIR}/config/global_config.cmake
                            --output header ${PROJECT_BINARY_DIR}/config/global_config.h
                            )
    execute_process(COMMAND ${generate_config_cmd} RESULT_VARIABLE cmd_res)
    if(NOT cmd_res EQUAL 0)
        message(FATAL_ERROR "Check Kconfig content")
    endif()

    # Include confiurations
    set(global_config_dir "${PROJECT_BINARY_DIR}/config")
    include(${global_config_dir}/global_config.cmake)
    if(WIN32)
        set(EXT ".exe")
    else()
        set(EXT "")
    endif()

    # Config toolchain
    if(CONFIG_TOOLCHAIN_PATH)
        if(WIN32)
            file(TO_CMAKE_PATH ${CONFIG_TOOLCHAIN_PATH} CONFIG_TOOLCHAIN_PATH)
        endif()
        if(NOT IS_DIRECTORY ${CONFIG_TOOLCHAIN_PATH})
            message(FATAL_ERROR "TOOLCHAIN_PATH set error:${CONFIG_TOOLCHAIN_PATH}")
        endif()
        set(TOOLCHAIN_PATH ${CONFIG_TOOLCHAIN_PATH})
        message(STATUS "TOOLCHAIN_PATH:${CONFIG_TOOLCHAIN_PATH}")
        set(CMAKE_C_COMPILER "${CONFIG_TOOLCHAIN_PATH}/${CONFIG_TOOLCHAIN_PREFIX}gcc${EXT}")
        set(CMAKE_CXX_COMPILER "${CONFIG_TOOLCHAIN_PATH}/${CONFIG_TOOLCHAIN_PREFIX}g++${EXT}")
        set(CMAKE_ASM_COMPILER "${CONFIG_TOOLCHAIN_PATH}/${CONFIG_TOOLCHAIN_PREFIX}gcc${EXT}")
        set(CMAKE_LINKER "${CONFIG_TOOLCHAIN_PATH}/${CONFIG_TOOLCHAIN_PREFIX}ld${EXT}")
    else()
        set(CMAKE_C_COMPILER "gcc${EXT}")
        set(CMAKE_CXX_COMPILER "g++${EXT}")
        set(CMAKE_ASM_COMPILER "gcc${EXT}")
        set(CMAKE_LINKER  "ld${EXT}")
    endif()

    set(CMAKE_C_COMPILER_WORKS 1)
    set(CMAKE_CXX_COMPILER_WORKS 1)

    
    set(CMAKE_SYSTEM_NAME Generic) 

    # Declare project # This function will cler flags!
    _project(${name} ASM C CXX)
    
    include(${SDK_PATH}/tools/cmake/util/compile_flags.cmake)

    # Add dependence: update configfile, append time and git info for global config header file
    # we didn't generate build info for cmake and makefile for if we do, it will always rebuild cmake
    # everytime we execute make
    set(gen_build_info_config_cmd ${python}  ${SDK_PATH}/tools/kconfig/update_build_info.py
                                  --configfile header ${PROJECT_BINARY_DIR}/config/global_build_info_time.h ${PROJECT_BINARY_DIR}/config/global_build_info_version.h
                                  )
    add_custom_target(update_build_info COMMAND ${gen_build_info_config_cmd})

    # Create exe_src.c to satisfy cmake's `add_executable` interface!
    set(exe_src ${CMAKE_BINARY_DIR}/exe_src.c)
    #message("33333333333333 name=${name}")
    if(${COMPILE_UNIT_TEST} STREQUAL "UNIT_TEST")
        set(name_output ${name}_ut)
        add_executable(${name_output} "${exe_src}")
        message("name_output ====== ${name_output}")
        add_custom_command(OUTPUT ${exe_src} COMMAND ${CMAKE_COMMAND} -E touch ${exe_src} VERBATIM)
        #add_custom_target(gen_exe_src DEPENDS "${exe_src}")
        #add_dependencies(${name_output} gen_exe_src)
        INSTALL(FILES build/${name_output} DESTINATION bin/ut/)
    else()
        set(name_output ${name})
        set(name_output_lib "lib${name}.a")
        #add_library(${name_output} "${exe_src}")
        INSTALL(DIRECTORY code/inc_pub/ DESTINATION include/${name_output} FILES_MATCHING PATTERN "*.h")
        #message("FILES build/code/libcode.a DESTINATION lib/${name_output_lib}")
        INSTALL(FILES build/code/${name_output_lib} DESTINATION lib)
    endif()
    

    
    # Sort component according to priority.conf config file
    #set(component_priority_conf_file "${PROJECT_PATH}/compile/priority.conf")
    #set(sort_components ${python}  ${SDK_PATH}/tools/cmake/sort_components.py
    #                               ${component_priority_conf_file} ${components_dirs}
    #                    )
    #execute_process(COMMAND ${sort_components} OUTPUT_VARIABLE component_dirs_sorted RESULT_VARIABLE cmd_res)
    #if(cmd_res EQUAL 2)
    #    message(STATUS "No components priority config file")
    #    set(component_dirs_sorted ${components_dirs})
    #elseif(cmd_res EQUAL 0)
    #    message(STATUS "Config components priority success")
    #else()
    #    message(STATUS "Components priority config fail ${component_dirs_sorted}, check config file:${component_priority_conf_file}")
    #endif()

    # Call CMakeLists.txt
    message("====================== components_dirs = ${components_dirs}")
    foreach(component_dir ${components_dirs})
        get_filename_component(base_dir ${component_dir} NAME)
        message("11111111111111 ${component_dir} ${base_dir}")
        add_subdirectory(${component_dir} ${base_dir}) # deadloop
        if(TARGET ${base_dir})
            add_dependencies(${base_dir} update_build_info) # add build info dependence
        else()
            message(STATUS "component ${base_dir} not enabled")
        endif()
    endforeach()
    

    # Add menuconfig target for makefile
    add_custom_target(menuconfig COMMAND ${generate_config_cmd2})

    # Add code component(lib)
    if(${COMPILE_UNIT_TEST} STREQUAL "UNIT_TEST")
        target_link_libraries(${name_output} unit_test)
    endif()

    # Add binary
    include("${SDK_PATH}/tools/cmake/util/gen_binary.cmake")

endmacro()