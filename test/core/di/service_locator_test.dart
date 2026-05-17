import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/core/config/app_environment.dart';
import 'package:moj_wss_notification/core/di/service_locator.dart';
import 'package:moj_wss_notification/features/notifications/application/channel_registry.dart';
import 'package:moj_wss_notification/features/notifications/application/load_notification_history.dart';
import 'package:moj_wss_notification/features/notifications/application/send_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('service locator', () {
    test('registers core and notification dependencies', () {
      configureDependencies();

      expect(getIt<AppEnvironment>(), AppEnvironment.production);
      expect(getIt<Clock>(), isA<SystemClock>());
      expect(getIt<NotificationRepository>(), isA<NotificationRepository>());
      expect(getIt<ChannelRegistry>().channels.map((channel) => channel.id), [
        'email',
        'sms',
        'push',
      ]);
      expect(getIt<SendNotification>(), isA<SendNotification>());
      expect(getIt<LoadNotificationHistory>(), isA<LoadNotificationHistory>());
      expect(
        getIt<NotificationChannelPresentationFactory>(),
        isA<DefaultNotificationChannelPresentationFactory>(),
      );
      expect(getIt<NotificationCubit>().state.channels, hasLength(3));
    });

    test('can be configured more than once without duplicate registration', () {
      configureDependencies();
      configureDependencies();

      expect(getIt<ChannelRegistry>().channels, hasLength(3));
    });

    test('registers the requested app environment', () {
      configureDependencies(environment: AppEnvironment.staging);

      expect(getIt<AppEnvironment>(), AppEnvironment.staging);
    });
  });
}
