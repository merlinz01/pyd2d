import pyd2d
import ctypes
from ctypes import wintypes
import sys

user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32

WNDPROCTYPE = ctypes.WINFUNCTYPE(
    wintypes.LPARAM, wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM
)


class WNDCLASSW(ctypes.Structure):
    _fields_ = [
        ("style", wintypes.UINT),
        ("lpfnWndProc", WNDPROCTYPE),
        ("cbClsExtra", ctypes.c_int),
        ("cbWndExtra", ctypes.c_int),
        ("hInstance", wintypes.HINSTANCE),
        ("hIcon", wintypes.HICON),
        ("hCursor", wintypes.HANDLE),
        ("hbrBackground", wintypes.HBRUSH),
        ("lpszMenuName", wintypes.LPCWSTR),
        ("lpszClassName", wintypes.LPCWSTR),
    ]


class POINT(ctypes.Structure):
    _fields_ = [
        ("x", wintypes.LONG),
        ("y", wintypes.LONG),
    ]


class PAINTSTRUCT(ctypes.Structure):
    _fields_ = [
        ("hdc", wintypes.HDC),
        ("fErase", wintypes.BOOL),
        ("rcPaint", wintypes.RECT),
        ("fRestore", wintypes.BOOL),
        ("fIncUpdate", wintypes.BOOL),
        ("rgbReserved", wintypes.BYTE * 32),
    ]


class MSG(ctypes.Structure):
    _fields_ = [
        ("hwnd", wintypes.HWND),
        ("message", wintypes.UINT),
        ("wParam", wintypes.WPARAM),
        ("lParam", wintypes.LPARAM),
        ("time", wintypes.DWORD),
        ("pt", POINT),
    ]


CW_USEDEFAULT = 0x80000000

SW_SHOWDEFAULT = 10

WM_CREATE = 0x0001
WM_DESTROY = 0x0002
WM_SIZE = 0x0005
WM_PAINT = 0x000F
WM_MOUSEMOVE = 0x0200
WM_LBUTTONDOWN = 0x0201
WM_LBUTTONUP = 0x0202

WS_OVERLAPPEDWINDOW = 0x00CF0000

hwnd2win = {}


class PyD2DDemoWindow:
    def __init__(self, hwnd):
        self.hwnd = hwnd
        pyd2d.InitializeCOM()
        factory = pyd2d.GetD2DFactory()
        rect = wintypes.RECT()
        user32.GetClientRect(self.hwnd, ctypes.byref(rect))
        width = rect.right - rect.left
        height = rect.bottom - rect.top
        self.render_target = factory.CreateHwndRenderTarget(
            int(self.hwnd), width, height
        )
        self.cursor = user32.LoadCursorW(None, ctypes.c_wchar_p(0x7F00))  # IDC_ARROW
        self.center = (50, 50)
        self.start = None

    def resize(self):
        rect = wintypes.RECT()
        user32.GetClientRect(self.hwnd, ctypes.byref(rect))
        width = rect.right - rect.left
        height = rect.bottom - rect.top
        self.render_target.Resize(width, height)

    def paint(self):
        rt = self.render_target
        rt.BeginDraw()
        rt.Clear(0.5, 0.5, 1.0)
        brush = rt.CreateSolidColorBrush(0.5, 1.0, 0.5)
        rt.FillEllipse(*self.center, 10, 10, brush)
        if self.start:
            brush = rt.CreateSolidColorBrush(1.0, 0.5, 0.5)
            rt.DrawLine(
                self.start[0],
                self.start[1],
                self.center[0],
                self.center[1],
                brush,
                5,
            )
        rt.EndDraw()

    def mouse_move(self, x, y):
        user32.SetCursor(self.cursor)
        self.center = (x, y)
        user32.InvalidateRect(self.hwnd, None, True)

    def mouse_down(self, x, y):
        self.start = (x, y)
        user32.SetCapture(self.hwnd)
        user32.InvalidateRect(self.hwnd, None, True)

    def mouse_up(self, x, y):
        self.start = None
        user32.ReleaseCapture()
        user32.InvalidateRect(self.hwnd, None, True)


@WNDPROCTYPE
def wnd_proc(hwnd, msg, wparam, lparam):
    if msg == WM_CREATE:
        win = PyD2DDemoWindow(hwnd)
        hwnd2win[hwnd] = win
        return 0
    if msg == WM_DESTROY:
        user32.PostQuitMessage(0)
        return 0
    win = hwnd2win.get(hwnd)
    if not win:
        return user32.DefWindowProcW(hwnd, msg, wparam, lparam)
    if msg == WM_SIZE:
        win.resize()
        return 0
    if msg == WM_PAINT:
        ps = PAINTSTRUCT()
        user32.BeginPaint(hwnd, ctypes.byref(ps))
        win.paint()
        user32.EndPaint(hwnd, ctypes.byref(ps))
        return 0
    if msg == WM_MOUSEMOVE:
        x = lparam & 0xFFFF
        y = (lparam >> 16) & 0xFFFF
        win.mouse_move(x, y)
        return 0
    if msg == WM_LBUTTONDOWN:
        x = lparam & 0xFFFF
        y = (lparam >> 16) & 0xFFFF
        win.mouse_down(x, y)
        return 0
    if msg == WM_LBUTTONUP:
        x = lparam & 0xFFFF
        y = (lparam >> 16) & 0xFFFF
        win.mouse_up(x, y)
        return 0
    return user32.DefWindowProcW(hwnd, msg, wparam, lparam)


def main():
    class_name = "PyD2DDemoWindowClass"

    wndclass = WNDCLASSW()
    wndclass.style = 0
    wndclass.lpfnWndProc = wnd_proc
    wndclass.cbClsExtra = 0
    wndclass.cbWndExtra = 0
    wndclass.hInstance = kernel32.GetModuleHandleW(None)
    wndclass.hIcon = None
    wndclass.hCursor = None
    wndclass.hbrBackground = None
    wndclass.lpszMenuName = None
    wndclass.lpszClassName = class_name

    atom = user32.RegisterClassW(ctypes.byref(wndclass))
    if not atom:
        print("Failed to register window class:", ctypes.FormatError())
        return 1

    hwnd = user32.CreateWindowExW(
        0,
        class_name,
        "PyD2D Demo Window",
        WS_OVERLAPPEDWINDOW,
        ctypes.c_int(CW_USEDEFAULT),
        ctypes.c_int(CW_USEDEFAULT),
        800,
        600,
        None,
        None,
        wndclass.hInstance,
        None,
    )
    if not hwnd:
        print("Failed to create window:", ctypes.FormatError())
        return 1

    user32.ShowWindow(hwnd, SW_SHOWDEFAULT)
    user32.UpdateWindow(hwnd)

    msg = MSG()
    while True:
        ret = user32.GetMessageW(ctypes.byref(msg), None, 0, 0)
        if ret == 0:
            break
        elif ret == -1:
            print("Failed to get window message:", ctypes.FormatError())
            break
        else:
            user32.TranslateMessage(ctypes.byref(msg))
            user32.DispatchMessageW(ctypes.byref(msg))

    return msg.wParam


if __name__ == "__main__":
    sys.exit(main())
