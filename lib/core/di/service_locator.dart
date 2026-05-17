import 'package:get_it/get_it.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/core/config/app_environment.dart';
import 'package:moj_wss_notification/features/notifications/di/notification_di.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies({
  AppEnvironment environment = AppEnvironment.production,
}) {
  if (!getIt.isRegistered<AppEnvironment>()) {
    getIt.registerSingleton<AppEnvironment>(environment);
  }

  if (!getIt.isRegistered<Clock>()) {
    getIt.registerLazySingleton<Clock>(() => const SystemClock());
  }

  registerNotificationDependencies(getIt);
}
