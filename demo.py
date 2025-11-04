import ctypes
import itertools
import math
import random
import sys
import time
import traceback
from ctypes import wintypes

import pyd2d

user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32

HCURSOR = wintypes.HANDLE
LRESULT = wintypes.LPARAM
UINT_PTR = wintypes.WPARAM

WNDPROC = ctypes.WINFUNCTYPE(
    LRESULT, wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM
)


class WNDCLASSW(ctypes.Structure):
    _fields_ = [
        ("style", wintypes.UINT),
        ("lpfnWndProc", WNDPROC),
        ("cbClsExtra", ctypes.c_int),
        ("cbWndExtra", ctypes.c_int),
        ("hInstance", wintypes.HINSTANCE),
        ("hIcon", wintypes.HICON),
        ("hCursor", HCURSOR),
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
        ("lPrivate", wintypes.DWORD),
    ]


user32.BeginPaint.restype = wintypes.HDC
user32.BeginPaint.argtypes = [wintypes.HWND, ctypes.POINTER(PAINTSTRUCT)]

user32.CreateWindowExW.restype = wintypes.HWND
user32.CreateWindowExW.argtypes = [
    wintypes.DWORD,
    wintypes.LPCWSTR,
    wintypes.LPCWSTR,
    wintypes.DWORD,
    ctypes.c_int,
    ctypes.c_int,
    ctypes.c_int,
    ctypes.c_int,
    wintypes.HWND,
    wintypes.HMENU,
    wintypes.HINSTANCE,
    wintypes.LPVOID,
]

user32.DefWindowProcW.restype = LRESULT
user32.DefWindowProcW.argtypes = [
    wintypes.HWND,
    wintypes.UINT,
    wintypes.WPARAM,
    wintypes.LPARAM,
]

user32.DispatchMessageW.restype = LRESULT
user32.DispatchMessageW.argtypes = [ctypes.POINTER(MSG)]

user32.EndPaint.restype = wintypes.BOOL
user32.EndPaint.argtypes = [wintypes.HWND, ctypes.POINTER(PAINTSTRUCT)]

user32.GetClientRect.restype = wintypes.BOOL
user32.GetClientRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]

user32.GetMessageW.restype = wintypes.BOOL
user32.GetMessageW.argtypes = [
    ctypes.POINTER(MSG),
    wintypes.HWND,
    wintypes.UINT,
    wintypes.UINT,
]

kernel32.GetModuleHandleW.restype = wintypes.HMODULE
kernel32.GetModuleHandleW.argtypes = [wintypes.LPCWSTR]

user32.InvalidateRect.restype = wintypes.BOOL
user32.InvalidateRect.argtypes = [
    wintypes.HWND,
    ctypes.POINTER(wintypes.RECT),
    wintypes.BOOL,
]

user32.KillTimer.restype = wintypes.BOOL
user32.KillTimer.argtypes = [wintypes.HWND, UINT_PTR]

user32.LoadCursorW.restype = HCURSOR
user32.LoadCursorW.argtypes = [wintypes.HINSTANCE, wintypes.LPCWSTR]

user32.PostQuitMessage.restype = None
user32.PostQuitMessage.argtypes = [wintypes.INT]

user32.RegisterClassW.restype = wintypes.ATOM
user32.RegisterClassW.argtypes = [ctypes.POINTER(WNDCLASSW)]

user32.ReleaseCapture.restype = wintypes.BOOL
user32.ReleaseCapture.argtypes = []

user32.SetCapture.restype = wintypes.HANDLE
user32.SetCapture.argtypes = [wintypes.HWND]

user32.SetCursor.restype = HCURSOR
user32.SetCursor.argtypes = [HCURSOR]

user32.SetTimer.restype = UINT_PTR
user32.SetTimer.argtypes = [
    wintypes.HWND,
    UINT_PTR,
    wintypes.UINT,
    wintypes.LPVOID,
]

user32.ShowWindow.restype = wintypes.BOOL
user32.ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]

user32.TranslateMessage.restype = wintypes.BOOL
user32.TranslateMessage.argtypes = [ctypes.POINTER(MSG)]

user32.UnregisterClassW.restype = wintypes.BOOL
user32.UnregisterClassW.argtypes = [wintypes.LPCWSTR, wintypes.HINSTANCE]

user32.UpdateWindow.restype = wintypes.BOOL
user32.UpdateWindow.argtypes = [wintypes.HWND]


CW_USEDEFAULT = 0x80000000

IDC_ARROW = 32512
IDC_HAND = 32649

SW_SHOWDEFAULT = 10

WM_CREATE = 0x0001
WM_DESTROY = 0x0002
WM_SIZE = 0x0005
WM_PAINT = 0x000F
WM_TIMER = 0x0113
WM_MOUSEMOVE = 0x0200
WM_LBUTTONDOWN = 0x0201
WM_LBUTTONUP = 0x0202

WS_OVERLAPPEDWINDOW = 0x00CF0000


def check(v):
    if not v:
        raise OSError(ctypes.FormatError())
    return v


hwnd2win = {}


class PyD2DDemoWindow:
    def __init__(self, hwnd):
        self.hwnd = hwnd
        self.cursor_arrow = check(user32.LoadCursorW(None, ctypes.c_wchar_p(IDC_ARROW)))
        self.cursor_hand = check(user32.LoadCursorW(None, ctypes.c_wchar_p(IDC_HAND)))
        pyd2d.InitializeCOM()
        factory = pyd2d.GetD2DFactory()
        rect = wintypes.RECT()
        check(user32.GetClientRect(self.hwnd, ctypes.byref(rect)))
        self.width = rect.right - rect.left
        self.height = rect.bottom - rect.top
        self.render_target = factory.CreateHwndRenderTarget(
            int(self.hwnd), self.width, self.height
        )
        factory.Release()
        self.line_brush = self.render_target.CreateSolidColorBrush(1.0, 0.5, 0.5)
        self.text_brush = self.render_target.CreateSolidColorBrush(1.0, 1.0, 1.0, 0.5)
        check(user32.SetTimer(self.hwnd, 123, 10, None))
        dwritefactory = pyd2d.GetDWriteFactory()
        self.text_format = dwritefactory.CreateTextFormat("Segoe UI", 12)
        dwritefactory.Release()
        self.mouse_is_down = False
        self.balls = []  # type: list[Ball]
        for _ in range(10):
            ball = Ball(
                self.width / 2,
                self.height - 50,
                self.width,
                self.height,
                self.render_target.CreateSolidColorBrush(
                    random.random(), random.random(), random.random()
                ),
            )
            ball.dx = random.randint(-100, 100)
            ball.dy = random.randint(-300, -100)
            self.balls.append(ball)

    def destroy(self):
        check(user32.KillTimer(self.hwnd, 123))
        for ball in self.balls:
            ball.brush.Release()
        self.text_brush.Release()
        self.line_brush.Release()
        self.render_target.Release()
        pyd2d.UninitializeCOM()

    def resize(self):
        rect = wintypes.RECT()
        check(user32.GetClientRect(self.hwnd, ctypes.byref(rect)))
        self.width = rect.right - rect.left
        self.height = rect.bottom - rect.top
        self.render_target.Resize(self.width, self.height)
        for ball in self.balls:
            ball.width = self.width
            ball.height = self.height

    def paint(self):
        rt = self.render_target
        rt.BeginDraw()
        rt.Clear(0.25, 0.25, 0.5)
        rt.DrawLine(
            10,
            self.height - 40,
            self.width - 10,
            self.height - 40,
            self.line_brush,
            2,
        )
        if self.mouse_is_down:
            ball = self.balls[-1]
            rt.DrawLine(
                ball.sx,
                ball.sy,
                ball.x,
                ball.y,
                self.line_brush,
                5,
            )
        for ball in self.balls:
            rt.FillEllipse(ball.x, ball.y, 10, 10, ball.brush)
        if self.balls:
            ball = self.balls[-1]
            text = (
                "Last ball:\n"
                f" Position X: {ball.x:.02f}\n Position Y: {ball.y:.02f}\n"
                f" Speed X: {ball.dx:.02f}\n Speed Y: {ball.dy:.02f}\n"
                "Click and drag to throw balls."
            )
        else:
            text = "Click and drag to throw balls."
        rt.DrawText(text, self.text_format, 5, 5, 200, 200, self.text_brush)
        rt.EndDraw()

    def mouse_move(self, x, y):
        if self.mouse_is_down:
            self.balls[-1].x = x
            self.balls[-1].y = y
            check(user32.InvalidateRect(self.hwnd, None, False))
            user32.SetCursor(self.cursor_hand)
        else:
            user32.SetCursor(self.cursor_arrow)

    def mouse_down(self, x, y):
        ball = Ball(
            x,
            y,
            self.width,
            self.height,
            self.render_target.CreateSolidColorBrush(
                random.random(), random.random(), random.random()
            ),
        )
        self.balls.append(ball)
        self.mouse_is_down = True
        user32.SetCapture(self.hwnd)
        check(user32.InvalidateRect(self.hwnd, None, False))
        user32.SetCursor(self.cursor_hand)

    def mouse_up(self, x, y):
        if self.mouse_is_down:
            self.balls[-1].x = x
            self.balls[-1].y = y
            self.balls[-1].dx = x - self.balls[-1].sx
            self.balls[-1].dy = y - self.balls[-1].sy
        self.mouse_is_down = False
        check(user32.ReleaseCapture())
        check(user32.InvalidateRect(self.hwnd, None, False))
        user32.SetCursor(self.cursor_arrow)

    def timer(self):
        for i, ball in enumerate(self.balls):
            if self.mouse_is_down and i == len(self.balls) - 1:
                continue
            ball.timer()
        for a, b in itertools.combinations(self.balls, 2):
            dx = b.x - a.x
            dy = b.y - a.y
            dist = math.hypot(dx, dy)
            if dist < 20 and dist > 1e-12:
                # Normalized collision normal
                nx = dx / dist
                ny = dy / dist
                # Project velocities onto the collision normal
                pa = a.dx * nx + a.dy * ny
                pb = b.dx * nx + b.dy * ny
                # Exchange the normal components (elastic collision, equal mass)
                a.dx += (pb - pa) * nx
                a.dy += (pb - pa) * ny
                b.dx += (pa - pb) * nx
                b.dy += (pa - pb) * ny
                # Separate them so they don't overlap
                overlap = 20 - dist
                a.x -= 0.5 * overlap * nx
                a.y -= 0.5 * overlap * ny
                b.x += 0.5 * overlap * nx
                b.y += 0.5 * overlap * ny
                a.stopped_since = None
                b.stopped_since = None
        now = time.time()
        for ball in list(self.balls):
            if ball.stopped_since and now - ball.stopped_since > 10:
                ball.brush.Release()
                self.balls.remove(ball)
        check(user32.InvalidateRect(self.hwnd, None, False))


class Ball:
    speed_factor = 0.1
    gravity_factor = 2
    floor_air_resistance_factor = 2
    air_resistance_factor = 0.005

    def __init__(self, x, y, w, h, brush):
        self.sx = self.x = x
        self.sy = self.y = y
        self.dx = self.dy = 0
        self.height = h
        self.width = w
        self.brush = brush
        self.stopped_since = None  # type: float | None

    def timer(self):
        # Move along current trajectory
        self.x += self.dx * self.speed_factor
        self.y += self.dy * self.speed_factor
        # Pull of gravity
        self.dy += self.gravity_factor
        # Air resistance at floor
        self.dy -= self.floor_air_resistance_factor / max(self.height - self.y - 50, 1)
        # Air resistance
        self.dy -= self.dy * self.air_resistance_factor
        self.dx -= self.dx * self.air_resistance_factor
        if abs(self.dx) < 1:
            # Eventually stop
            self.dx = 0
        elif self.x < 10 or self.x > self.width - 10:
            # Bounce off side walls
            self.dx = -self.dx
        # Keep within side walls
        self.x = min(max(self.x, 10), self.width - 5)
        if self.y > self.height - 51 and abs(self.dy) < 5:
            # Eventually stop
            self.dy = 0
            self.y = self.height - 50
        elif self.y < 10 or self.y > self.height - 50:
            # Keep within floor and ceiling
            self.dy = -self.dy
            self.y = min(max(self.y, 10), self.height - 50)
        # Keep track of when stopped
        if self.dx == 0 and self.dy == 0 and not self.stopped_since:
            self.stopped_since = time.time()


def get_mouse_pos(lparam):
    x = lparam & 0xFFFF
    y = (lparam >> 16) & 0xFFFF
    if x > 0x8000:
        x -= 0x10000
    if y > 0x8000:
        y -= 0x10000
    return x, y


@WNDPROC
def wnd_proc(hwnd, msg, wparam, lparam):
    try:
        return wnd_proc_inner(hwnd, msg, wparam, lparam)
    except BaseException:
        traceback.print_exc()
        user32.PostQuitMessage(1)
        return 0


def wnd_proc_inner(hwnd, msg, wparam, lparam):
    if msg == WM_CREATE:
        win = PyD2DDemoWindow(hwnd)
        hwnd2win[hwnd] = win
        return 0
    win = hwnd2win.get(hwnd)
    if not win:
        return user32.DefWindowProcW(hwnd, msg, wparam, lparam)
    if msg == WM_DESTROY:
        user32.PostQuitMessage(0)
        win.destroy()
        hwnd2win.pop(hwnd, None)
        return 0
    if msg == WM_SIZE:
        win.resize()
        return 0
    if msg == WM_PAINT:
        ps = PAINTSTRUCT()
        check(user32.BeginPaint(hwnd, ctypes.byref(ps)))
        win.paint()
        user32.EndPaint(hwnd, ctypes.byref(ps))
        return 0
    if msg == WM_MOUSEMOVE:
        win.mouse_move(*get_mouse_pos(lparam))
        return 0
    if msg == WM_LBUTTONDOWN:
        win.mouse_down(*get_mouse_pos(lparam))
        return 0
    if msg == WM_LBUTTONUP:
        win.mouse_up(*get_mouse_pos(lparam))
        return 0
    if msg == WM_TIMER:
        win.timer()
        return 0
    return user32.DefWindowProcW(hwnd, msg, wparam, lparam)


def main():
    class_name = "PyD2DDemoWindowClass"

    wndclass = WNDCLASSW()
    wndclass.style = 0
    wndclass.lpfnWndProc = wnd_proc
    wndclass.cbClsExtra = 0
    wndclass.cbWndExtra = 0
    wndclass.hInstance = check(kernel32.GetModuleHandleW(None))
    wndclass.hIcon = None
    wndclass.hCursor = None
    wndclass.hbrBackground = None
    wndclass.lpszMenuName = None
    wndclass.lpszClassName = class_name

    check(user32.RegisterClassW(ctypes.byref(wndclass)))

    hwnd = check(
        user32.CreateWindowExW(
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
    )

    user32.ShowWindow(hwnd, SW_SHOWDEFAULT)
    check(user32.UpdateWindow(hwnd))

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

    check(user32.UnregisterClassW(class_name, wndclass.hInstance))

    return msg.wParam


if __name__ == "__main__":
    sys.exit(main())
