import 'package:flutter/material.dart';
import 'package:moj_wss_notification/features/notifications/presentation/layout/notification_layout_metrics.dart';
import 'package:moj_wss_notification/core/theme/app_theme.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/conversation_transcript.dart';

class NotificationDashboardBody extends StatelessWidget {
  const NotificationDashboardBody({
    super.key,
    required this.filterChannelId,
    required this.filterLabel,
  });

  final String? filterChannelId;
  final String filterLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = NotificationLayoutMetrics.fromConstraints(constraints);

        return DecoratedBox(
          decoration: _pageDecoration(context),
          child: SafeArea(
            top: false,
            bottom: false,
            child: _TranscriptFrame(
              metrics: metrics,
              filterChannelId: filterChannelId,
              filterLabel: filterLabel,
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _pageDecoration(BuildContext context) {
    final glass = Theme.of(context).extension<GlassColors>();
    final fallback = Theme.of(context).scaffoldBackgroundColor;

    return BoxDecoration(
      color: fallback,
      gradient: glass == null
          ? null
          : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [glass.pageGradientStart, glass.pageGradientEnd],
            ),
    );
  }
}

class _TranscriptFrame extends StatelessWidget {
  const _TranscriptFrame({
    required this.metrics,
    required this.filterChannelId,
    required this.filterLabel,
  });

  final NotificationLayoutMetrics metrics;
  final String? filterChannelId;
  final String filterLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.transcriptHorizontalPadding,
        metrics.transcriptTopPadding,
        metrics.transcriptHorizontalPadding,
        metrics.transcriptBottomPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.transcriptMaxWidth),
          child: ConversationTranscript(
            filterChannelId: filterChannelId,
            filterLabel: filterLabel,
          ),
        ),
      ),
    );
  }
}
