import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finalproject/theme/app_theme.dart';

void main() {
  testWidgets('App theme builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: const Scaffold(body: Center(child: Text('ok'))),
      ),
    );

    expect(find.text('ok'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
