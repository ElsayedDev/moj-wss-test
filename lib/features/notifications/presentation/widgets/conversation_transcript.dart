import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/empty_conversation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_bubble.dart';

class ConversationTranscript extends StatelessWidget {
  const ConversationTranscript({
    super.key,
    required this.filterChannelId,
    required this.filterLabel,
  });

  final String? filterChannelId;
  final String filterLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('conversation-transcript'),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.46),
        ),
      ),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final messages = filterChannelId == null
              ? state.history
              : state.history
                    .where(
                      (notification) =>
                          notification.channelId == filterChannelId,
                    )
                    .toList();

          if (messages.isEmpty) {
            return EmptyConversation(filterLabel: filterLabel);
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 92.h),
            itemCount: messages.length,
            separatorBuilder: (_, _) => 10.verticalSpace,
            itemBuilder: (context, index) =>
                NotificationMessageCard(notification: messages[index]),
          );
        },
      ),
    );
  }
}
