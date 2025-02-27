# pyD2D - A Python wrapper for the Windows Direct2D API

pyD2D is a Python wrapper for the Windows Direct2D and DirectWrite APIs.

Not all of the Direct2D and DirectWrite APIs are wrapped, but the most commonly used ones are.
If you need a specific API that is not wrapped, feel free to open an issue or submit a pull request.

Note: At this point pyD2D only provides wheels for Python 3.13 32-bit on Windows,
due to the headaches of Python packaging for Cython extensions.
If you need a wheel for a different version of Python, feel free to open an issue.

## Installation

```bash
pip install pyd2d
```

## Usage

```python
import pyd2d

# Initialize COM
pyd2d.InitializeCOM()

# Create a Direct2D factory
factory = pyd2d.GetD2DFactory()

# Create a render target
render_target = factory.CreateHwndRenderTarget(
    my_hwnd, width=800, height=600,
)

# Draw a rectangle
render_target.BeginDraw()
render_target.Clear(1.0, 1.0, 1.0, 1.0)
render_target.FillRectangle(100, 100, 200, 200, render_target.CreateSolidColorBrush(0.0, 0.0, 0.0, 1.0))
render_target.EndDraw()
```

## License

pyD2D is licensed under the MIT License.
