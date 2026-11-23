cmake_minimum_required(VERSION 3.14)
project(calendar_notes LANGUAGES CXX)

set(BINARY_NAME "calendar_notes")
cmake_policy(SET CMP0063 NEW)
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

add_subdirectory(flutter)
add_subdirectory(runner)

include(flutter/generated_plugins.cmake)
