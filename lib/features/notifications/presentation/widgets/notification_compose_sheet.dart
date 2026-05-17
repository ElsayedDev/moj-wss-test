import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';
import 'package:moj_wss_notification/features/notifications/presentation/layout/notification_layout_metrics.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_compose_panel.dart';

class NotificationComposeSheet extends StatefulWidget {
  const NotificationComposeSheet({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  State<NotificationComposeSheet> createState() =>
      _NotificationComposeSheetState();
}

class _NotificationComposeSheetState extends State<NotificationComposeSheet> {
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listenWhen: (previous, current) =>
          previous.status == NotificationStatus.submitting &&
          current.status == NotificationStatus.success,
      listener: (context, state) {
        _recipientController.clear();
        _messageController.clear();
        widget.onClose();
      },
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenSize = MediaQuery.sizeOf(context);
              final metrics = NotificationLayoutMetrics.fromConstraints(
                BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  maxHeight: screenSize.height,
                ),
              );
              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
              final isWideSheet = constraints.maxWidth >= 600;
              final targetSheetWidth = isWideSheet
                  ? (constraints.maxWidth > 900 ? 720.0 : 680.0)
                  : metrics.composeWidth;
              final sheetWidth = math.min(
                metrics.composeWidth,
                targetSheetWidth,
              );
              final maxSheetHeight = math.max(
                0.0,
                screenSize.height - keyboardInset - 18.h,
              );

              return AnimatedPadding(
                duration: const Duration(milliseconds: 190),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: SafeArea(
                  top: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                      child: SizedBox(
                        width: sheetWidth,
                        child: ConstrainedBox(
                          key: const ValueKey('compose-sheet'),
                          constraints: BoxConstraints(
                            maxHeight: maxSheetHeight,
                          ),
                          child: SingleChildScrollView(
                            child: NotificationComposePanel(
                              state: state,
                              recipientController: _recipientController,
                              messageController: _messageController,
                              onCancel: _handleCancel,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleCancel() {
    _recipientController.clear();
    _messageController.clear();
    FocusScope.of(context).unfocus();
    widget.onClose();
  }
}
