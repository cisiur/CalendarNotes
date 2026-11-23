cmake_minimum_required(VERSION 3.14)
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")
include("${FLUTTER_MANAGED_DIR}/generated_config.cmake")

add_library(flutter_wrapper_plugin STATIC
  ephemeral/cpp_client_wrapper/core_implementations.cc
  ephemeral/cpp_client_wrapper/standard_codec.cc
)
target_include_directories(flutter_wrapper_plugin PUBLIC
  "${FLUTTER_MANAGED_DIR}"
  "${FLUTTER_MANAGED_DIR}/cpp_client_wrapper/include"
)
target_link_libraries(flutter_wrapper_plugin PUBLIC flutter)
add_dependencies(flutter_wrapper_plugin flutter_assemble)

add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE "${FLUTTER_MANAGED_DIR}")
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
add_dependencies(flutter flutter_assemble)

function(apply_standard_settings target)
  target_compile_features(${target} PUBLIC cxx_std_17)
  target_compile_definitions(${target} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_options(${target} PRIVATE /W4 /EHsc)
endfunction()

add_custom_command(
  OUTPUT "${FLUTTER_MANAGED_DIR}/flutter_windows.dll"
    "${FLUTTER_MANAGED_DIR}/flutter_windows.dll.lib"
    "${FLUTTER_MANAGED_DIR}/flutter_export.h"
    "${FLUTTER_MANAGED_DIR}/flutter_messenger.h"
    "${FLUTTER_MANAGED_DIR}/flutter_plugin_registrar.h"
    "${FLUTTER_MANAGED_DIR}/flutter_texture_registrar.h"
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.bat"
      windows-x64 ${CMAKE_BUILD_TYPE}
  VERBATIM
)
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_MANAGED_DIR}/flutter_windows.dll"
)
