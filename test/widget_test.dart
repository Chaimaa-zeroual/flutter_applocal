import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/app.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}
