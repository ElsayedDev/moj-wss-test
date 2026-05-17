import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class NotificationComposeFields extends StatelessWidget {
  const NotificationComposeFields({
    super.key,
    required this.state,
    required this.recipientController,
    required this.messageController,
  });

  final NotificationState state;
  final TextEditingController recipientController;
  final TextEditingController messageController;

  @override
  Widget build(BuildContext context) {
    final presentationFactory = context
        .read<NotificationChannelPresentationFactory>();
    final selectedPresentation = presentationFactory.resolve(
      state.selectedChannel,
    );

    return Column(
      spacing: 10.h,
      children: [
        TextFormField(
          key: const ValueKey('recipient-field'),
          controller: recipientController,
          enabled: !state.isSubmitting,
          keyboardType: selectedPresentation.keyboardType,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            labelText: context.l10n.recipientLabel,
            hintText: selectedPresentation.recipientHint,
            errorText: state.recipientError,
          ),
        ),
        TextFormField(
          key: const ValueKey('message-field'),
          controller: messageController,
          enabled: !state.isSubmitting,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(
            isDense: true,
            labelText: context.l10n.messageContentLabel,
            hintText: context.l10n.messageHint,
            errorText: state.messageError,
          ),
        ),
      ],
    );
  }
}
