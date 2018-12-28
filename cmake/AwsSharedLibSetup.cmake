# Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#  http://aws.amazon.com/apache2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

option(VERSION_LIBS "Turns on versioning of shared libs, defaults to ON, you'll want to turn this off if you're building bindings and copying shared libs around." ON)

set(LIBRARY_DIRECTORY lib)
# Set the default lib installation path on GNU systems with GNUInstallDirs
if (UNIX AND NOT APPLE)
    include(GNUInstallDirs)
    set(LIBRARY_DIRECTORY ${CMAKE_INSTALL_LIBDIR})
endif()

function(aws_prepare_shared_lib_exports target)
    if (VERSION_LIBS)
        # Our ABI is not yet stable
        set_target_properties(${target} PROPERTIES VERSION 1.0.0)
        set_target_properties(${target} PROPERTIES SOVERSION 0unstable)
    endif()

    if (BUILD_SHARED_LIBS)
        install(TARGETS ${target}
                EXPORT ${target}-targets
                ARCHIVE
                DESTINATION ${LIBRARY_DIRECTORY}
                COMPONENT Development
                LIBRARY
                DESTINATION ${LIBRARY_DIRECTORY}
                NAMELINK_SKIP
                COMPONENT Runtime
                RUNTIME
                DESTINATION ${LIBRARY_DIRECTORY}
                COMPONENT Runtime)
        install(TARGETS ${target}
                EXPORT ${target}-targets
                LIBRARY
                DESTINATION ${LIBRARY_DIRECTORY}
                NAMELINK_ONLY
                COMPONENT Development)
    else()
        install(TARGETS ${target}
                EXPORT ${target}-targets
                ARCHIVE DESTINATION ${LIBRARY_DIRECTORY}
                COMPONENT Development)
    endif()
endfunction()

function(aws_prepare_symbol_visibility_args target lib_prefix)
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(${target} PUBLIC "-D${lib_prefix}_USE_IMPORT_EXPORT")
        target_compile_definitions(${target} PRIVATE "-D${lib_prefix}_EXPORTS")
    endif()
endfunction()