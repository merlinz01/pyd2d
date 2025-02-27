from libc.stdint cimport int32_t, uint32_t, uint64_t
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
        void *Arguments)
    bint SUCCEEDED(HRESULT hr)
    bint FAILED(HRESULT hr)

cdef extern from "objbase.h":
    HRESULT CoInitializeEx(
        void* pvReserved,
        unsigned long dwCoInit)
    
    cdef cppclass IUnknown:
        void Release()

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
        FLOAT GetMaxWidth()
        HRESULT GetMetrics(DWRITE_TEXT_METRICS *textMetrics)
    cdef cppclass IDWriteFactory:
        HRESULT CreateTextFormat(
            const WCHAR *family_name,
            IDWriteFontCollection *collection,
            DWRITE_FONT_WEIGHT weight,
            DWRITE_FONT_STYLE style,
            DWRITE_FONT_STRETCH stretch,
            FLOAT size,
            const WCHAR *locale,
            IDWriteTextFormat **format)
        HRESULT CreateTextLayout(
            WCHAR *string,
            UINT32 stringLength,
            IDWriteTextFormat *textFormat,
            FLOAT maxWidth,
            FLOAT maxHeight,
            IDWriteTextLayout **textLayout
        )
    cdef cppclass IDWriteFontCollection
    cdef cppclass IDWriteTextFormat

    HRESULT DWriteCreateFactory(DWRITE_FACTORY_TYPE factoryType, const GUID& iid, IUnknown** factory)


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
        FLOAT GetOpacity()
    cdef cppclass ID2D1PathGeometry:
        HRESULT Open(ID2D1GeometrySink **geometrySink)
    cdef cppclass ID2D1StrokeStyle
    cdef cppclass ID2D1Factory:
        HRESULT CreateHwndRenderTarget(
            const D2D1_RENDER_TARGET_PROPERTIES *renderTargetProperties,
            const D2D1_HWND_RENDER_TARGET_PROPERTIES *hwndRenderTargetProperties,
            ID2D1HwndRenderTarget **hwndRenderTarget)
        HRESULT CreatePathGeometry(ID2D1PathGeometry **pathGeometry)
        HRESULT CreateStrokeStyle(
            const D2D1_STROKE_STYLE_PROPERTIES *strokeStyleProperties,
            const FLOAT *dashes,
            UINT dashesCount,
            ID2D1StrokeStyle **strokeStyle)
    cdef cppclass ID2D1Geometry
    cdef cppclass ID2D1GeometrySink:
        void AddArc(const D2D1_ARC_SEGMENT *arc)
        void AddBezier(const D2D1_BEZIER_SEGMENT *bezier)
        void AddLine(D2D1_POINT_2F point)
        void AddQuadraticBezier(const D2D1_QUADRATIC_BEZIER_SEGMENT *bezier)
        void BeginFigure(D2D1_POINT_2F startPoint, D2D1_FIGURE_BEGIN figureBegin)
        HRESULT Close()
        void EndFigure(D2D1_FIGURE_END figureEnd)
        void SetFillMode(D2D1_FILL_MODE fillMode)
    cdef cppclass ID2D1HwndRenderTarget:
        HRESULT Resize(const D2D1_SIZE_U *pixelSize)
    cdef cppclass ID2D1RenderTarget:
        void BeginDraw()
        void Clear(const D2D1_COLOR_F *clearColor)
        HRESULT CreateBitmapFromWicBitmap(
            IWICBitmapSource *wicBitmapSource,
            const D2D1_BITMAP_PROPERTIES *bitmapProperties,
            ID2D1Bitmap **bitmap)
        HRESULT CreateSolidColorBrush(
            const D2D1_COLOR_F *color,
            const D2D1_BRUSH_PROPERTIES *brushProperties,
            ID2D1SolidColorBrush **solidColorBrush)
        void DrawBitmap(
            ID2D1Bitmap *bitmap,
            const D2D1_RECT_F& destinationRectangle,
            FLOAT opacity,
            D2D1_BITMAP_INTERPOLATION_MODE interpolationMode,
            const D2D1_RECT_F *sourceRectangle)
        void DrawEllipse(
            const D2D1_ELLIPSE *ellipse,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle)
        void DrawGeometry(
            ID2D1Geometry *geometry,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle)
        void DrawLine(
            D2D1_POINT_2F point0,
            D2D1_POINT_2F point1,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle)
        void DrawRectangle(
            const D2D1_RECT_F *rect,
            ID2D1Brush *brush,
            FLOAT strokeWidth,
            ID2D1StrokeStyle *strokeStyle)
        void DrawTextW(
            const WCHAR *string,
            UINT stringLength,
            IDWriteTextFormat *textFormat,
            const D2D1_RECT_F &layoutRect,
            ID2D1Brush *defaultForegroundBrush,
            D2D1_DRAW_TEXT_OPTIONS options,
            DWRITE_MEASURING_MODE measuringMode)
        void DrawTextLayout(
            D2D1_POINT_2F origin,
            IDWriteTextLayout *textLayout,
            ID2D1Brush *defaultForegroundBrush,
            D2D1_DRAW_TEXT_OPTIONS options)
        HRESULT EndDraw(D2D1_TAG *tag1, D2D1_TAG *tag2)
        void FillEllipse(const D2D1_ELLIPSE *ellipse, ID2D1Brush *brush)
        void FillGeometry(
            ID2D1Geometry *geometry,
            ID2D1Brush *brush,
            ID2D1Brush *opacityBrush)
        void FillRectangle(const D2D1_RECT_F *rect, ID2D1Brush *brush)
        void GetTransform(D2D1_MATRIX_3X2_F *transform)
        void SetAntialiasMode(D2D1_ANTIALIAS_MODE antialiasMode)
        void SetTransform(const D2D1_MATRIX_3X2_F *transform)
    cdef cppclass ID2D1SimplifiedGeometrySink:
        void BeginFigure(D2D1_POINT_2F startPoint, int figureBegin)
        HRESULT Close()
        void EndFigure(int figureEnd)
        void SetFillMode(D2D1_FILL_MODE fillMode)
    cdef cppclass ID2D1SolidColorBrush:
        void SetColor(const D2D1_COLOR_F *color)
    cdef cppclass IWICBitmapSource

    cdef const GUID IID_ID2D1Factory

    HRESULT D2D1CreateFactory(
        D2D1_FACTORY_TYPE factoryType,
        const GUID& riid,
        const D2D1_FACTORY_OPTIONS *pFactoryOptions,
        void **ppIFactory)