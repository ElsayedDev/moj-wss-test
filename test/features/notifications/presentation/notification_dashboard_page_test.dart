import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/features/notifications/application/channel_registry.dart';
import 'package:moj_wss_notification/features/notifications/application/load_notification_history.dart';
import 'package:moj_wss_notification/features/notifications/application/send_notification.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/email_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/push_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/sms_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/repositories/in_memory_notification_repository.dart';
import 'package:moj_wss_notification/l10n/app_localizations.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/pages/notification_dashboard_page.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_compose_floating_action.dart';
import 'package:moj_wss_notification/core/theme/app_theme.dart';

class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime(2026, 5, 17, 14, 30);
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  Size surfaceSize = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final repository = InMemoryNotificationRepository();
  final sendNotification = SendNotification(
    registry: ChannelRegistry([
      EmailNotificationChannel(),
      SmsNotificationChannel(),
      PushNotificationChannel(),
    ]),
    repository: repository,
    clock: const _FixedClock(),
  );

  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Clock>.value(value: const _FixedClock()),
        RepositoryProvider<NotificationChannelPresentationFactory>(
          create: (_) => const DefaultNotificationChannelPresentationFactory(
            channelVisualSpecs: {
              'email': NotificationChannelVisualSpec(
                icon: Icons.mail_outline_rounded,
                selectedIcon: Icons.mail_rounded,
                sfSymbol: 'envelope',
                selectedSfSymbol: 'envelope.fill',
              ),
              'sms': NotificationChannelVisualSpec(
                icon: Icons.sms_outlined,
                selectedIcon: Icons.sms_rounded,
                sfSymbol: 'message',
                selectedSfSymbol: 'message.fill',
              ),
              'push': NotificationChannelVisualSpec(
                icon: Icons.notifications_none_rounded,
                selectedIcon: Icons.notifications_rounded,
                sfSymbol: 'bell',
                selectedSfSymbol: 'bell.fill',
              ),
            },
          ),
        ),
      ],
      child: BlocProvider(
        create: (_) => NotificationCubit(
          sendNotification: sendNotification,
          loadHistory: LoadNotificationHistory(repository: repository),
        )..onLoadHistory(),
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const NotificationDashboardPage(),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openComposer(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('compose-action')));
  await tester.pumpAndSettle();
}

Future<void> _chooseComposerChannel(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const ValueKey('compose-channel-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _sendNotification(
  WidgetTester tester, {
  required String channel,
  required String recipient,
  required String message,
}) async {
  await _openComposer(tester);
  await _chooseComposerChannel(tester, channel);
  await tester.enterText(
    find.byKey(const ValueKey('recipient-field')),
    recipient,
  );
  await tester.enterText(find.byKey(const ValueKey('message-field')), message);
  await tester.tap(find.byKey(const ValueKey('send-button')));
  await tester.pumpAndSettle();
}

Future<void> _chooseFeedFilter(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const ValueKey('message-filter-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  group('NotificationComposeFloatingAction', () {
    Future<void> pumpAction(
      WidgetTester tester, {
      required TargetPlatform platform,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            floatingActionButton: NotificationComposeFloatingAction(
              buttonKey: const ValueKey('compose-action'),
              tooltip: 'Create message',
              onPressed: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('uses Material floating action button on Android', (
      tester,
    ) async {
      await pumpAction(tester, platform: TargetPlatform.android);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(CNButton), findsNothing);
      expect(find.byKey(const ValueKey('compose-action')), findsOneWidget);
    });

    testWidgets('uses Cupertino-native icon button outside Android', (
      tester,
    ) async {
      await pumpAction(tester, platform: TargetPlatform.iOS);

      expect(find.byType(CNButton), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byKey(const ValueKey('compose-action')), findsOneWidget);
    });
  });

  group('NotificationDashboardPage', () {
    testWidgets('renders one material screen without bottom navigation', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      expect(
        find.byKey(const ValueKey('notification-dashboard')),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byKey(const ValueKey('animated-route-shell')), findsNothing);
      expect(find.byKey(const ValueKey('compose-action')), findsOneWidget);
      expect(find.byType(CNPopupMenuButton), findsOneWidget);
      expect(
        find.byKey(const ValueKey('conversation-transcript')),
        findsOneWidget,
      );
      expect(find.text('Notification Center'), findsOneWidget);
      expect(find.byKey(const ValueKey('compose-sheet')), findsNothing);
    });

    testWidgets('shows an all-messages empty prompt initially', (tester) async {
      await _pumpDashboard(tester);

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(
        find.text('Create a notification to start the message history.'),
        findsOneWidget,
      );
    });

    testWidgets('filter menu exposes All and registered channels', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      expect(find.byKey(const ValueKey('message-filter-menu')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('message-filter-menu')));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('SMS'), findsOneWidget);
      expect(find.text('Push'), findsOneWidget);
    });

    testWidgets('uses Cupertino-native popup menu controls', (tester) async {
      await _pumpDashboard(tester);

      expect(find.byKey(const ValueKey('message-filter-menu')), findsOneWidget);
      expect(find.byType(CNPopupMenuButton), findsOneWidget);

      await _openComposer(tester);

      expect(
        find.byKey(const ValueKey('compose-channel-menu')),
        findsOneWidget,
      );
      expect(find.byType(CNPopupMenuButton), findsNWidgets(2));
    });

    testWidgets(
      'create opens a bottom sheet with channel, title, and content',
      (tester) async {
        await _pumpDashboard(tester);

        await _openComposer(tester);

        expect(find.byKey(const ValueKey('compose-sheet')), findsOneWidget);
        expect(find.text('New Notification'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('compose-channel-menu')),
          findsOneWidget,
        );
        expect(find.text('Recipient'), findsOneWidget);
        expect(find.text('Message Content'), findsOneWidget);
      },
    );

    testWidgets('composer can choose any channel independent of feed filter', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _chooseFeedFilter(tester, 'Push');
      expect(find.text('No Push notifications yet'), findsOneWidget);

      await _sendNotification(
        tester,
        channel: 'SMS',
        recipient: '+201001112222',
        message: 'SMS reminder',
      );

      expect(find.text('No Push notifications yet'), findsOneWidget);
      expect(find.text('SMS reminder'), findsNothing);

      await _chooseFeedFilter(tester, 'All');

      expect(find.text('SMS reminder'), findsOneWidget);
      expect(find.text('SMS'), findsWidgets);
    });

    testWidgets('default feed shows all channel messages newest first', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _sendNotification(
        tester,
        channel: 'Email',
        recipient: 'clerk@justice.gov',
        message: 'Email reminder',
      );
      await _sendNotification(
        tester,
        channel: 'SMS',
        recipient: '+201001112222',
        message: 'SMS reminder',
      );
      await _sendNotification(
        tester,
        channel: 'Push',
        recipient: 'device-token',
        message: 'Push reminder',
      );

      expect(find.text('Email reminder'), findsOneWidget);
      expect(find.text('SMS reminder'), findsOneWidget);
      expect(find.text('Push reminder'), findsOneWidget);

      final pushTop = tester.getTopLeft(find.text('Push reminder')).dy;
      final smsTop = tester.getTopLeft(find.text('SMS reminder')).dy;
      final emailTop = tester.getTopLeft(find.text('Email reminder')).dy;
      expect(pushTop, lessThan(smsTop));
      expect(smsTop, lessThan(emailTop));
    });

    testWidgets('feed filter shows only the selected channel messages', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _sendNotification(
        tester,
        channel: 'Email',
        recipient: 'clerk@justice.gov',
        message: 'Email reminder',
      );
      await _sendNotification(
        tester,
        channel: 'SMS',
        recipient: '+201001112222',
        message: 'SMS reminder',
      );

      await _chooseFeedFilter(tester, 'Email');

      expect(find.text('Email reminder'), findsOneWidget);
      expect(find.text('SMS reminder'), findsNothing);

      await _chooseFeedFilter(tester, 'SMS');

      expect(find.text('Email reminder'), findsNothing);
      expect(find.text('SMS reminder'), findsOneWidget);
    });

    testWidgets('message cards render channel-specific icons', (tester) async {
      await _pumpDashboard(tester);

      await _sendNotification(
        tester,
        channel: 'Email',
        recipient: 'clerk@justice.gov',
        message: 'Email reminder',
      );
      await _sendNotification(
        tester,
        channel: 'SMS',
        recipient: '+201001112222',
        message: 'SMS reminder',
      );
      await _sendNotification(
        tester,
        channel: 'Push',
        recipient: 'device-token',
        message: 'Push reminder',
      );

      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sms_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('message cards expose provider icon semantics', (tester) async {
      await _pumpDashboard(tester);

      await _sendNotification(
        tester,
        channel: 'Email',
        recipient: 'clerk@justice.gov',
        message: 'Email reminder',
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Email notification',
        ),
        findsOneWidget,
      );
    });

    testWidgets('SMS selection uses phone validation in the sheet', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _openComposer(tester);
      await _chooseComposerChannel(tester, 'SMS');

      await tester.enterText(
        find.byKey(const ValueKey('recipient-field')),
        'abc',
      );
      await tester.enterText(
        find.byKey(const ValueKey('message-field')),
        'Hello',
      );
      await tester.tap(find.byKey(const ValueKey('send-button')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid phone number.'), findsOneWidget);
    });

    testWidgets('missing recipient shows validation error in the composer', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _openComposer(tester);

      await tester.enterText(
        find.byKey(const ValueKey('message-field')),
        'Hello',
      );
      await tester.tap(find.byKey(const ValueKey('send-button')));
      await tester.pumpAndSettle();

      expect(find.text('Recipient is required.'), findsOneWidget);
    });

    testWidgets('missing message shows validation error in the composer', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _openComposer(tester);

      await tester.enterText(
        find.byKey(const ValueKey('recipient-field')),
        'clerk@justice.gov',
      );
      await tester.tap(find.byKey(const ValueKey('send-button')));
      await tester.pumpAndSettle();

      expect(find.text('Message is required.'), findsOneWidget);
    });

    testWidgets('successful send closes sheet and renders message card', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _sendNotification(
        tester,
        channel: 'Email',
        recipient: 'clerk@justice.gov',
        message: 'Hearing reminder',
      );

      expect(find.byKey(const ValueKey('notification-card')), findsOneWidget);
      expect(find.byKey(const ValueKey('compose-sheet')), findsNothing);
      expect(find.text('To clerk@justice.gov'), findsOneWidget);
      expect(find.text('Hearing reminder'), findsOneWidget);
      expect(find.text('Notification sent.'), findsOneWidget);
      expect(find.text('No notifications yet'), findsNothing);
    });

    testWidgets('uses localized English strings and timestamp formatting', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _sendNotification(
        tester,
        channel: 'Email',
        recipient: 'clerk@justice.gov',
        message: 'Localized reminder',
      );

      expect(find.text('Notification Center'), findsOneWidget);
      expect(find.text('Localized reminder'), findsOneWidget);
      expect(find.text('2:30 PM'), findsOneWidget);
    });

    testWidgets('long messages render without layout exceptions', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await _sendNotification(
        tester,
        channel: 'Email',
        recipient: 'clerk@justice.gov',
        message:
            'This is a very long notification message intended to verify that the history row wraps and clips gracefully without overflowing on a narrow surface.',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('phone viewport renders without layout exceptions', (
      tester,
    ) async {
      await _pumpDashboard(tester, surfaceSize: const Size(390, 844));

      await _openComposer(tester);

      expect(find.byKey(const ValueKey('compose-sheet')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('compose sheet moves above the keyboard inset', (tester) async {
      const keyboardHeight = 300.0;
      const surfaceSize = Size(390, 844);

      await _pumpDashboard(tester, surfaceSize: surfaceSize);

      await _openComposer(tester);

      tester.view.viewInsets = FakeViewPadding(
        bottom: keyboardHeight * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.reset);
      await tester.pumpAndSettle();

      final sheetBottom = tester
          .getBottomLeft(find.byKey(const ValueKey('compose-sheet')))
          .dy;

      expect(sheetBottom, lessThanOrEqualTo(surfaceSize.height));
      expect(tester.takeException(), isNull);
    });

    testWidgets('iPad portrait constrains the compose sheet', (tester) async {
      await _pumpDashboard(tester, surfaceSize: const Size(820, 1180));

      await _openComposer(tester);

      final sheetSize = tester.getSize(
        find.byKey(const ValueKey('compose-sheet')),
      );

      expect(sheetSize.width, lessThanOrEqualTo(681));
      expect(sheetSize.width, greaterThan(600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('iPad landscape keeps transcript and sheet readable', (
      tester,
    ) async {
      await _pumpDashboard(tester, surfaceSize: const Size(1180, 820));

      await _openComposer(tester);

      final transcriptSize = tester.getSize(
        find.byKey(const ValueKey('conversation-transcript')),
      );
      final sheetSize = tester.getSize(
        find.byKey(const ValueKey('compose-sheet')),
      );

      expect(transcriptSize.width, lessThanOrEqualTo(921));
      expect(sheetSize.width, lessThanOrEqualTo(721));
      expect(sheetSize.width, greaterThan(640));
      expect(tester.takeException(), isNull);
    });
  });
}
