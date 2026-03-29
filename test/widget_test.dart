import 'package:flutter_test/flutter_test.dart';

import 'package:plate_check/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TagSnagApp());

    expect(find.text('TagSnag'), findsOneWidget);
    expect(find.text('Check a Plate'), findsOneWidget);
    expect(find.text('Get AI Plate Ideas'), findsOneWidget);
  });
}
