import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_3_pmpl/main.dart';

void main() {
  testWidgets('app shows login screen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login Provider'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
