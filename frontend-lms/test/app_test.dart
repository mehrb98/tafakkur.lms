import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tafakkur_lms/main.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('demo sign-in opens the role dashboard with its sidebar', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TafakkurApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Teacher'));
    await tester.pumpAndSettle();

    expect(find.text('Lessons today'), findsOneWidget);
    expect(find.text('My classes'), findsWidgets);
    expect(find.text('Demo data'), findsOneWidget);
  });
}
