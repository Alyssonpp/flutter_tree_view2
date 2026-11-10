import 'package:example/main.dart' as example_app;
import 'package:example/src/app.dart';
import 'package:example/src/examples.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final example in Example.values) {
    testWidgets('Starts ${example.title} with material_ui', (tester) async {
      SharedPreferences.setMockInitialValues({
        selectedExampleKey: example.name,
      });

      await example_app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(AppView), findsOneWidget);
      expect(find.byType(ExamplesView), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
