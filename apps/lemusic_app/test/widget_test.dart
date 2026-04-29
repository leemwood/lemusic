import 'package:flutter_test/flutter_test.dart';

import 'package:lemusic/main.dart';

void main() {
  testWidgets('LeMusic app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LeMusicApp());
    await tester.pumpAndSettle();

    // Bottom navigation labels should exist
    expect(find.text('搜索'), findsOneWidget);
    expect(find.text('播放'), findsOneWidget);
    expect(find.text('歌单'), findsOneWidget);
  });
}

