# PyD2D: Python + Direct2D

PyD2D is a Python wrapper for the Windows Direct2D and DirectWrite APIs.

## Features

- Direct2D APIs such as RenderTarget, Brush, and Geometry
- DirectWrite APIs such as TextFormat and TextLayout
- Supports Python versions from 3.9 to 3.14
- Supports both 32-bit and 64-bit Python
- Supports free-threaded Python
- Zero dependencies, single extension module
- Full type stubs included
- Includes many useful integer constants
- Fully functional demo app, see [demo.py](/demo.py)
- Permissively licensed
- Used in production

> Note: Not all of the Direct2D and DirectWrite APIs are wrapped, but the most
> commonly used ones are. If you need a specific API that is not wrapped, feel
> free to open an issue or submit a pull request.

## Installation

Simply install the `pyd2d` package from PyPI:

```bash
uv add pyd2d
```

or

```bash
pip install pyd2d
```

## Usage

See the [demo app](/demo.py) for a working example app using pyD2D and ctypes.

Usage follows the C++/COM API usage directly.
In general, pointer-to-struct arguments are passed as keyword arguments for each struct field.

See the [Direct2D](https://learn.microsoft.com/en-us/windows/win32/direct2d/direct2d-portal)
and [DirectWrite](https://learn.microsoft.com/en-us/windows/win32/DirectWrite/direct-write-portal)
documentation for more information.

Example:

```python
import pyd2d

# Initialize COM
pyd2d.InitializeCOM()

# Create a Direct2D factory
factory = pyd2d.GetD2DFactory()

# Create a render target
render_target = factory.CreateHwndRenderTarget(
    my_window_handle, width=800, height=600,
)

# Draw a rectangle
render_target.BeginDraw()
render_target.Clear(1.0, 1.0, 1.0, 1.0)
render_target.FillRectangle(
    100, 100, 200, 200,
    render_target.CreateSolidColorBrush(0.0, 0.0, 0.0, 1.0),
)
render_target.EndDraw()

# Release resources
render_target.Release()
factory.Release()
pyd2d.UninitializeCOM()
```

## License

PyD2D is licensed under the MIT License.
