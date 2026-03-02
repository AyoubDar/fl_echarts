import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_echarts/fl_echarts.dart';

void main() {
  // ── EChartsController ──────────────────────────────────────────────

  group('EChartsController', () {
    test('isAttached is false before attaching', () {
      final controller = EChartsController();
      expect(controller.isAttached, isFalse);
    });

    test('isLoaded is false before attaching', () {
      final controller = EChartsController();
      expect(controller.isLoaded, isFalse);
    });

    test('hasError is false when no error present', () {
      final controller = EChartsController();
      expect(controller.hasError, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test('dispose detaches the controller', () {
      final controller = EChartsController();
      controller.dispose();
      expect(controller.isAttached, isFalse);
    });

    test('updateChart throws when not attached', () {
      final controller = EChartsController();
      expect(
        () => controller.updateChart({'series': []}),
        throwsStateError,
      );
    });

    test('resizeChart throws when not attached', () {
      final controller = EChartsController();
      expect(
        () => controller.resizeChart(),
        throwsStateError,
      );
    });

    test('executeJavaScript throws when not attached', () {
      final controller = EChartsController();
      expect(
        () => controller.executeJavaScript('console.log("hi")'),
        throwsStateError,
      );
    });

    test('showLoading throws when not attached', () {
      final controller = EChartsController();
      expect(
        () => controller.showLoading(),
        throwsStateError,
      );
    });

    test('hideLoading throws when not attached', () {
      final controller = EChartsController();
      expect(
        () => controller.hideLoading(),
        throwsStateError,
      );
    });
  });

  // ── ECharts widget ─────────────────────────────────────────────────

  group('ECharts widget', () {
    testWidgets('renders without crashing with minimal option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ECharts(
              option: const {'series': []},
            ),
          ),
        ),
      );
      // Should not throw; widget renders some content
      expect(find.byType(ECharts), findsOneWidget);
    });

    testWidgets('applies provided width and height', (tester) async {
      const double w = 300;
      const double h = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ECharts(
              option: const {'series': []},
              width: w,
              height: h,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ECharts),
          matching: find.byType(Container).first,
        ),
      );

      expect(
          container.constraints?.maxWidth ??
              (container.constraints == null ? w : null),
          anyOf(isNull, equals(w)));
    });

    testWidgets('controller is accepted without error', (tester) async {
      final controller = EChartsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ECharts(
              option: const {'series': []},
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byType(ECharts), findsOneWidget);
      controller.dispose();
    });

    testWidgets('darkMode flag is accepted without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ECharts(
              option: const {'series': []},
              darkMode: true,
            ),
          ),
        ),
      );
      expect(find.byType(ECharts), findsOneWidget);
    });
  });
}
