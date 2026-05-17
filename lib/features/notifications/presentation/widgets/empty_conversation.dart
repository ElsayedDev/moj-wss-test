import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class EmptyConversation extends StatelessWidget {
  const EmptyConversation({super.key, required this.filterLabel});

  final String filterLabel;

  @override
  Widget build(BuildContext context) {
    final isAll = filterLabel == context.l10n.allFilterLabel;
    final title = isAll
        ? context.l10n.emptyAllTitle
        : context.l10n.emptyChannelTitle(channel: filterLabel);
    final body = isAll
        ? context.l10n.emptyAllBody
        : context.l10n.emptyChannelBody;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 360.w.clamp(320, 420).toDouble()),
        child: Padding(
          padding: EdgeInsets.all(28.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
                child: const Icon(Icons.chat_bubble_outline_rounded),
              ),
              16.verticalSpace,
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              6.verticalSpace,
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
