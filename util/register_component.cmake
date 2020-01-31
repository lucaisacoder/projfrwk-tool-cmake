message(STATUS "SDK_PATH:${SDK_PATH}")
include(${SDK_PATH}/tools/cmake/util/tools.cmake)

function(register_component)
    get_filename_component(component_dir ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
    get_filename_component(component_name ${component_dir} NAME)
    message(STATUS "[register component: ${component_name} ], path:${component_dir}")

    # Add src to lib
    message("************* component_name=${component_name}")
    if(ADD_SRCS)
        add_library(${component_name} STATIC ${ADD_SRCS})
        set(include_type PUBLIC)
    else()
        add_library(${component_name} INTERFACE)
        set(include_type INTERFACE)
    endif()

    # Add include
    foreach(include_dir ${ADD_INCLUDE})
        get_filename_component(abs_dir ${include_dir} ABSOLUTE BASE_DIR ${component_dir})
        if(NOT IS_DIRECTORY ${abs_dir})
            message(FATAL_ERROR "${CMAKE_CURRENT_LIST_FILE}: ${include_dir} not found!")
        endif()
        target_include_directories(${component_name} ${include_type} ${abs_dir})
    endforeach()

    # Add private include
    foreach(include_dir ${ADD_PRIVATE_INCLUDE})
        if(${include_type} STREQUAL INTERFACE)
            message(FATAL_ERROR "${CMAKE_CURRENT_LIST_FILE}: ADD_PRIVATE_INCLUDE set but no source file！")
        endif()
        get_filename_component(abs_dir ${include_dir} ABSOLUTE BASE_DIR ${component_dir})
        if(NOT IS_DIRECTORY ${abs_dir})
            message(FATAL_ERROR "${CMAKE_CURRENT_LIST_FILE}: ${include_dir} not found!")
        endif()
        target_include_directories(${component_name} PRIVATE ${abs_dir})
    endforeach()

    # Add blobal config include
    target_include_directories(${component_name} PUBLIC ${global_config_dir})

    # Add requirements
    target_link_libraries(${component_name} ${ADD_REQUIREMENTS})

    # Add definitions public
    foreach(difinition ${ADD_DEFINITIONS})
        target_compile_options(${component_name} PUBLIC ${difinition})
    endforeach()

    # Add definitions private
    foreach(difinition ${ADD_DEFINITIONS_PRIVATE})
        target_compile_options(${component_name} PRIVATE ${difinition})
    endforeach()

    # Add static lib
    if(ADD_STATIC_LIB)
        foreach(lib ${ADD_STATIC_LIB})
            if(NOT EXISTS "${lib}")
                prepend(lib_full "${component_dir}/" ${lib})
                if(NOT EXISTS "${lib_full}")
                    message(FATAL_ERROR "Can not find ${lib} or ${lib_full}")
                endif()
                set(lib ${lib_full})
            endif()
            target_link_libraries(${component_name} ${lib})
        endforeach()
    endif()
    #install(TARGETS ${component_name}
    #        LIBRARY DESTINATION ../lib
    #        ARCHIVE DESTINATION ../lib/static)

endfunction()