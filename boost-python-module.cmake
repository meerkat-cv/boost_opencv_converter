function(boost_python_module_py3 NAME)

    if(APPLE)
        set(BOOSTPY_LIB "boost_python3")
    else()
        find_library(BOOSTPY_LIB "boost_python-py35")
        if (NOT BOOSTPY_LIB)
            message("Boost python-py35 not found")
            find_library(BOOSTPY_LIB "boost_python3")
        endif()
        message("Boost python: " ${BOOSTPY_LIB})
    endif()

    message("Using boostpy_lib: " ${BOOSTPY_LIB} " ;")

    set(DEP_LIBS
        ${BOOSTPY_LIB}
        ${PYTHON_LIBRARIES}
        )
    #these are required includes for every ecto module
    include_directories(  )
    add_library(${NAME} SHARED  ${ARGN} )

    set_target_properties(${NAME}
        PROPERTIES
        OUTPUT_NAME ${NAME}
        COMPILE_FLAGS "${FASTIDIOUS_FLAGS}"
        LINK_FLAGS -dynamic
        PREFIX ""
        )

    if( WIN32 )
        set_target_properties(${NAME} PROPERTIES SUFFIX ".pyd")
    elseif( APPLE OR ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        # on mac osx, python cannot import libraries with .dylib extension
        set_target_properties(${NAME} PROPERTIES SUFFIX ".so")
    endif()

    target_link_libraries(${NAME} ${DEP_LIBS} )

endfunction()
