import unittest

import pyd2d
import ctypes
from ctypes import wintypes

user32 = ctypes.windll.user32
CreateWindowExW = user32.CreateWindowExW
CreateWindowExW.argtypes = [
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
CreateWindowExW.restype = wintypes.HWND


def create_test_window(
    class_name: str = "BUTTON",
    window_name: str = "Test Window",
):
    hwnd = CreateWindowExW(
        0,
        class_name,
        window_name,
        0x80000000 | 0x40000000,
        0,
        0,
        0,
        0,
        None,
        None,
        None,
        None,
    )
    return hwnd


def destroy_test_window(hwnd):
    user32.DestroyWindow(hwnd)


class PyD2DTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        pyd2d.InitializeCOM()


class TestD2DFactory(PyD2DTest):
    def test_get_d2d_factory(self):
        factory = pyd2d.GetD2DFactory()
        self.assertIsInstance(factory, pyd2d.D2DFactory)

    def test_factory_create_hwnd_render_target(self):
        factory = pyd2d.GetD2DFactory()
        hwnd = create_test_window()
        render_target = factory.CreateHwndRenderTarget(
            hwnd=hwnd,
            width=100,
            height=100,
            presentOptions=pyd2d.PRESENT_OPTIONS.NONE,
            rtType=pyd2d.RENDER_TARGET_TYPE.DEFAULT,
            pixelFormat=pyd2d.DXGI_FORMAT.UNKNOWN,
            alphaMode=pyd2d.ALPHA_MODE.UNKNOWN,
            dpiX=96,
            dpiY=96,
            usage=pyd2d.RENDER_TARGET_USAGE.NONE,
            featureLevel=pyd2d.FEATURE_LEVEL.DEFAULT,
        )
        self.assertIsInstance(render_target, pyd2d.RenderTarget)
        destroy_test_window(hwnd)

    def test_factory_create_path_geometry(self):
        factory = pyd2d.GetD2DFactory()
        geometry = factory.CreatePathGeometry()
        self.assertIsInstance(geometry, pyd2d.PathGeometry)

    def test_factory_create_stroke_style(self):
        factory = pyd2d.GetD2DFactory()
        stroke_style = factory.CreateStrokeStyle(
            startCap=pyd2d.CAP_STYLE.FLAT,
            endCap=pyd2d.CAP_STYLE.FLAT,
            dashCap=pyd2d.CAP_STYLE.FLAT,
            lineJoin=pyd2d.LINE_JOIN.MITER,
            miterLimit=10.0,
            dashStyle=pyd2d.DASH_STYLE.SOLID,
            dashOffset=0.0,
        )
        self.assertIsInstance(stroke_style, pyd2d.StrokeStyle)


class TestDWriteFactory(PyD2DTest):
    def test_get_dwrite_factory(self):
        factory = pyd2d.GetDWriteFactory()
        self.assertIsInstance(factory, pyd2d.DWriteFactory)

    def test_factory_create_text_format(self):
        factory = pyd2d.GetDWriteFactory()
        text_format = factory.CreateTextFormat(
            familyName="Arial",
            size=12.0,
            weight=pyd2d.FONT_WEIGHT.NORMAL,
            style=pyd2d.FONT_STYLE.NORMAL,
            stretch=pyd2d.FONT_STRETCH.NORMAL,
        )
        self.assertIsInstance(text_format, pyd2d.TextFormat)

    def test_factory_create_text_layout(self):
        factory = pyd2d.GetDWriteFactory()
        text_layout = factory.CreateTextLayout(
            text="Hello, World!",
            textFormat=factory.CreateTextFormat("Arial", 12.0),
            maxWidth=100.0,
            maxHeight=100.0,
        )
        self.assertIsInstance(text_layout, pyd2d.TextLayout)


class TestBitmap(PyD2DTest):
    pass


class TestBrush(PyD2DTest):
    def setUp(self):
        self.factory = pyd2d.GetD2DFactory()
        self.window = create_test_window()
        self.render_target = self.factory.CreateHwndRenderTarget(self.window, 100, 100)

    def tearDown(self):
        destroy_test_window(self.window)

    def test_brush_get_opacity(self):
        brush = self.render_target.CreateSolidColorBrush(1, 1, 1, 1, 0.875)
        self.assertEqual(brush.GetOpacity(), 0.875)


class TestFontFace(PyD2DTest):
    pass


class TestGeometry(PyD2DTest):
    pass


class TestGeometrySink(PyD2DTest):
    def setUp(self):
        self.factory = pyd2d.GetD2DFactory()
        self.geometry = self.factory.CreatePathGeometry()
        self.sink = self.geometry.Open()

    def tearDown(self):
        self.sink.Close()

    def test_geometry_sink_add_arc(self):
        self.sink.BeginFigure(0.0, 0.0, pyd2d.FIGURE_BEGIN.FILLED)
        self.sink.AddArc(
            x=50.0,
            y=50.0,
            rx=50.0,
            ry=50.0,
            rotationAngle=0.0,
            sweepDirection=pyd2d.SWEEP_DIRECTION.CLOCKWISE,
            arcSize=pyd2d.ARC_SIZE.SMALL,
        )
        self.sink.EndFigure(pyd2d.FIGURE_END.OPEN)

    def test_geometry_sink_add_bezier(self):
        self.sink.BeginFigure(0.0, 0.0, pyd2d.FIGURE_BEGIN.FILLED)
        self.sink.AddBezier(x1=0.0, y1=0.0, x2=50.0, y2=50.0, x3=100.0, y3=100.0)
        self.sink.EndFigure(pyd2d.FIGURE_END.OPEN)

    def test_geometry_sink_add_line(self):
        self.sink.BeginFigure(0.0, 0.0, pyd2d.FIGURE_BEGIN.FILLED)
        self.sink.AddLine(100.0, 100.0)
        self.sink.EndFigure(pyd2d.FIGURE_END.OPEN)

    def test_geometry_sink_add_quadratic_bezier(self):
        self.sink.BeginFigure(0.0, 0.0, pyd2d.FIGURE_BEGIN.FILLED)
        self.sink.AddQuadraticBezier(x1=50.0, y1=50.0, x2=100.0, y2=100.0)
        self.sink.EndFigure(pyd2d.FIGURE_END.OPEN)


class TestHwndRenderTarget(PyD2DTest):
    def setUp(self):
        self.window = create_test_window()
        self.factory = pyd2d.GetD2DFactory()
        self.render_target = self.factory.CreateHwndRenderTarget(self.window, 100, 100)

    def tearDown(self):
        destroy_test_window(self.window)

    def test_hwnd_render_target_resize(self):
        self.render_target.Resize(width=200, height=200)


class TestImage(PyD2DTest):
    pass


class TestPathGeometry(PyD2DTest):
    def setUp(self):
        self.factory = pyd2d.GetD2DFactory()
        self.geometry = self.factory.CreatePathGeometry()

    def test_path_geometry_open_close(self):
        sink = self.geometry.Open()
        self.assertIsInstance(sink, pyd2d.GeometrySink)
        sink.Close()


class TestRenderTarget(PyD2DTest):
    def setUp(self):
        self.window = create_test_window()
        self.factory = pyd2d.GetD2DFactory()
        self.render_target = self.factory.CreateHwndRenderTarget(self.window, 100, 100)

    def tearDown(self):
        destroy_test_window(self.window)

    def test_render_target_begin_draw_end_draw(self):
        self.render_target.BeginDraw()
        self.render_target.EndDraw()

    def test_render_target_clear(self):
        self.render_target.BeginDraw()
        self.render_target.Clear(r=0.5, g=0.5, b=0.5, a=0.5)
        self.render_target.EndDraw()

    def test_render_target_create_solid_color_brush(self):
        brush = self.render_target.CreateSolidColorBrush(
            r=0.5, g=0.5, b=0.5, a=0.5, opacity=0.75
        )
        self.assertIsInstance(brush, pyd2d.Brush)
        self.assertEqual(brush.GetOpacity(), 0.75)

    def test_render_target_draw_bitmap(self):
        # TODO: Add WIC interface
        pass

    def test_render_target_draw_ellipse(self):
        self.render_target.BeginDraw()
        self.render_target.DrawEllipse(
            cx=50.0,
            cy=50.0,
            rx=50.0,
            ry=50.0,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
            strokeWidth=1.0,
            strokeStyle=self.factory.CreateStrokeStyle(),
        )
        self.render_target.EndDraw()

    def test_render_target_draw_geometry(self):
        geometry = self.factory.CreatePathGeometry()
        geometry.Open().Close()
        self.render_target.BeginDraw()
        self.render_target.DrawGeometry(
            geometry=geometry,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
            strokeWidth=1.0,
            strokeStyle=self.factory.CreateStrokeStyle(),
        )
        self.render_target.EndDraw()

    def test_render_target_draw_line(self):
        self.render_target.BeginDraw()
        self.render_target.DrawLine(
            x1=0.0,
            y1=0.0,
            x2=100.0,
            y2=100.0,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
            strokeWidth=1.0,
            strokeStyle=self.factory.CreateStrokeStyle(),
        )
        self.render_target.EndDraw()

    def test_render_target_draw_rectangle(self):
        self.render_target.BeginDraw()
        self.render_target.DrawRectangle(
            l=0.0,
            t=0.0,
            r=100.0,
            b=100.0,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
            strokeWidth=1.0,
            strokeStyle=self.factory.CreateStrokeStyle(),
        )
        self.render_target.EndDraw()

    def test_render_target_draw_text(self):
        self.render_target.BeginDraw()
        self.render_target.DrawText(
            text="Hello, World!",
            textFormat=pyd2d.GetDWriteFactory().CreateTextFormat("Arial", 12.0),
            l=0.0,
            t=0.0,
            r=100.0,
            b=100.0,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
            options=pyd2d.DRAW_TEXT_OPTIONS.NONE,
            measuringMode=pyd2d.MEASURING_MODE.NATURAL,
        )
        self.render_target.EndDraw()

    def test_render_target_draw_text_layout(self):
        self.render_target.BeginDraw()
        text_layout = pyd2d.GetDWriteFactory().CreateTextLayout(
            text="Hello, World!",
            textFormat=pyd2d.GetDWriteFactory().CreateTextFormat("Arial", 12.0),
            maxWidth=100.0,
            maxHeight=100.0,
        )
        self.render_target.DrawTextLayout(
            x=0.0,
            y=0.0,
            textLayout=text_layout,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
            options=pyd2d.DRAW_TEXT_OPTIONS.NONE,
        )
        self.render_target.EndDraw()

    def test_render_target_fill_ellipse(self):
        self.render_target.BeginDraw()
        self.render_target.FillEllipse(
            cx=50.0,
            cy=50.0,
            rx=50.0,
            ry=50.0,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
        )
        self.render_target.EndDraw()

    def test_render_target_fill_geometry(self):
        geometry = self.factory.CreatePathGeometry()
        geometry.Open().Close()
        self.render_target.BeginDraw()
        self.render_target.FillGeometry(
            geometry=geometry,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
        )
        self.render_target.EndDraw()

    def test_render_target_fill_rectangle(self):
        self.render_target.BeginDraw()
        self.render_target.FillRectangle(
            l=0.0,
            t=0.0,
            r=100.0,
            b=100.0,
            brush=self.render_target.CreateSolidColorBrush(1, 1, 1),
        )
        self.render_target.EndDraw()

    def test_render_target_get_transform(self):
        matrix = self.render_target.GetTransform()
        self.assertIsInstance(matrix, tuple)
        self.assertTupleEqual(matrix, (1.0, 0.0, 0.0, 1.0, 0.0, 0.0))

    def test_render_target_set_transform(self):
        self.render_target.SetTransform(0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
        matrix = self.render_target.GetTransform()
        self.assertTupleEqual(matrix, (0.5, 0.5, 0.5, 0.5, 0.5, 0.5))


class TestSimplifiedGeometrySink(PyD2DTest):
    def setUp(self):
        self.factory = pyd2d.GetD2DFactory()
        self.geometry = self.factory.CreatePathGeometry()
        self.sink = self.geometry.Open()

    def tearDown(self):
        self.sink.Close()

    def test_simplified_geometry_sink_begin_figure_end_figure(self):
        self.sink.BeginFigure(0.0, 0.0, pyd2d.FIGURE_BEGIN.FILLED)
        self.sink.EndFigure(pyd2d.FIGURE_END.OPEN)

    def test_simple_geometry_sink_set_fill_mode(self):
        self.sink.SetFillMode(pyd2d.FILL_MODE.ALTERNATE)


class TestSolidColorBrush(PyD2DTest):
    def setUp(self):
        self.window = create_test_window()
        self.factory = pyd2d.GetD2DFactory()
        self.render_target = self.factory.CreateHwndRenderTarget(self.window, 100, 100)
        self.brush = self.render_target.CreateSolidColorBrush(1, 1, 1)

    def tearDown(self):
        destroy_test_window(self.window)

    def test_solid_color_brush_set_color(self):
        self.brush.SetColor(r=0.5, g=0.5, b=0.5, a=0.5)


class TestStrokeStyle(PyD2DTest):
    pass


class TestTextFormat(PyD2DTest):
    pass


class TestTextLayout(PyD2DTest):
    def setUp(self):
        self.factory = pyd2d.GetDWriteFactory()
        self.text_layout = self.factory.CreateTextLayout(
            text="Hello, World!",
            textFormat=self.factory.CreateTextFormat("Arial", 12.0),
            maxWidth=100.0,
            maxHeight=100.0,
        )

    def test_text_layout_get_max_width(self):
        self.assertEqual(self.text_layout.GetMaxWidth(), 100.0)

    def test_text_layout_get_metrics(self):
        metrics = self.text_layout.GetMetrics()
        self.assertIsInstance(metrics, pyd2d.TEXT_METRICS)
        self.assertIsInstance(metrics.left, float)
        self.assertIsInstance(metrics.top, float)
        self.assertIsInstance(metrics.width, float)
        self.assertIsInstance(metrics.widthIncludingTrailingWhitespace, float)
        self.assertIsInstance(metrics.height, float)
        self.assertIsInstance(metrics.layoutWidth, float)
        self.assertIsInstance(metrics.layoutHeight, float)
        self.assertIsInstance(metrics.maxBidiReorderingDepth, int)
        self.assertIsInstance(metrics.lineCount, int)


if __name__ == "__main__":
    unittest.main()
