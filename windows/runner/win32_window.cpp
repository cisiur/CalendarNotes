#include "win32_window.h"

#include <windowsx.h>

namespace {
constexpr wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
}

Win32Window::Win32Window() = default;
Win32Window::~Win32Window() = default;

bool Win32Window::Create(const std::wstring& title, const Point& origin,
                         const Size& size) {
  WNDCLASS window_class = {};
  window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class.lpszClassName = kWindowClassName;
  window_class.style = CS_HREDRAW | CS_VREDRAW;
  window_class.lpfnWndProc = Win32Window::WndProc;
  RegisterClass(&window_class);

  const POINT adjusted_origin = {static_cast<LONG>(origin.x), static_cast<LONG>(origin.y)};
  RECT adjusted_rect = {adjusted_origin.x, adjusted_origin.y,
                        adjusted_origin.x + static_cast<LONG>(size.width),
                        adjusted_origin.y + static_cast<LONG>(size.height)};
  AdjustWindowRect(&adjusted_rect, WS_OVERLAPPEDWINDOW | WS_VISIBLE, FALSE);

  window_handle_ = CreateWindow(
      kWindowClassName, title.c_str(), WS_OVERLAPPEDWINDOW | WS_VISIBLE,
      adjusted_rect.left, adjusted_rect.top, adjusted_rect.right - adjusted_rect.left,
      adjusted_rect.bottom - adjusted_rect.top, nullptr, nullptr, GetModuleHandle(nullptr), this);
  return window_handle_ != nullptr;
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

RECT Win32Window::GetClientArea() {
  RECT rect = {};
  GetClientRect(window_handle_, &rect);
  return rect;
}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT rect = GetClientArea();
  MoveWindow(content, rect.left, rect.top, rect.right - rect.left,
             rect.bottom - rect.top, TRUE);
  SetFocus(content);
}

bool Win32Window::OnCreate() { return true; }
void Win32Window::OnDestroy() {}

LRESULT Win32Window::MessageHandler(HWND window, UINT const message,
                                    WPARAM const wparam,
                                    LPARAM const lparam) noexcept {
  switch (message) {
    case WM_SIZE:
      if (child_content_ != nullptr) {
        RECT rect = GetClientArea();
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                   rect.bottom - rect.top, TRUE);
      }
      return 0;
    case WM_CLOSE:
      DestroyWindow(window);
      return 0;
    case WM_DESTROY:
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;
  }
  return DefWindowProc(window, message, wparam, lparam);
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  Win32Window* that = nullptr;
  if (message == WM_NCCREATE) {
    auto* create_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    that = static_cast<Win32Window*>(create_struct->lpCreateParams);
    SetWindowLongPtr(window, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(that));
    that->window_handle_ = window;
  } else {
    that = reinterpret_cast<Win32Window*>(GetWindowLongPtr(window, GWLP_USERDATA));
  }
  if (that != nullptr) {
    if (message == WM_CREATE && !that->OnCreate()) {
      return -1;
    }
    const LRESULT result = that->MessageHandler(window, message, wparam, lparam);
    if (message == WM_NCDESTROY) {
      that->OnDestroy();
      that->window_handle_ = nullptr;
      SetWindowLongPtr(window, GWLP_USERDATA, 0);
    }
    return result;
  }
  return DefWindowProc(window, message, wparam, lparam);
}
