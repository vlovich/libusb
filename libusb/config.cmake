include(CheckCXXCompilerFlag)
include(CheckIncludeFiles)
include(CheckTypeSize)
include(FindThreads)

if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	check_cxx_compiler_flag("-fvisibility=hidden" HAVE_VISIBILITY)
	check_cxx_compiler_flag("-Wno-pointer-sign" HAVE_WARN_NO_POINTER_SIGN)

	set(_GNU_SOURCE 1 CACHE INTERNAL "" FORCE)

	unset(ADDITIONAL_CC_FLAGS)

	if (HAVE_VISIBILITY)
		list(APPEND ADDITIONAL_CC_FLAGS -fvisibility=hidden)
	endif()

	if (HAVE_WARN_NO_POINTER_SIGN)
		list(APPEND ADDITIONAL_CC_FLAGS -Wno-pointer-sign)
	endif()

	append_compiler_flags(
		-std=gnu99
		-Wall
		-Wundef
		-Wunused
		-Wstrict-prototypes
		-Werror-implicit-function-declaration
		-Wshadow
		${ADDITIONAL_CC_FLAGS}
	)
else(MSVC)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	append_compiler_flags(/Wp64)
endif()

check_include_files(sys/timerfd.h USBI_TIMERFD_AVAILABLE)
check_type_size(struct timespec STRUCT_TIMESPEC)

if (CMAKE_USE_PTHREADS_INIT)
	set(THREADS_POSIX TRUE CACHE INTERNAL "use pthreads" FORCE)
endif()

if (HAVE_VISIBILITY)
	set(DEFAULT_VISIBILITY "__attribute__((visibility(\"default\")))" CACHE INTERNAL "visibility attribute to function decl" FORCE)
else()
	set(DEFAULT_VISIBILITY "" CACHE INTERNAL "visibility attribute to function decl" FORCE)
endif()

check_include_files(poll.h HAVE_POLL_H)
if (HAVE_POLL_H)
	list(APPEND CMAKE_EXTRA_INCLUDE_FILES "poll.h")
	check_type_size(nfds_t NFDS_T)
	unset(CMAKE_EXTRA_INCLUDE_FILES)
endif()

if (HAVE_NFDS_T)
	set(POLL_NFDS_TYPE nfds_t CACHE INTERNAL "the poll nfds types for this platform" FORCE)
else()
	set(POLL_NFDS_TYPE "unsigned int" CACHE INTERNAL "the poll nfds for this platform" FORCE)
endif()

if (OS_WINDOWS)
	option(WITH_ENUM_DEBUG "enable enumeration debugging (windows only)" false)

	macro(copy_header_if_missing HEADER VARIABLE ALTERNATIVE_DIR)
		check_include_files(${HEADER} ${VARIABLE})
		if (NOT ${VARIABLE})
			message(STATUS "Missing ${HEADER} - grabbing from ${ALTERNATIVE_DIR}")
			file(COPY "${ALTERNATIVE_DIR}/${HEADER}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/")
		endif()
	endmacro()

	# Only VS 2010 has stdint.h
	copy_header_if_missing(stdint.h HAVE_STDINT_H ../msvc)
	copy_header_if_missing(inttypes.h HAVE_INTTYPES_H ../msvc)
endif()

set(ENABLE_DEBUG_LOGGING ${WITH_DEBUG_LOG} CACHE INTERNAL "enable debug logging (WITH_DEBUG_LOGGING)" FORCE)
set(ENABLE_LOGGING ${WITH_LOGGING} CACHE INTERNAL "enable logging (WITH_LOGGING)" FORCE)
set(ENUM_DEBUG ${WITH_ENUM_DEBUG} CACHE INTERNAL "Set to WITH_ENUM_DEBUG" FORCE)
set(PACKAGE "libusb" CACHE INTERNAL "The package name" FORCE)
set(PACKAGE_BUGREPORT "libusb-devel@lists.sourceforge.net" CACHE INTERNAL "Where to send bug reports" FORCE)
set(PACKAGE_VERSION "${LIBUSB_MAJOR}.${LIBUSB_MINOR}.${LIBUSB_MICRO}" CACHE INTERNAL "package version" FORCE)
set(PACKAGE_STRING "${PACKAGE} ${PACKAGE_VERSION}" CACHE INTERNAL "package string" FORCE)
set(PACKAGE_URL "http://www.libusb.org" CACHE INTERNAL "package url" FORCE)
set(PACKAGE_TARNAME "libusb" CACHE INTERNAL "tarball name" FORCE)
set(VERSION "${PACKAGE_VERSION}" CACHE INTERNAL "version" FORCE)

configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)
message(STATUS "Generated configuration file in ${CMAKE_CURRENT_BINARY_DIR}/config.h")

# for generated config.h
include_directories(${CMAKE_CURRENT_BINARY_DIR})