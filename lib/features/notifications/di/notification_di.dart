import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/features/notifications/application/channel_registry.dart';
import 'package:moj_wss_notification/features/notifications/application/load_notification_history.dart';
import 'package:moj_wss_notification/features/notifications/application/send_notification.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/email_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/push_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/sms_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/repositories/in_memory_notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';

void registerNotificationDependencies(GetIt getIt) {
  if (!getIt.isRegistered<NotificationRepository>()) {
    getIt.registerLazySingleton<NotificationRepository>(
      InMemoryNotificationRepository.new,
    );
  }

  if (!getIt.isRegistered<ChannelRegistry>()) {
    getIt.registerLazySingleton<ChannelRegistry>(
      () => ChannelRegistry(createDefaultNotificationChannels()),
    );
  }

  if (!getIt.isRegistered<SendNotification>()) {
    getIt.registerLazySingleton<SendNotification>(
      () => SendNotification(
        registry: getIt<ChannelRegistry>(),
        repository: getIt<NotificationRepository>(),
        clock: getIt<Clock>(),
      ),
    );
  }

  if (!getIt.isRegistered<LoadNotificationHistory>()) {
    getIt.registerLazySingleton<LoadNotificationHistory>(
      () =>
          LoadNotificationHistory(repository: getIt<NotificationRepository>()),
    );
  }

  if (!getIt.isRegistered<NotificationChannelPresentationFactory>()) {
    getIt.registerLazySingleton<NotificationChannelPresentationFactory>(
      () => DefaultNotificationChannelPresentationFactory(
        channelVisualSpecs: defaultNotificationChannelVisualSpecs(),
      ),
    );
  }

  if (!getIt.isRegistered<NotificationCubit>()) {
    getIt.registerFactory<NotificationCubit>(
      () => NotificationCubit(
        sendNotification: getIt<SendNotification>(),
        loadHistory: getIt<LoadNotificationHistory>(),
      ),
    );
  }
}

List<NotificationChannel> createDefaultNotificationChannels() {
  return [
    EmailNotificationChannel(),
    SmsNotificationChannel(),
    PushNotificationChannel(),
  ];
}

Map<String, NotificationChannelVisualSpec>
defaultNotificationChannelVisualSpecs() {
  return const {
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
  };
}
