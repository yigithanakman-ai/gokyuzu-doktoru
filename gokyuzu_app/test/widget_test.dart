import 'package:flutter_test/flutter_test.dart';
import 'package:gokyuzu_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GokyuzuDoktoruApp());
    await tester.pump(const Duration(seconds: 1));
  });
}
