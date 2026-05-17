import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_compose_floating_action.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_dashboard_body.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_compose_sheet.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_filter_menu.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class NotificationDashboardPage extends StatefulWidget {
  const NotificationDashboardPage({super.key});

  @override
  State<NotificationDashboardPage> createState() =>
      _NotificationDashboardPageState();
}

class _NotificationDashboardPageState extends State<NotificationDashboardPage> {
  static const _composeActionTransitionDelay = Duration(milliseconds: 200);

  String? _selectedFilterChannelId;
  bool _isComposerOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == NotificationStatus.success,
      listener: (context, state) => _handleListener(),

      child:
          BlocSelector<
            NotificationCubit,
            NotificationState,
            List<NotificationChannelInfo>
          >(
            selector: (state) => state.channels,
            builder: (context, channels) {
              return Scaffold(
                key: const ValueKey('notification-dashboard'),
                appBar: AppBar(
                  title: Text(context.l10n.appTitle),
                  centerTitle: false,
                  actions: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 10.w),
                      child: NotificationFilterMenu(
                        selectedValue:
                            _selectedFilterChannelId ??
                            NotificationFilterMenu.allValue,
                        channels: channels,
                        onSelected: (value) {
                          setState(() {
                            _selectedFilterChannelId =
                                value == NotificationFilterMenu.allValue
                                ? null
                                : value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                floatingActionButton: !_isComposerOpen
                    ? NotificationComposeFloatingAction(
                        buttonKey: const ValueKey('compose-action'),
                        tooltip: context.l10n.createMessageTooltip,
                        onPressed: _handleOpenComposer,
                      )
                    : null,
                body: NotificationDashboardBody(
                  filterChannelId: _selectedFilterChannelId,
                  filterLabel: _filterLabelFor(context, channels),
                ),
              );
            },
          ),
    );
  }

  // ----- Helpers -----

  String _filterLabelFor(
    BuildContext context,
    List<NotificationChannelInfo> channels,
  ) {
    if (_selectedFilterChannelId == null) {
      return context.l10n.allFilterLabel;
    }

    return channels
        .firstWhere(
          (channel) => channel.id == _selectedFilterChannelId,
          orElse: () => channels.first,
        )
        .label;
  }

  // ----- Functions -----

  Future<void> _handleOpenComposer() async {
    if (_isComposerOpen) {
      return;
    }

    final cubit = context.read<NotificationCubit>();
    final sheetMaxWidth = MediaQuery.sizeOf(context).width;

    setState(() => _isComposerOpen = true);

    // this try/finally ensures the composer open state is reset
    // even if the sheet fails to open for some reason, or the user dismisses it
    // by tapping outside the sheet (instead of using the provided close button)
    try {
      // Keep the adaptive action out of the modal route's first frame; the
      // Cupertino-native button can otherwise overlap the sheet transition.
      await Future.delayed(_composeActionTransitionDelay);
      if (!mounted) {
        return;
      }

      cubit.onSelectChannel(cubit.state.selectedChannelId);

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        constraints: BoxConstraints(maxWidth: sheetMaxWidth),
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.28),
        builder: (sheetContext) {
          return NotificationComposeSheet(
            onClose: () => Navigator.of(sheetContext).maybePop(),
          );
        },
      );
    } finally {
      await Future.delayed(_composeActionTransitionDelay);
      if (mounted) {
        setState(() => _isComposerOpen = false);
      }
    }
  }

  // todo: use AdaptiveSnackbar when available to avoid the double snackbar issue on iOS
  void _handleListener() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.notificationSent)));
  }
}
