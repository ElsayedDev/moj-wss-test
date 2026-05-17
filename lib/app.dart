import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/core/di/service_locator.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/pages/notification_dashboard_page.dart';
import 'package:moj_wss_notification/core/theme/app_theme.dart';
import 'package:moj_wss_notification/l10n/app_localizations.dart';

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = AppTheme.light();
    final darkTheme = AppTheme.dark();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Clock>.value(value: getIt<Clock>()),
        RepositoryProvider<NotificationChannelPresentationFactory>.value(
          value: getIt<NotificationChannelPresentationFactory>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        splitScreenMode: true,
        builder: (context, child) {
          return BlocProvider<NotificationCubit>(
            create: (_) => getIt<NotificationCubit>()..onLoadHistory(),
            child: MaterialApp(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              themeMode: ThemeMode.system,
              theme: lightTheme,
              darkTheme: darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              home: const NotificationDashboardPage(),
              builder: (context, child) {
                final brightness = MediaQuery.platformBrightnessOf(context);
                final materialTheme = brightness == Brightness.dark
                    ? darkTheme
                    : lightTheme;

                return Theme(
                  data: materialTheme,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
