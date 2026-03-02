import 'dart:convert';
import 'package:flutter/services.dart';

import 'src/platform_utils.dart';
import 'package:flutter/material.dart';

import 'src/webview_factory.dart';

typedef EChartsMessageCallback = void Function(String message);

class EChartsController {
  _EChartsState? _state;

  void _attach(_EChartsState state) => _state = state;
  void _detach() => _state = null;

  bool get isAttached => _state != null;
  bool get isLoaded => _state?._isLoaded ?? false;
  bool get hasError => _state?._lastError != null;
  String? get errorMessage => _state?._lastError;

  /// Update the chart with new options
  Future<void> updateChart(Map<String, dynamic> newOption) async {
    if (_state == null || !_state!.mounted) {
      throw StateError(
          'EChartsController is not attached to any widget or widget is disposed');
    }
    if (!_state!._isLoaded) {
      throw StateError(
          'Chart is not ready yet. Wait for onChartReady callback.');
    }
    await _state!.updateChart(newOption);
  }

  /// Resize the chart (useful after container size changes)
  Future<void> resizeChart() async {
    if (_state == null || !_state!.mounted) {
      throw StateError(
          'EChartsController is not attached to any widget or widget is disposed');
    }
    if (!_state!._isLoaded) {
      throw StateError(
          'Chart is not ready yet. Wait for onChartReady callback.');
    }
    await _state!.resizeChart();
  }

  /// Execute custom JavaScript in the chart context
  Future<void> executeJavaScript(String script) async {
    if (_state == null || !_state!.mounted) {
      throw StateError(
          'EChartsController is not attached to any widget or widget is disposed');
    }
    await _state!.executeJavaScript(script);
  }

  /// Show loading state manually
  void showLoading({String? text}) {
    if (_state == null || !_state!.mounted) {
      throw StateError(
          'EChartsController is not attached to any widget or widget is disposed');
    }
    _state!.showLoading(text: text);
  }

  /// Hide loading state manually
  void hideLoading() {
    if (_state == null || !_state!.mounted) {
      throw StateError(
          'EChartsController is not attached to any widget or widget is disposed');
    }
    _state!.hideLoading();
  }

  /// Dispose the controller
  void dispose() {
    _detach();
  }
}

class ECharts extends StatefulWidget {
  final Map<String, dynamic> option;
  final double? width;
  final double? height;
  final EChartsMessageCallback? onMessage;
  final VoidCallback? onWebViewCreated;
  final VoidCallback? onChartReady;
  final bool darkMode;
  final EChartsController? controller;

  const ECharts({
    super.key,
    required this.option,
    this.width,
    this.height,
    this.onMessage,
    this.onWebViewCreated,
    this.onChartReady,
    this.darkMode = false,
    this.controller,
  });

  @override
  State<ECharts> createState() => _EChartsState();
}

class _EChartsState extends State<ECharts> {
  EChartsWebView? _webView;

  bool _isLoaded = false;
  bool _isInitializing = true;
  bool _manualLoading = false;
  String? _lastError;
  String? _loadingText;
  String? _echartsScript;

  @override
  void initState() {
    super.initState();
    // Attach controller if provided
    widget.controller?._attach(this);
    _initializeWebView();
  }

  @override
  void didUpdateWidget(covariant ECharts oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-attach controller if it changed
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
    // Re-render chart if option changed
    if (_isLoaded && oldWidget.option != widget.option) {
      updateChart(widget.option);
    }
  }

  @override
  void dispose() {
    // Detach controller
    widget.controller?._detach();
    _webView?.dispose();
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    try {
      // Load echarts script from assets
      try {
        _echartsScript = await rootBundle
            .loadString('packages/fl_echarts/assets/echarts.min.js');
      } catch (e) {
        // Fallback for local development
         try {
          _echartsScript = await rootBundle.loadString('assets/echarts.min.js');
        } catch (e) {
          setState(() {
            _lastError = 'Failed to load echarts script: $e';
            _isInitializing = false;
          });
          return;
        }
      }

      if (_echartsScript == null || _echartsScript!.isEmpty) {
        setState(() {
           _lastError = 'ECharts script is empty';
           _isInitializing = false;
        });
        return;
      }

      _webView = createWebView();
      await _webView!.init(
        () {
          setState(() {
            _isInitializing = false;
          });
        },
        (error) {
          setState(() {
            _lastError = error;
            _isInitializing = false;
          });
        },
        (message) {
           _handleMessage(message);
        },
        () {
           widget.onWebViewCreated?.call();
        },
        _getHtmlContent(),
      );
    } catch (e) {
      setState(() {
        _lastError = e.toString();
        _isInitializing = false;
      });
    }
  }

  // _initializeMobileWebView and _initializeWindowsWebView are removed as they are now handled by EChartsWebView impls.
  // ...

  void _handleMessage(String message) {
    try {
      if (message.contains('"type":"ready"')) {
        setState(() {
          _isLoaded = true;
          _isInitializing = false;
          _manualLoading = false;
          _loadingText = null;
        });
        widget.onChartReady?.call();
      } else if (message.contains('"type":"error"')) {
        setState(() {
          _lastError = 'Chart error: $message';
          _isLoaded = false;
          _manualLoading = false;
        });
      }
    } catch (e) {
      // Ignore error
    }

    widget.onMessage?.call(message);
  }

  String _getHtmlContent() {
    final theme = widget.darkMode ? 'dark' : 'light';

    return '''
      <!DOCTYPE html>
      <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>ECharts</title>
            <script>
              ${_echartsScript ?? ''}
            </script>
            <style>
                * { margin: 0; padding: 0; }
                html, body { width: 100%; height: 100%; overflow: hidden !important; }
                #chart { width: 100%; height: 100vh; }
                .loading {
                  display: flex;
                  flex-direction: column;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  font-family: Arial, sans-serif;
                  color: #666;
                }
                .spinner {
                  border: 3px solid #f3f3f3;
                  border-top: 3px solid #3498db;
                  border-radius: 50%;
                  width: 30px;
                  height: 30px;
                  animation: spin 1s linear infinite;
                  margin-bottom: 10px;
                }
                @keyframes spin {
                  0% { transform: rotate(0deg); }
                  100% { transform: rotate(360deg); }
                }
            </style>
        </head>
        <body>
            <div id="loading" class="loading">
              <div class="spinner"></div>
              <div>Loading chart...</div>
            </div>
            <div id="chart" style="display: none;"></div>
            <script>
                let echart;

                // Recursive function to parse stringified functions in the options object
                function parseOptions(obj) {
                  if (Array.isArray(obj)) {
                    return obj.map(val => parseOptions(val));
                  } else if (typeof obj === 'object' && obj !== null) {
                    const newObj = {};
                    for (const key in obj) {
                      if (obj.hasOwnProperty(key)) {
                        newObj[key] = parseOptions(obj[key]);
                      }
                    }
                    return newObj;
                  } else if (typeof obj === 'string') {
                    const str = obj.trim();
                    // Check if the string looks like a JS function
                    if (str.startsWith('function') || str.startsWith('(') || str.includes('=>')) {
                      try {
                        // Use the Function constructor to evaluate the expression
                        return new Function('return ' + str)();
                      } catch (e) {
                        // If it fails (e.g. it was just a normal string that happened to look like code), keep it as is
                        return obj;
                      }
                    }
                  }
                  return obj;
                }
                
                function initChart() {
                  const chart = document.getElementById('chart');
                  const loading = document.getElementById('loading');
                  
                  try {
                    echart = echarts.init(chart, '$theme');
                    
                    // Parse options to hydrate functions
                    const rawOption = ${jsonEncode(widget.option)};
                    echart.setOption(parseOptions(rawOption), true);
                    
                    loading.style.display = 'none';
                    chart.style.display = 'block';

                    echart.resize();
                    
                    window.addEventListener('resize', function() {
                      if (echart) {
                        echart.resize();
                      }
                    });
                    
                    sendMessage(JSON.stringify({type: 'ready'}));
                  } catch(e) {
                    loading.innerHTML = '<div style="color: red;">Error loading chart: ' + e.message + '</div>';
                    sendMessage(JSON.stringify({type: 'error', message: e.message}));
                  }
                }

                function setOption(option) {
                  if (echart) {
                    echart.setOption(option, true);
                  }
                }
                
                function showLoading(text) {
                  if (echart) {
                    echart.showLoading('default', {
                      text: text || 'Loading...',
                      color: '#3498db',
                      textColor: '#666',
                      maskColor: 'rgba(255, 255, 255, 0.8)',
                      zlevel: 0
                    });
                  }
                }
                
                function hideLoading() {
                  if (echart) {
                    echart.hideLoading();
                  }
                }
                
                function sendMessage(message) {
                  if (window.FlutterECharts) {
                    window.FlutterECharts.postMessage(message);
                  }
                  
                  if (window.chrome && window.chrome.webview) {
                    window.chrome.webview.postMessage(message);
                  }
                }
                
                let _waitAttempts = 0;
                function waitForECharts() {
                  if (typeof echarts !== 'undefined') {
                    initChart();
                  } else if (_waitAttempts++ < 100) {
                    setTimeout(waitForECharts, 50);
                  } else {
                    const loading = document.getElementById('loading');
                    if (loading) loading.innerHTML = '<div style="color: red;">Error: ECharts failed to load (timeout).</div>';
                    sendMessage(JSON.stringify({type: 'error', message: 'ECharts failed to load (timeout)'}));
                  }
                }
                
                window.onload = function() {
                  waitForECharts();
                };

                window.onerror = function(msg, url, line, col, error) {
                  const loading = document.getElementById('loading');
                  if (loading) {
                    loading.innerHTML = '<div style="color: red;">Error: ' + msg + '</div>';
                  }
                  sendMessage(JSON.stringify({
                    type: 'error',
                    message: msg,
                    line: line,
                    column: col
                  }));
                };
            </script>
        </body>
      </html>
    ''';
  }

  Future<void> updateChart(Map<String, dynamic> newOption) async {
    final String script = '''
      try {
        const rawOption = ${jsonEncode(newOption)};
        const parsedOption = parseOptions(rawOption);
        setOption(parsedOption);
        sendMessage(JSON.stringify({type: 'updated'}));
      } catch(e) {
        sendMessage(JSON.stringify({type: 'error', message: e.message}));
      }
    ''';

    await _executeScript(script);
  }

  Future<void> resizeChart() async {
    const String script = '''
      if (echart) {
        echart.resize();
        sendMessage(JSON.stringify({type: 'resized'}));
      }
    ''';

    await _executeScript(script);
  }

  Future<void> executeJavaScript(String script) async {
    await _executeScript(script);
  }

  void showLoading({String? text}) {
    setState(() {
      _manualLoading = true;
      _loadingText = text;
    });

    final String script = 'showLoading(${jsonEncode(text ?? 'Loading...')});';
    _executeScript(script);
  }

  void hideLoading() {
    setState(() {
      _manualLoading = false;
      _loadingText = null;
    });

    const String script = 'hideLoading();';
    _executeScript(script);
  }

  Future<void> _executeScript(String script) async {
    try {
      if (_webView != null) {
        await _webView!.runJavaScript(script);
      }
    } catch (e) {
      // Ignore error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lastError != null) {
      return _buildErrorWidget();
    }

    if (!PlatformDetector.isSupported) {
      return _buildUnsupportedWidget();
    }

    return Container(
        width: widget.width,
        height: widget.height ?? 400,
        color: Colors.transparent,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(children: [
              _buildWebView(),
              if (_isInitializing || !_isLoaded || _manualLoading)
                Container(
                    color: widget.darkMode
                        ? Colors.black.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.darkMode
                                      ? Colors.white
                                      : Colors.blue)),
                          const SizedBox(height: 16),
                          Text(_loadingText ?? 'Loading chart...',
                              style: TextStyle(
                                  color: widget.darkMode
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 14))
                        ])))
            ])));
  }

  Widget _buildWebView() {
    if (_webView != null) {
      return _webView!.build(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorWidget() {
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text('Error loading chart',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700)),
          const SizedBox(height: 8),
          Text(_lastError!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center)
        ]));
  }

  Widget _buildUnsupportedWidget() {
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.warning_outlined, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text('Platform Not Supported',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700)),
          const SizedBox(height: 8),
          Text('Platform: ${PlatformDetector.platformName}',
              style: const TextStyle(color: Colors.grey))
        ]));
  }
}
