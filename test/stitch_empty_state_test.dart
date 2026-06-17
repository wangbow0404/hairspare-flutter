import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/widgets/stitch/stitch_empty_state.dart';

void main() {
  testWidgets('StitchEmptyState shows message and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StitchEmptyState(
            message: '목록이 없습니다',
            actionLabel: '다시 시도',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('목록이 없습니다'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    expect(tapped, isTrue);
  });
}
