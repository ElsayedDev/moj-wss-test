import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

class ChannelRegistry {
  ChannelRegistry(List<NotificationChannel> channels) {
    final registeredChannels = <String, NotificationChannel>{};
    final channelInfos = <NotificationChannelInfo>[];

    for (final channel in channels) {
      if (registeredChannels.containsKey(channel.id)) {
        throw ArgumentError(
          'Duplicate notification channel id: ${channel.id}.',
        );
      }

      registeredChannels[channel.id] = channel;
      channelInfos.add(
        NotificationChannelInfo(
          id: channel.id,
          label: channel.label,
          recipientInputKind: channel.recipientInputKind,
        ),
      );
    }

    _channels = Map.unmodifiable(registeredChannels);
    this.channels = List.unmodifiable(channelInfos);
  }

  late final Map<String, NotificationChannel> _channels;

  late final List<NotificationChannelInfo> channels;

  Result<NotificationChannel> resolve(String channelId) {
    final channel = _channels[channelId];
    if (channel == null) {
      return Result.failure(
        NotificationFailure.general(
          'No notification channel registered for $channelId.',
        ),
      );
    }
    return Result.success(channel);
  }
}
