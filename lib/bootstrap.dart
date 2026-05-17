import 'package:flutter/material.dart';
import 'package:moj_wss_notification/app.dart';
import 'package:moj_wss_notification/core/config/app_environment.dart';
import 'package:moj_wss_notification/core/di/service_locator.dart';

void bootstrap(AppEnvironment environment) {
  configureDependencies(environment: environment);
  runApp(const NotificationApp());
}
