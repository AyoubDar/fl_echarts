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
