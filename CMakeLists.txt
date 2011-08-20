cmake_minimum_required(VERSION 2.6)

# Can be removed once CMake >= 2.8.4 is required
# this has to be set before the project directive
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

project(libusb)

include(CMakeDependentOption)

option(WITH_SHARED "Build a shared library" ON)
option(WITH_STATIC "Build a static library" OFF)
option(WITH_DOCS "Build the documentation" OFF)

option(WITH_DEBUG_LOG "enable debug logging" OFF)

# if debug logging is enabled, by default enable logging
cmake_dependent_option(WITH_LOGGING "if false, disable all logging" ON "WITH_DEBUG_LOG" OFF)

option(WITH_MAINTAINER_MODE "enable rules and dependencies not useful (and sometimes confusing) to the casual installer" OFF)

# enable examples by default if building with maintainer mode
cmake_dependent_option(WITH_EXAMPLES "build example applications" ON "WITH_MAINTAINER_MODE" OFF)

set(LIBUSB_MAJOR 1)
set(LIBUSB_MINOR 0)
set(LIBUSB_MICRO 8)

macro(append_compiler_flags)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ARGN}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARGN}")
endmacro()

if (WITH_DOCS)
	add_subdirectory(docs)
endif ()

add_subdirectory(libusb)
