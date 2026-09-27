import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tafakkur_lms/main.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('demo sign-in opens the dashboard and the sidebar drawer', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TafakkurApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Teacher'));
    await tester.pumpAndSettle();
    expect(find.text('Lessons today'), findsOneWidget);
    expect(find.byTooltip('Scan QR code to sign in on the web'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    expect(find.text('My classes'), findsWidgets);
    expect(find.text('Homework'), findsOneWidget);
  });
}
