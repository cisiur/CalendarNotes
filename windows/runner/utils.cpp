#include "utils.h"

#include <fcntl.h>
#include <io.h>
#include <windows.h>

#include <shellapi.h>

#include <iostream>
#include <string>
#include <utility>
#include <vector>

std::vector<std::string> GetCommandLineArguments() {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return {};
  }

  std::vector<std::string> command_line_arguments;
  for (int i = 1; i < argc; i++) {
    int size_needed = ::WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, nullptr,
                                            0, nullptr, nullptr);
    std::string arg(size_needed - 1, 0);
    ::WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, arg.data(), size_needed,
                          nullptr, nullptr);
    command_line_arguments.push_back(std::move(arg));
  }
  ::LocalFree(argv);
  return command_line_arguments;
}

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE* unbuffered;
    if (freopen_s(&unbuffered, "CONOUT$", "w", stdout)) {
      return;
    }
    if (freopen_s(&unbuffered, "CONOUT$", "w", stderr)) {
      return;
    }
    if (freopen_s(&unbuffered, "CONIN$", "r", stdin)) {
      return;
    }
    std::ios::sync_with_stdio();
  }
}
