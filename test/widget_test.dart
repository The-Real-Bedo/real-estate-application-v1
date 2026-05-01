import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:real_estate_app/screens/auth/welcome_screen.dart';
import 'package:real_estate_app/theme/app_theme.dart';

void main() {
  testWidgets('welcome screen shows main actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const WelcomeScreen()),
    );

    expect(find.text('RealEstate'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);
  });
}
