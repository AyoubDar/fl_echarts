import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fl_echarts_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: verify app loads and shows title',
      (WidgetTester tester) async {
    // Start the app
    app.main();

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify the title is present
    expect(find.text('fl_echarts Demo'), findsOneWidget);

    // Verify tabs are present
    expect(find.text('Bar'), findsOneWidget);
    expect(find.text('Line'), findsOneWidget);
    expect(find.text('Pie'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });
}
