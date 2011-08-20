add_subdirectory(os)

include(config.cmake)

set (LIBUSB_COMMON
	core.c
	descriptor.c
	io.c
	sync.c
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/os)

message("LIBUSB_LIBRARIES=${LIBUSB_LIBRARIES}")
# The CLEAN_DIRECT_OUTPUT property setting can be removed once CMake >= 2.8.4
if (WITH_SHARED)
	add_library(usb-1.0
		SHARED
		${LIBUSB_COMMON}
		${LIBUSB_PLATFORM}
	)
	set_target_properties(usb-1.0 PROPERTIES
		CLEAN_DIRECT_OUTPUT 1
	)

	if (DEFINED LIBUSB_LIBRARIES)
		message("Linking shared library against ${LIBUSB_LIBRARIES}")
		target_link_libraries(usb-1.0
			${LIBUSB_LIBRARIES}
		)
	endif()
endif()

if (WITH_STATIC)
	add_library(usb-1.0-static
		STATIC
		${LIBUSB_COMMON}
		${LIBUSB_PLATFORM}
	)

	set_target_properties(usb-1.0-static PROPERTIES
		PREFIX "lib"
		OUTPUT_NAME "usb-1.0"
		CLEAN_DIRECT_OUTPUT 1
	)

	if (DEFINED LIBUSB_LIBRARIES)
		target_link_libraries(usb-1.0-static
			${LIBUSB_LIBRARIES}
		)
	endif()
endif()
