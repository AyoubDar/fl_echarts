# fl_echarts

A Flutter package that brings the full power of [Apache ECharts](https://echarts.apache.org/) to your Flutter app via an embedded WebView — no JavaScript knowledge required.

**Supported platforms:** Android · iOS · macOS · Web · Windows

**Linux:** not yet supported (no viable webview backend available).

---

## Features

- Render any ECharts chart (line, bar, pie, scatter, candlestick, radar, map, …)
- Dark mode support
- Dynamic chart updates without rebuilding the widget
- Manual `showLoading` / `hideLoading` control
- Custom JavaScript execution
- Resize API
- `EChartsController` for full programmatic control
- Callbacks: `onChartReady`, `onMessage`, `onWebViewCreated`

---

## Getting started

### 1. Add the dependency

```yaml
dependencies:
  fl_echarts: ^0.3.0
```

### 2. Platform setup

**Android** — no extra steps.

**iOS / macOS** — add to `ios/Runner/Info.plist` (iOS) or `macos/Runner/Info.plist` (macOS):

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
```

**Web** — no extra steps. Charts render inside an iframe using the browser's native rendering.

**Windows** — requires the **WebView2 Runtime** (pre-installed on Windows 10 21H2+ and all Windows 11). For older Windows 10 machines, users must install it from Microsoft. Follow the [webview_windows setup guide](https://pub.dev/packages/webview_windows#setup) for any additional project configuration.

---

## Usage

### Basic chart

```dart
import 'package:fl_echarts/fl_echarts.dart';

ECharts(
  height: 300,
  option: {
    'xAxis': {'type': 'category', 'data': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']},
    'yAxis': {'type': 'value'},
    'series': [
      {'type': 'bar', 'data': [120, 200, 150, 80, 70]},
    ],
  },
)
```

### Using `EChartsController`

```dart
final _controller = EChartsController();

// In your widget
ECharts(
  height: 300,
  controller: _controller,
  option: _myOption,
  onChartReady: () {
    // Chart is rendered and ready
  },
)

// Update the chart data later
await _controller.updateChart(_newOption);

// Show/hide loading overlay
_controller.showLoading(text: 'Fetching data…');
await Future.delayed(const Duration(seconds: 2));
_controller.hideLoading();

// Trigger resize after layout changes
await _controller.resizeChart();

// Run arbitrary JavaScript
await _controller.executeJavaScript('echart.clear();');

// Clean up
_controller.dispose();
```

### Dark mode

```dart
ECharts(
  height: 300,
  darkMode: true,
  option: _myOption,
)
```

### Full widget parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `option` | `Map<String, dynamic>` | required | ECharts option object |
| `width` | `double?` | fills parent | Widget width |
| `height` | `double?` | `400` | Widget height |
| `darkMode` | `bool` | `false` | Enable dark theme |
| `controller` | `EChartsController?` | — | Programmatic control |
| `onChartReady` | `VoidCallback?` | — | Called when chart finishes rendering |
| `onMessage` | `EChartsMessageCallback?` | — | Raw JS→Flutter messages |
| `onWebViewCreated` | `VoidCallback?` | — | Called when WebView is created |

---

## ECharts documentation

For the full list of chart types and `option` fields see the  
[official ECharts documentation](https://echarts.apache.org/en/option.html).

---

## License

MIT. See [LICENSE](LICENSE).
