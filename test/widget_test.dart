import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/app.dart';
import 'package:moj_wss_notification/core/di/service_locator.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('Notification app renders one-screen notification feed', (
    tester,
  ) async {
    await tester.pumpWidget(const NotificationApp());

    expect(find.text('Notification Center'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('notification-dashboard')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('compose-action')), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
  });
}
