import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_echarts/fl_echarts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fl_echarts Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

// ─── Demo page ───────────────────────────────────────────────────────────────

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('fl_echarts Demo'),
          actions: [
            const Text('Dark'),
            Switch(
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bar'),
              Tab(text: 'Line'),
              Tab(text: 'Pie'),
              Tab(text: 'Live'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ChartTab(
              darkMode: _darkMode,
              title: 'Bar Chart — Monthly Sales',
              option: _barOption,
            ),
            _ChartTab(
              darkMode: _darkMode,
              title: 'Line Chart — Temperature',
              option: _lineOption,
            ),
            _ChartTab(
              darkMode: _darkMode,
              title: 'Pie Chart — Browser Usage',
              option: _pieOption,
            ),
            _LiveTab(darkMode: _darkMode),
          ],
        ),
      ),
    );
  }
}

// ─── Static chart tab ────────────────────────────────────────────────────────

class _ChartTab extends StatelessWidget {
  final bool darkMode;
  final String title;
  final Map<String, dynamic> option;

  const _ChartTab({
    required this.darkMode,
    required this.title,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ECharts(
            height: 320,
            darkMode: darkMode,
            option: option,
            onChartReady: () => debugPrint('$title ready'),
          ),
        ],
      ),
    );
  }
}

// ─── Live update tab ─────────────────────────────────────────────────────────

class _LiveTab extends StatefulWidget {
  final bool darkMode;
  const _LiveTab({required this.darkMode});

  @override
  State<_LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<_LiveTab> {
  final _controller = EChartsController();
  final _rng = Random();
  bool _ready = false;
  bool _loading = false;

  Map<String, dynamic> get _randomOption => {
        'title': {'text': 'Random Data', 'left': 'center'},
        'tooltip': {},
        'xAxis': {
          'type': 'category',
          'data': ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
        },
        'yAxis': {'type': 'value'},
        'series': [
          {
            'type': 'bar',
            'data': List.generate(7, (_) => _rng.nextInt(200) + 20),
            'itemStyle': {
              'color': {
                'type': 'linear',
                'x': 0,
                'y': 0,
                'x2': 0,
                'y2': 1,
                'colorStops': [
                  {'offset': 0, 'color': '#6366f1'},
                  {'offset': 1, 'color': '#a5b4fc'},
                ],
              },
            },
          },
        ],
      };

  Map<String, dynamic> _currentOption = {};

  @override
  void initState() {
    super.initState();
    _currentOption = _randomOption;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    _controller.showLoading(text: 'Refreshing…');
    await Future.delayed(const Duration(milliseconds: 600));
    final next = _randomOption;
    await _controller.updateChart(next);
    _controller.hideLoading();
    setState(() {
      _currentOption = next;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Updates via EChartsController',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ECharts(
            height: 320,
            darkMode: widget.darkMode,
            option: _currentOption,
            controller: _controller,
            onChartReady: () => setState(() => _ready = true),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _ready && !_loading ? _refresh : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Randomize Data'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: _ready
                    ? () => _controller.executeJavaScript('echart.clear();')
                    : null,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _ready ? '✓ Chart is ready' : '⏳ Waiting for chart…',
            style: TextStyle(
              color: _ready ? Colors.green : Colors.orange,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chart options ────────────────────────────────────────────────────────────

final _barOption = {
  'tooltip': {'trigger': 'axis'},
  'legend': {
    'data': ['2023', '2024']
  },
  'xAxis': {
    'type': 'category',
    'data': [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ],
  },
  'yAxis': {'type': 'value'},
  'series': [
    {
      'name': '2023',
      'type': 'bar',
      'data': [32, 51, 41, 64, 75, 82, 91, 87, 73, 68, 54, 45],
    },
    {
      'name': '2024',
      'type': 'bar',
      'data': [42, 58, 55, 70, 88, 95, 101, 96, 85, 78, 65, 60],
    },
  ],
};

final _lineOption = {
  'tooltip': {'trigger': 'axis'},
  'legend': {
    'data': ['Min', 'Max']
  },
  'xAxis': {
    'type': 'category',
    'data': [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ],
  },
  'yAxis': {'type': 'value', 'name': '°C'},
  'series': [
    {
      'name': 'Min',
      'type': 'line',
      'smooth': true,
      'data': [-2, 0, 4, 9, 14, 18, 20, 19, 15, 10, 5, 1],
      'areaStyle': {'opacity': 0.2},
    },
    {
      'name': 'Max',
      'type': 'line',
      'smooth': true,
      'data': [6, 9, 14, 19, 25, 30, 33, 32, 27, 21, 13, 8],
      'areaStyle': {'opacity': 0.2},
    },
  ],
};

final _pieOption = {
  'tooltip': {'trigger': 'item'},
  'legend': {'orient': 'vertical', 'left': 'left'},
  'series': [
    {
      'name': 'Browser',
      'type': 'pie',
      'radius': ['40%', '70%'],
      'avoidLabelOverlap': false,
      'label': {'show': false},
      'emphasis': {
        'label': {'show': true, 'fontSize': 18, 'fontWeight': 'bold'},
      },
      'data': [
        {'value': 63, 'name': 'Chrome'},
        {'value': 18, 'name': 'Safari'},
        {'value': 6, 'name': 'Edge'},
        {'value': 4, 'name': 'Firefox'},
        {'value': 9, 'name': 'Other'},
      ],
    },
  ],
};
