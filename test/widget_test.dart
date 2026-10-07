import 'package:flutter_test/flutter_test.dart';
import 'package:thesalon/app.dart';

void main() {
  testWidgets('SalonTimesApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SalonTimesApp());
    expect(find.byType(SalonTimesApp), findsOneWidget);
  });
}
