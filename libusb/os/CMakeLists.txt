include(FindThreads)

set(PTHREADS_ENABLED FALSE)
if (CMAKE_USE_PTHREADS_INIT)
	set(PTHREADS_ENABLED TRUE)
endif()

if (WIN32 OR CMAKE_SYSTEM_NAME MATCHES "CYGWIN")
	set(OS_WINDOWS 1 CACHE INTERNAL "controls config.h macro definition" FORCE)

	if (CMAKE_SYSTEM_NAME MATCHES "CYGWIN")
		message(STATUS "Detected cygwin")
		set(PTHREADS_ENABLED TRUE)
	endif()

	set(PLATFORM_SRC
		poll_windows.c
		threads_windows.c
		windows_usb.c
	)
elseif (APPLE)
	# Apple != OSX alone
	set(OS_DARWIN 1 CACHE INTERNAL "controls config.h macro definition" FORCE)

	if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
		set(PLATFORM_SRC
			darwin_usb.c
			threads_posix.c
		)

		find_package(IOKit REQUIRED)
		list(APPEND LIBUSB_LIBRARIES ${IOKit_LIBRARIES})

		# Currently only objc_registerThreadWithCollector requires linking against it
		# which is only for MAC_OS_X_VERSION_MIN_REQUIRED >= 1060
		include(CheckCSourceCompiles)
		check_c_source_compiles(
"#include <AvailabilityMacros.h>
int main()
{
#if !(MAC_OS_X_VERSION_MIN_REQUIRED >= 1060)
#error \"Don't need objc\"
#endif
}
" NEED_OBJC_REGISTER_THREAD_WITH_COLLECTOR)

		if (NEED_OBJC_REGISTER_THREAD_WITH_COLLECTOR)
			find_library(LIBOBJC objc)
			if (NOT LIBOBJC)
				message(SEND_ERROR "Need objc library but can't find it")
			else()
				list(APPEND LIBUSB_LIBRARIES ${LIBOBJC})
			endif()
		endif()
	endif()
elseif (UNIX)
	# Unix is for all *NIX systems including OSX
	if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
		set(OS_LINUX 1 CACHE INTERNAL "controls config.h macro definition" FORCE)

		set(PLATFORM_SRC
			linux_usbfs.c
			threads_posix.c
		)

		list(APPEND LIBUSB_LIBRARIES rt)
	endif()
endif()

if (NOT PLATFORM_SRC)
	message(FATAL_ERROR "Unsupported platform ${CMAKE_SYSTEM_NAME}.  Currently only support Windows, OSX, & Linux.")
endif()

# the paths are relative to this directory but used in the parent directory,
# so we have to adjust the paths
foreach(SRC IN LISTS PLATFORM_SRC)
	list(APPEND LIBUSB_PLATFORM ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
endforeach()

# export one level up so that the generic
# libusb parts know what the platform bits are supposed to be
set(LIBUSB_PLATFORM ${LIBUSB_PLATFORM} PARENT_SCOPE)
set(LIBUSB_LIBRARIES ${LIBUSB_LIBRARIES} PARENT_SCOPE)

if (WITHOUT_PTHREADS)
	set(PTHREADS_ENABLED FALSE)
endif()
set(THREADS_POSIX ${PTHREADS_ENABLED} CACHE INTERNAL "use pthreads" FORCE)
