cmake_minimum_required(VERSION 3.2)

PROJECT (lib_boost_onpencv_converter)

if(APPLE)
	set(PYTHON_INCLUDE_DIRS
		"/usr/local/Cellar/python3/3.5.1/Frameworks/Python.framework/Versions/3.5/include/python3.5m")
	set(PYTHON_LIBRARIES
		"/usr/local/Cellar/python3/3.5.1/Frameworks/Python.framework/Versions/3.5/lib/libpython3.5.dylib")
else()
        find_package(PythonLibs 3 REQUIRED)
        message("python include dirs: " ${PYTHON_INCLUDE_DIRS})
        message("python libraries: " ${PYTHON_LIBRARIES})
endif()

find_package(Boost REQUIRED COMPONENTS python)

find_package(OpenCV 3.2.0 REQUIRED )

find_package(PkgConfig REQUIRED)
include(boost-python-module.cmake)


# I am assuming that the builds starts at build/ folder
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib/)
#set(lib_dest "${CMAKE_CURRENT_LIST_DIR}/lib/")
set(lib_dest "lib/meerkat")
set(include_dest "include/meerkat")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -std=c++1y -fPIC -O3")

if(APPLE)
	set(USE_AVX_INSTRUCTIONS true)
	set(NUMPY_INCLUDE_DIR "/usr/local/lib/python3.5/site-packages/numpy/core/include")
elseif(UNIX)
	set(USE_AVX_INSTRUCTIONS true)

    # Test for numpy
    find_package(PythonInterp 3 REQUIRED)
    if(PYTHONINTERP_FOUND)
       execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import numpy" OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE NUMPYRC)
       if(NUMPYRC EQUAL 1)
          message(WARNING "Numpy not found. Functions that return numpy arrays will throw exceptions!")
       else()
          message(STATUS "Found Python with installed numpy package")
          execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sys; from numpy import get_include; sys.stdout.write(get_include())" OUTPUT_VARIABLE NUMPY_INCLUDE_DIR)
          message(STATUS "Numpy include path '${NUMPY_INCLUDE_DIR}'")
          include_directories(${NUMPY_INCLUDE_DIR})
       endif()
    else()
       message(WARNING "Numpy not found. Functions that return numpy arrays will throw exceptions!")
       set(NUMPYRC 1)
    endif()

endif()


INCLUDE_DIRECTORIES("include/" ${PYTHON_INCLUDE_DIRS} ${NUMPY_INCLUDE_DIR})

file (GLOB all_converter_source
			src/*.cpp
                        include/*.hpp
                        include/*.h
                        )

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

# Creates the target library boost_opencv_converter.so
boost_python_module_py3(boost_opencv_converter ${all_converter_source})
target_link_libraries(boost_opencv_converter boost_system ${BOOSTPY_LIB} ${OpenCV_LIBS})

# TODO install configuration to put this libraries in the correct directory
install(TARGETS boost_opencv_converter DESTINATION "${lib_dest}")
install(FILES include/boost_opencv_converter.h DESTINATION "${include_dest}")
