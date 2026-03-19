## 0.3.0

* Re-add **Web** support via a custom `HtmlElementView` iframe — no `webview_flutter_web` dependency, no `addJavaScriptChannel` limitation.
* Fix web rendering: use a `Blob` object URL instead of `srcdoc` to safely load the 1 MB ECharts bundle.
* Fix web: `runJavaScript` commands are delivered to the iframe via `postMessage`.
* Re-add **Windows** support via `webview_windows`.
* Fix widget lifecycle on web: force a `setState` after `init()` so the iframe enters the DOM before waiting for the `ready` message.
* Package now supports 5 platforms: Android, iOS, macOS, Web, Windows.

## 0.2.0

* **BREAKING**: Removed web support due to platform limitations.
* Improved error handling for unsupported platforms.
* Updated `isSupported` check to exclude web.

## 0.1.1

* Segregate platform implementations to improve package analysis score.
* Fix pubspec.yaml documentation links.
* Update example dependency to current version.

## 0.1.0

* Add macOS support (via `webview_flutter`).
* Fix critical bug: `echarts.init` received undefined `chartDom`; corrected to use the `chart` DOM element.
* Fix `resizeChart()` calling `chart.resize()` instead of `echart.resize()`.
* Add `didUpdateWidget` — chart re-renders automatically when `option` changes; controller re-attaches on swap.
* Fix `showLoading` JS string interpolation vulnerability (now uses `jsonEncode`).
* Add timeout to `waitForECharts` polling loop to prevent infinite spin when asset fails.
* Replace deprecated `withOpacity` with `withValues(alpha:)`.
* Relax SDK constraint from `^3.7.2` to `^3.0.0`.
* Bump Flutter minimum to `>=3.10.0`.
* Write complete README with usage examples.

## 0.0.1

* Initial release with Android, iOS, and Windows support.
