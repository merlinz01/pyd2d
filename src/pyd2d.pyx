# cython: language_level=3
# cython: freethreading_compatible=True

include "_pyd2d_const.pyi"
from libc.stdint cimport int32_t, uint32_t, uint64_t, intptr_t
from libc.stddef cimport wchar_t
from cpython.mem cimport PyMem_Free

cdef extern from *:
    """
    #define UNICODE
    #define _UNICODE
    """
    wchar_t* PyUnicode_AsWideCharString(object unicode, Py_ssize_t *size)
    object PyUnicode_FromWideChar(wchar_t *wstr, Py_ssize_t size)

cdef extern from "windows.h":
    ctypedef int32_t HRESULT
    ctypedef uint32_t ULONG
    ctypedef void* HWND
    ctypedef uint32_t UINT32
    ctypedef float FLOAT
    ctypedef uint64_t UINT64
    ctypedef uint32_t UINT
    ctypedef wchar_t WCHAR

    ctypedef struct GUID:
        unsigned long Data1
        unsigned short Data2
        unsigned short Data3
        unsigned char Data4[8]

    unsigned int FormatMessageW(
        unsigned long dwFlags,
        void *lpSource,
        unsigned long dwMessageId,
        unsigned long dwLanguageId,
        wchar_t* lpBuffer,
        unsigned long nSize,
        void *Arguments) noexcept nogil
    bint SUCCEEDED(HRESULT hr) noexcept nogil
    bint FAILED(HRESULT hr) noexcept nogil

cdef extern from "objbase.h":
    HRESULT CoInitializeEx(
        void* pvReserved,
        unsigned long dwCoInit) noexcept nogil
    void CoUninitialize() noexcept nogil

    cdef cppclass IUnknown:
        void Release() noexcept nogil

cdef extern from "dwrite.h":
    """
    #define IID_IDWriteFactory __uuidof(IDWriteFactory)
    """
    ctypedef int DWRITE_FACTORY_TYPE
    ctypedef int DWRITE_FONT_STYLE
    ctypedef int DWRITE_FONT_WEIGHT
    ctypedef int DWRITE_FONT_STRETCH

    ctypedef struct DWRITE_TEXT_METRICS:
        FLOAT  left
        FLOAT  top
        FLOAT  width
        FLOAT  widthIncludingTrailingWhitespace
        FLOAT  height
        FLOAT  layoutWidth
        FLOAT  layoutHeight
        UINT32 maxBidiReorderingDepth
        UINT32 lineCount

    cdef GUID IID_IDWriteFactory

    cdef cppclass IDWriteTextLayout:
        FLOAT GetMaxWidth() noexcept nogil
        HRESULT GetMetrics(DWRITE_TEXT_METRICS *textMetrics) noexcept nogil
    cdef cppclass IDWriteFactory:
        HRESULT CreateTextFormat(
            const WCHAR *family_name,
            IDWriteFontCollection *collection,
            DWRITE_FONT_WEIGHT weight,
            DWRITE_FONT_STYLE style,
            DWRITE_FONT_STRETCH stretch,
            FLOAT size,
            const WCHAR *locale,
            IDWriteTextFormat **format) noexcept nogil
        HRESULT CreateTextLayout(
            WCHAR *string,
            UINT32 stringLength,
            IDWriteTextFormat *textFormat,
            FLOAT maxWidth,
            FLOAT maxHeight,
            IDWriteTextLayout **textLayout) noexcept nogil
    cdef cppclass IDWriteFontCollection
    cdef cppclass IDWriteTextFormat

    HRESULT DWriteCreateFactory(
        DWRITE_FACTORY_TYPE factoryType,
        const GUID& iid, IUnknown** factory) noexcept nogil


cdef extern from "d2d1.h":
    ctypedef int D2D1_DEBUG_LEVEL
    ctypedef int D2D1_FACTORY_TYPE
    ctypedef int D2D1_RENDER_TARGET_TYPE
    ctypedef int DXGI_FORMAT
    ctypedef int D2D1_ALPHA_MODE
    ctypedef int D2D1_RENDER_TARGET_USAGE
    ctypedef int D2D1_FEATURE_LEVEL
    ctypedef int D2D1_PRESENT_OPTIONS
    ctypedef int D2D1_CAP_STYLE
    ctypedef int D2D1_LINE_JOIN
    ctypedef int D2D1_DASH_STYLE
    ctypedef int D2D1_SWEEP_DIRECTION
    ctypedef int D2D1_ARC_SIZE
    ctypedef int D2D1_FILL_MODE
    ctypedef int D2D1_ANTIALIAS_MODE
    ctypedef int D2D1_BITMAP_INTERPOLATION_MODE
    ctypedef int D2D1_DRAW_TEXT_OPTIONS
    ctypedef int DWRITE_MEASURING_MODE
    ctypedef int D2D1_FIGURE_BEGIN
    ctypedef int D2D1_FIGURE_END

    ctypedef struct D2D1_FACTORY_OPTIONS:
        D2D1_DEBUG_LEVEL debugLevel
    ctypedef struct D2D1_PIXEL_FORMAT:
         DXGI_FORMAT     format
         D2D1_ALPHA_MODE alphaMode
    ctypedef struct D2D1_RENDER_TARGET_PROPERTIES:
         D2D1_RENDER_TARGET_TYPE  type
         D2D1_PIXEL_FORMAT        pixelFormat
         float                    dpiX
         float                    dpiY
         D2D1_RENDER_TARGET_USAGE usage
         D2D1_FEATURE_LEVEL       minLevel
    ctypedef struct D2D1_SIZE_U:
        UINT32 width
        UINT32 height
    ctypedef struct D2D1_HWND_RENDER_TARGET_PROPERTIES:
       HWND                 hwnd
       D2D1_SIZE_U          pixelSize
       D2D1_PRESENT_OPTIONS presentOptions
    ctypedef struct D3DCOLORVALUE:
        float r
        float g
        float b
        float a
    ctypedef D3DCOLORVALUE D2D1_COLOR_F
    ctypedef struct D2D1_MATRIX_3X2_F:
        float m11
        float m12
        float m21
        float m22
        float dx
        float dy
    ctypedef struct D2D1_BRUSH_PROPERTIES:
        FLOAT             opacity
        D2D1_MATRIX_3X2_F transform
    ctypedef struct D2D1_RECT_F:
        float left
        float top
        float right
        float bottom
    ctypedef UINT64 D2D1_TAG
    ctypedef struct D2D1_STROKE_STYLE_PROPERTIES:
        D2D1_CAP_STYLE  startCap
        D2D1_CAP_STYLE  endCap
        D2D1_CAP_STYLE  dashCap
        D2D1_LINE_JOIN  lineJoin
        FLOAT           miterLimit
        D2D1_DASH_STYLE dashStyle
        FLOAT           dashOffset
    ctypedef struct D2D1_POINT_2F:
        float x
        float y
    ctypedef struct D2D1_BEZIER_SEGMENT:
        D2D1_POINT_2F point1
        D2D1_POINT_2F point2
        D2D1_POINT_2F point3
    ctypedef struct D2D1_SIZE_F:
        float width
        float height
    ctypedef struct D2D1_ARC_SEGMENT:
        D2D1_POINT_2F        point
        D2D1_SIZE_F          size
        FLOAT                rotationAngle
        D2D1_SWEEP_DIRECTION sweepDirection
        D2D1_ARC_SIZE        arcSize
    ctypedef struct D2D1_QUADRATIC_BEZIER_SEGMENT:
        D2D1_POINT_2F point1
        D2D1_POINT_2F point2
    ctypedef struct D2D1_ELLIPSE:
        D2D1_POINT_2F point
        FLOAT         radiusX
        FLOAT         radiusY
    ctypedef struct D2D1_BITMAP_PROPERTIES:
        D2D1_PIXEL_FORMAT pixelFormat
        FLOAT             dpiX
        FLOAT             dpiY

    cdef cppclass ID2D1Bitmap
    cdef cppclass ID2D1Brush:
        FLOAT GetOpacity() noexcept nogil
    cdef cppclass ID2D1PathGeometry:
        HRESULT Open(ID2D1GeometrySink **geometrySink) noexcept nogil
    cdef cppclass ID2D1StrokeStyle
    cdef cppclass ID2D1Factory:
        HRESULT CreateHwndRenderTarget(
            const D2D1_RENDER_TARGET_PROPERTIES *renderTargetProperties,
            const D2D1_HWND_RENDER_TARGET_PROPERTIES *hwndRenderTargetProperties,
            ID2D1HwndRenderTarget **hwndRenderTarget) noexcept nogil
        HRESULT CreatePathGeometry(ID2D1PathGeometry **pathGeometry) noexcept nogil
        HRESULT CreateStrokeStyle(
            const D2D1_STROKE_STYLE_PROPERTIES *strokeStyleProperties,
            const FLOAT *dashes,
            UINT dashesCount,
            ID2D1StrokeStyle **strokeStyle) noexcept nogil
    cdef cppclass ID2D1Geometry
    cdef cppclass ID2D1GeometrySink:
        void AddArc(const D2D1_ARC_SEGMENT *arc) noexcept nogil
        void AddBezier(const D2D1_BEZIER_SEGMENT *bezier) noexcept nogil
        void AddLine(D2D1_POINT_2F point) noexcept nogil
        void AddQuadraticBezier(const D2D1_QUADRATIC_BEZIER_SEGMENT *bezier) noexcept nogil
        void BeginFigure(D2D1_POINT_2F startPoint, D2D1_FIGURE_BEGIN figureBegin) noexcept nogil
        HRESULT Close() noexcept nogil
        void EndFigure(D2D1_FIGURE_END figureEnd) noexcept nogil
        void SetFillMode(D2D1_FILL_MODE fillMode) noexcept nogil
    cdef cppclass ID2D1HwndRenderTarget:
        HRESULT Resize(const D2D1_SIZE_U *pixelSize) noexcept nogil
    cdef cppclass ID2D1RenderTarget:
        void BeginDraw() noexcept nogil
        void Clear(const D2D1_COLOR_F *clearColor) noexcept nogil
        HRESULT CreateBitmapFromWicBitmap(
            IWICBitmapSource *wicBitmapSource,
            const D2D1_BITMAP_PROPERTIES *bitmapProperties,
            ID2D1Bitmap **bitmap) noexcept nogil
        HRESULT CreateSolidColorBrush(
            const D2D1_COLOR_F *color,
            const D2D1_BRUSH_PROPERTIES *brushProperties,
            ID2D1SolidColorBrush **solidColorBrush) noexcept nogil
        void DrawBitmap(
            ID2D1Bitmap *bitmap,
            const D2D1_RECT_F& destinationRectangle,
            FLOAT opacity,
            D2D1_BITMAP_INTERPOLATION_MODE interpolationMode,
            const D2D1_RECT_F *sourceRectangle) noexcept nogil
        void DrawEllipse(
            const D2D1_ELLIPSE *ellipse,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle) noexcept nogil
        void DrawGeometry(
            ID2D1Geometry *geometry,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle) noexcept nogil
        void DrawLine(
            D2D1_POINT_2F point0,
            D2D1_POINT_2F point1,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle) noexcept nogil
        void DrawRectangle(
            const D2D1_RECT_F *rect,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle) noexcept nogil
        void DrawTextW(
            const WCHAR *string,
            UINT stringLength,
            IDWriteTextFormat *textFormat,
            const D2D1_RECT_F &layoutRect,
            ID2D1Brush *defaultForegroundBrush,
            D2D1_DRAW_TEXT_OPTIONS options,
            DWRITE_MEASURING_MODE measuringMode) noexcept nogil
        void DrawTextLayout(
            D2D1_POINT_2F origin,
            IDWriteTextLayout *textLayout,
            ID2D1Brush *defaultForegroundBrush,
            D2D1_DRAW_TEXT_OPTIONS options) noexcept nogil
        HRESULT EndDraw(D2D1_TAG *tag1, D2D1_TAG *tag2) noexcept nogil
        void FillEllipse(const D2D1_ELLIPSE *ellipse, ID2D1Brush *brush) noexcept nogil
        void FillGeometry(
            ID2D1Geometry *geometry,
            ID2D1Brush *brush,
            ID2D1Brush *opacityBrush) noexcept nogil
        void FillRectangle(const D2D1_RECT_F *rect, ID2D1Brush *brush) noexcept nogil
        void GetTransform(D2D1_MATRIX_3X2_F *transform) noexcept nogil
        void SetAntialiasMode(D2D1_ANTIALIAS_MODE antialiasMode) noexcept nogil
        void SetTransform(const D2D1_MATRIX_3X2_F *transform) noexcept nogil
    cdef cppclass ID2D1SimplifiedGeometrySink:
        void BeginFigure(D2D1_POINT_2F startPoint, int figureBegin) noexcept nogil
        HRESULT Close() noexcept nogil
        void EndFigure(int figureEnd) noexcept nogil
        void SetFillMode(D2D1_FILL_MODE fillMode) noexcept nogil
    cdef cppclass ID2D1SolidColorBrush:
        void SetColor(const D2D1_COLOR_F *color) noexcept nogil
    cdef cppclass IWICBitmapSource

    cdef const GUID IID_ID2D1Factory

    HRESULT D2D1CreateFactory(
        D2D1_FACTORY_TYPE factoryType,
        const GUID& riid,
        const D2D1_FACTORY_OPTIONS *pFactoryOptions,
        void **ppIFactory) noexcept nogil


cdef getHRESULTstring(int hr):
    cdef int strBufLen = 0x1000
    cdef wchar_t[0x1000] strBuf
    cdef unsigned int ncopied = FormatMessageW(
        0x1200,
        NULL,
        hr,
        0,
        strBuf,
        strBufLen,
        NULL)
    if ncopied == 0:
        return 'unknown error %08x' % hr
    return PyUnicode_FromWideChar(strBuf, ncopied).rstrip("\r\n")


class COMError(OSError):
    def __init__(self, hresult):
        self.hresult = hresult
        self.args = (getHRESULTstring(hresult),)


class Direct2DError(COMError):
    pass

def InitializeCOM(options=0):
    cdef HRESULT hr = CoInitializeEx(NULL, options)
    if hr == 1:
        # already initialized
        pass
    elif FAILED(hr):
        raise COMError(hr)

def UninitializeCOM():
    CoUninitialize()

cdef class COMObject:
    cdef void* ptr

    def __init__(self):
        raise TypeError("This class cannot be instantiated directly.")

    cpdef Release(self):
        if self.ptr is not NULL:
            (<IUnknown*>self.ptr).Release()
            self.ptr = NULL

    def __dealloc__(self):
        self.Release()


_d2d_factory = None

def GetD2DFactory():
    global _d2d_factory
    if _d2d_factory is None:
        _d2d_factory = D2DFactory()
    return _d2d_factory

from libc.stdio cimport printf

cdef class D2DFactory(COMObject):
    def __init__(self, int factoryType=0, int debugLevel=0):
        cdef D2D1_FACTORY_OPTIONS options
        cdef ID2D1Factory* factory
        options.debugLevel = <D2D1_DEBUG_LEVEL>debugLevel
        res = D2D1CreateFactory(<D2D1_FACTORY_TYPE>factoryType, IID_ID2D1Factory, &options, <void**>&factory)
        if FAILED(res):
            raise Direct2DError(res)
        self.ptr = <void*>factory

    def CreateHwndRenderTarget(
            self,
            intptr_t hwnd,
            int width,
            int height,
            int presentOptions=0,
            int rtType=0,
            int pixelFormat=0,
            int alphaMode=0,
            float dpiX=0,
            float dpiY=0,
            int usage=0,
            int featureLevel=0):
        cdef D2D1_RENDER_TARGET_PROPERTIES rtp
        rtp.type = <D2D1_RENDER_TARGET_TYPE>rtType
        rtp.pixelFormat.format = <DXGI_FORMAT>pixelFormat
        rtp.pixelFormat.alphaMode = <D2D1_ALPHA_MODE>alphaMode
        rtp.dpiX = dpiX
        rtp.dpiY = dpiY
        rtp.usage = <D2D1_RENDER_TARGET_USAGE>usage
        rtp.minLevel = <D2D1_FEATURE_LEVEL>featureLevel
        cdef D2D1_HWND_RENDER_TARGET_PROPERTIES hrtp
        hrtp.hwnd = <HWND>hwnd
        hrtp.pixelSize.width = width
        hrtp.pixelSize.height = height
        hrtp.presentOptions = <D2D1_PRESENT_OPTIONS>presentOptions
        cdef ID2D1HwndRenderTarget* target
        res = (<ID2D1Factory*>self.ptr).CreateHwndRenderTarget(&rtp, &hrtp, <ID2D1HwndRenderTarget**>&target)
        if FAILED(res):
            raise Direct2DError(res)
        cdef HWNDRenderTarget obj = HWNDRenderTarget.__new__(HWNDRenderTarget)
        obj.ptr = <void*>target
        return obj

    def CreatePathGeometry(self):
        cdef ID2D1PathGeometry* pgm
        res = (<ID2D1Factory*>self.ptr).CreatePathGeometry(<ID2D1PathGeometry**>&pgm)
        if FAILED(res):
            raise Direct2DError(res)
        cdef PathGeometry obj = PathGeometry.__new__(PathGeometry)
        obj.ptr = <void*>pgm
        return obj

    def CreateStrokeStyle(
            self,
            int startCap=0,
            int endCap=0,
            int dashCap=0,
            int lineJoin=0,
            float miterLimit=10.0,
            int dashStyle=0,
            float dashOffset=0.0):
        cdef D2D1_STROKE_STYLE_PROPERTIES ssp
        ssp.startCap = <D2D1_CAP_STYLE>startCap
        ssp.endCap = <D2D1_CAP_STYLE>endCap
        ssp.dashCap = <D2D1_CAP_STYLE>dashCap
        ssp.lineJoin = <D2D1_LINE_JOIN>lineJoin
        ssp.miterLimit = miterLimit
        ssp.dashStyle = <D2D1_DASH_STYLE>dashStyle
        ssp.dashOffset = dashOffset
        cdef ID2D1StrokeStyle *sstyle
        res = (<ID2D1Factory*>self.ptr).CreateStrokeStyle(&ssp, NULL, 0, <ID2D1StrokeStyle**>&sstyle)
        if FAILED(res):
            raise Direct2DError(res)
        cdef StrokeStyle obj = StrokeStyle.__new__(StrokeStyle)
        obj.ptr = <void*>sstyle
        return obj


cdef class Resource(COMObject):
    pass


cdef class RenderTarget(Resource):
    def BeginDraw(self):
        (<ID2D1RenderTarget*>self.ptr).BeginDraw()

    def Clear(self, float r, float g, float b, float a=1.0):
        cdef D2D1_COLOR_F color
        color.r = r
        color.g = g
        color.b = b
        color.a = a
        (<ID2D1RenderTarget*>self.ptr).Clear(&color)

    # def CreateBitmapFromWicBitmap(self, source, int dxgiFormat=0, int alphaMode=0, float dpiX=0.0, float dpiY=0.0):
    #     cdef D2D1_BITMAP_PROPERTIES properties
    #     properties.pixelFormat.format = dxgiFormat
    #     properties.pixelFormat.alphaMode = alphaMode
    #     properties.dpiX = dpiX
    #     properties.dpiY = dpiY
    #     cdef ID2D1Bitmap *bitmap
    #     res = (<ID2D1RenderTarget*>self.ptr).CreateBitmapFromWicBitmap(
    #         <IWICBitmapSource*>source.ptr,
    #         &properties,
    #         &bitmap)
    #     if FAILED(res):
    #         raise Direct2DError(res)
    #     cdef Bitmap obj = Bitmap.__new__(Bitmap)
    #     obj.ptr = <void*>bitmap
    #     return obj

    def CreateSolidColorBrush(self, float r, float g, float b, float a=1.0, float opacity=1.0):
        cdef D2D1_COLOR_F color
        color.r = r
        color.g = g
        color.b = b
        color.a = a
        cdef D2D1_BRUSH_PROPERTIES bprop
        bprop.opacity = opacity
        cdef ID2D1SolidColorBrush *brush
        res = (<ID2D1RenderTarget*>self.ptr).CreateSolidColorBrush(&color, &bprop, &brush)
        if FAILED(res):
            raise Direct2DError(res)
        cdef SolidColorBrush obj = SolidColorBrush.__new__(SolidColorBrush)
        obj.ptr = <void*>brush
        return obj

    def DrawBitmap(
            self,
            Bitmap bitmap,
            float l,
            float t,
            float r,
            float b,
            float opacity=1.0,
            interpolationMode=1,
            srcRect=None):
        cdef D2D1_RECT_F dest, src
        dest.left = l
        dest.top = t
        dest.right = r
        dest.bottom = b
        cdef D2D1_RECT_F *srcRectPtr = NULL
        if srcRect is not None:
            src.left, src.top, src.right, src.bottom = srcRect
            srcRectPtr = &src
        (<ID2D1RenderTarget*>self.ptr).DrawBitmap(
            <ID2D1Bitmap*>bitmap.ptr,
            dest,
            opacity,
            <D2D1_BITMAP_INTERPOLATION_MODE>interpolationMode,
            srcRectPtr)

    def DrawEllipse(
            self,
            float cx,
            float cy,
            float rx,
            float ry,
            Brush brush,
            float strokeWidth=1.0,
            StrokeStyle strokeStyle=None):
        cdef D2D1_ELLIPSE el
        el.point.x = cx
        el.point.y = cy
        el.radiusX = rx
        el.radiusY = ry
        cdef ID2D1StrokeStyle *sstyle
        if strokeStyle is None:
            sstyle = NULL
        else:
            sstyle = <ID2D1StrokeStyle*>strokeStyle.ptr
        (<ID2D1RenderTarget*>self.ptr).DrawEllipse(&el, <ID2D1Brush*>brush.ptr, strokeWidth, sstyle)

    def DrawGeometry(self, Geometry geometry, Brush brush, float strokeWidth=1.0, StrokeStyle strokeStyle=None):
        cdef ID2D1StrokeStyle *sstyle
        if strokeStyle is None:
            sstyle = NULL
        else:
            sstyle = <ID2D1StrokeStyle*>strokeStyle.ptr
        (<ID2D1RenderTarget*>self.ptr).DrawGeometry(
            <ID2D1Geometry*>geometry.ptr,
            <ID2D1Brush*>brush.ptr,
            strokeWidth,
            sstyle)

    def DrawLine(
            self,
            float x1,
            float y1,
            float x2,
            float y2,
            Brush brush,
            float strokeWidth=1.0,
            StrokeStyle strokeStyle=None):
        cdef D2D1_POINT_2F point0
        point0.x = x1
        point0.y = y1
        cdef D2D1_POINT_2F point1
        point1.x = x2
        point1.y = y2
        cdef ID2D1StrokeStyle *sstyle
        if strokeStyle is None:
            sstyle = NULL
        else:
            sstyle = <ID2D1StrokeStyle*>strokeStyle.ptr
        (<ID2D1RenderTarget*>self.ptr).DrawLine(point0, point1, <ID2D1Brush*>brush.ptr, strokeWidth, sstyle)

    def DrawRectangle(
            self,
            float l,
            float t,
            float r,
            float b,
            Brush brush,
            float strokeWidth=1.0,
            StrokeStyle strokeStyle=None):
        cdef D2D1_RECT_F rect
        rect.left = l
        rect.top = t
        rect.right = r
        rect.bottom = b
        cdef ID2D1StrokeStyle *sstyle
        if strokeStyle is None:
            sstyle = NULL
        else:
            sstyle = <ID2D1StrokeStyle*>strokeStyle.ptr
        (<ID2D1RenderTarget*>self.ptr).DrawRectangle(&rect, <ID2D1Brush*>brush.ptr, strokeWidth, sstyle)

    def DrawText(
            self,
            str text,
            TextFormat textFormat,
            float l,
            float t,
            float r,
            float b,
            Brush brush,
            int options=0,
            int measuringMode=0):
        cdef D2D1_RECT_F rect
        rect.left = l
        rect.top = t
        rect.right = r
        rect.bottom = b
        cdef wchar_t *textBuf
        cdef Py_ssize_t _textLength
        textBuf = PyUnicode_AsWideCharString(text, &_textLength)
        cdef UINT textLength
        textLength = <UINT>_textLength
        if textBuf == NULL:
            raise MemoryError
        (<ID2D1RenderTarget*>self.ptr).DrawTextW(
            textBuf,
            <UINT>textLength,
            <IDWriteTextFormat*>textFormat.ptr,
            rect,
            <ID2D1Brush*>brush.ptr,
            <D2D1_DRAW_TEXT_OPTIONS>options,
            <DWRITE_MEASURING_MODE>measuringMode)
        PyMem_Free(<void*>textBuf)

    def DrawTextLayout(self, float x, float y, TextLayout textLayout, Brush brush, int options=0):
        cdef D2D1_POINT_2F pt
        pt.x = x
        pt.y = y
        (<ID2D1RenderTarget*>self.ptr).DrawTextLayout(
            pt,
            <IDWriteTextLayout*>textLayout.ptr,
            <ID2D1Brush*>brush.ptr,
            <D2D1_DRAW_TEXT_OPTIONS>options)

    def EndDraw(self):
        res = (<ID2D1RenderTarget*>self.ptr).EndDraw(NULL, NULL)
        if FAILED(res):
            raise Direct2DError(res)

    def FillEllipse(self, float cx, float cy, float rx, float ry, Brush brush):
        cdef D2D1_ELLIPSE el
        el.point.x = cx
        el.point.y = cy
        el.radiusX = rx
        el.radiusY = ry
        (<ID2D1RenderTarget*>self.ptr).FillEllipse(&el, <ID2D1Brush*>brush.ptr)

    def FillGeometry(self, Geometry geometry, Brush brush):
        (<ID2D1RenderTarget*>self.ptr).FillGeometry(<ID2D1Geometry*>geometry.ptr, <ID2D1Brush*>brush.ptr, NULL)

    def FillRectangle(self, float l, float t, float r, float b, Brush brush):
        cdef D2D1_RECT_F rect
        rect.left = l
        rect.top = t
        rect.right = r
        rect.bottom = b
        (<ID2D1RenderTarget*>self.ptr).FillRectangle(&rect, <ID2D1Brush*>brush.ptr)

    def GetTransform(self):
        cdef D2D1_MATRIX_3X2_F mat
        (<ID2D1RenderTarget*>self.ptr).GetTransform(&mat)
        return mat.m11, mat.m12, mat.m21, mat.m22, mat.dx, mat.dy

    def SetAntialiasMode(self, int mode):
        (<ID2D1RenderTarget*>self.ptr).SetAntialiasMode(<D2D1_ANTIALIAS_MODE>mode)

    def SetTransform(self, float m11=1, float m12=0, float m21=0, float m22=1, float dx=0, float dy=0):
        cdef D2D1_MATRIX_3X2_F mat
        mat.m11 = m11
        mat.m12 = m12
        mat.m21 = m21
        mat.m22 = m22
        mat.dx = dx
        mat.dy = dy
        (<ID2D1RenderTarget*>self.ptr).SetTransform(&mat)


cdef class HWNDRenderTarget(RenderTarget):
    def Resize(self, int width, int height):
        cdef D2D1_SIZE_U size
        size.width = width
        size.height = height
        res = (<ID2D1HwndRenderTarget*>self.ptr).Resize(&size)
        if FAILED(res):
            raise Direct2DError(res)


cdef class Brush(Resource):
    def GetOpacity(self):
        return (<ID2D1Brush*>self.ptr).GetOpacity()


cdef class SolidColorBrush(Brush):
    def SetColor(self, float r, float g, float b, float a=1.0):
        cdef D2D1_COLOR_F color
        color.r = r
        color.g = g
        color.b = b
        color.a = a
        (<ID2D1SolidColorBrush*>self.ptr).SetColor(&color)


cdef class StrokeStyle(Resource):
    pass


cdef class Geometry(Resource):
    pass


cdef class PathGeometry(Geometry):
    def Open(self):
        cdef ID2D1GeometrySink *gs
        res = (<ID2D1PathGeometry*>self.ptr).Open(&gs)
        if FAILED(res):
            raise Direct2DError(res)
        cdef GeometrySink obj = GeometrySink.__new__(GeometrySink)
        obj.ptr = <void*>gs
        return obj


cdef class SimplifiedGeometrySink(COMObject):
    def BeginFigure(self, float x, float y, int figureBegin=0):
        cdef D2D1_POINT_2F pt
        pt.x = x
        pt.y = y
        (<ID2D1SimplifiedGeometrySink*>self.ptr).BeginFigure(pt, <D2D1_FIGURE_BEGIN>figureBegin)

    def Close(self):
        res = (<ID2D1SimplifiedGeometrySink*>self.ptr).Close()
        if FAILED(res):
            raise Direct2DError(res)

    def EndFigure(self, int figureEnd=0):
        (<ID2D1SimplifiedGeometrySink*>self.ptr).EndFigure(<D2D1_FIGURE_END>figureEnd)

    def SetFillMode(self, int fillMode):
        (<ID2D1SimplifiedGeometrySink*>self.ptr).SetFillMode(<D2D1_FILL_MODE>fillMode)


cdef class GeometrySink(SimplifiedGeometrySink):
    def AddArc(self, float x, float y, float rx, float ry, float rotationAngle, int sweepDirection, int arcSize):
        cdef D2D1_ARC_SEGMENT arc
        arc.point.x = x
        arc.point.y = y
        arc.size.width = rx
        arc.size.height = ry
        arc.rotationAngle = rotationAngle
        arc.sweepDirection = <D2D1_SWEEP_DIRECTION>sweepDirection
        arc.arcSize = <D2D1_ARC_SIZE>arcSize
        (<ID2D1GeometrySink*>self.ptr).AddArc(&arc)

    def AddBezier(self, float x1, float y1, float x2, float y2, float x3, float y3):
        cdef D2D1_BEZIER_SEGMENT bz
        bz.point1.x = x1
        bz.point1.y = y1
        bz.point2.x = x2
        bz.point2.y = y2
        bz.point3.x = x3
        bz.point3.y = y3
        (<ID2D1GeometrySink*>self.ptr).AddBezier(&bz)

    def AddLine(self, float x, float y):
        cdef D2D1_POINT_2F pt
        pt.x = x
        pt.y = y
        (<ID2D1GeometrySink*>self.ptr).AddLine(pt)

    def AddQuadraticBezier(self, float x1, float y1, float x2, float y2):
        cdef D2D1_QUADRATIC_BEZIER_SEGMENT bz
        bz.point1.x = x1
        bz.point1.y = y1
        bz.point2.x = x2
        bz.point2.y = y2
        (<ID2D1GeometrySink*>self.ptr).AddQuadraticBezier(&bz)


cdef class Image(Resource):
    pass


cdef class Bitmap(Image):
    pass


_dwrite_factory = None

def GetDWriteFactory():
    global _dwrite_factory
    if _dwrite_factory is None:
        _dwrite_factory = DWriteFactory()
    return _dwrite_factory

class DirectWriteError(COMError):
    pass

cdef class DWriteFactory(COMObject):
    def __init__(self, int factoryType=0):
        cdef IDWriteFactory* factory
        res = DWriteCreateFactory(
            <DWRITE_FACTORY_TYPE>factoryType,
            IID_IDWriteFactory,
            <IUnknown**>&factory)
        if FAILED(res):
            raise DirectWriteError(res)
        self.ptr = <void*>factory

    def CreateTextFormat(self, str familyName, float size, int weight=500, int style=0, int stretch=5):
        cdef IDWriteTextFormat *fmt
        cdef wchar_t *familyBuf
        familyBuf = PyUnicode_AsWideCharString(familyName, NULL)
        if familyBuf == NULL:
            raise MemoryError
        cdef wchar_t[1] localeBuf
        localeBuf[0] = 0
        res = (<IDWriteFactory*>self.ptr).CreateTextFormat(
            familyBuf,
            NULL,
            <DWRITE_FONT_WEIGHT>weight,
            <DWRITE_FONT_STYLE>style,
            <DWRITE_FONT_STRETCH>stretch,
            size,
            localeBuf,
            <IDWriteTextFormat**>&fmt)
        PyMem_Free(<void*>familyBuf)
        if FAILED(res):
            raise DirectWriteError(res)
        cdef TextFormat obj = TextFormat.__new__(TextFormat)
        obj.ptr = <void*>fmt
        return obj

    def CreateTextLayout(self, str text, TextFormat textFormat, float maxWidth, float maxHeight):
        cdef IDWriteTextLayout* layout
        cdef wchar_t *stringBuf
        cdef Py_ssize_t stringBufLen
        stringBuf = PyUnicode_AsWideCharString(text, &stringBufLen)
        if stringBuf == NULL:
            raise MemoryError
        res = (<IDWriteFactory*>self.ptr).CreateTextLayout(
            stringBuf,
            <UINT32>stringBufLen,
            <IDWriteTextFormat*>textFormat.ptr,
            maxWidth,
            maxHeight,
            &layout)
        PyMem_Free(stringBuf)
        if FAILED(res):
            raise DirectWriteError(res)
        cdef TextLayout obj = TextLayout.__new__(TextLayout)
        obj.ptr = <void*>layout
        return obj


cdef class FontFace(COMObject):
    pass


cdef class TextFormat(COMObject):
    pass


cdef class TextLayout(TextFormat):
    def GetMaxWidth(self):
        return (<IDWriteTextLayout*>self.ptr).GetMaxWidth()

    def GetMetrics(self):
        cdef DWRITE_TEXT_METRICS tm
        res = (<IDWriteTextLayout*>self.ptr).GetMetrics(&tm)
        if FAILED(res):
            raise DirectWriteError(res)
        TM = TEXT_METRICS()
        TM.left = tm.left
        TM.top = tm.top
        TM.width = tm.width
        TM.widthIncludingTrailingWhitespace = tm.widthIncludingTrailingWhitespace
        TM.height = tm.height
        TM.layoutWidth = tm.layoutWidth
        TM.layoutHeight = tm.layoutHeight
        TM.maxBidiReorderingDepth = tm.maxBidiReorderingDepth
        TM.lineCount = tm.lineCount
        return TM

class TEXT_METRICS:
    pass
