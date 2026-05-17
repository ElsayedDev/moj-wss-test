enum AppFlavor { development, staging, production }

class AppEnvironment {
  const AppEnvironment._({
    required this.flavor,
    required this.name,
    required this.displayName,
  });

  static const development = AppEnvironment._(
    flavor: AppFlavor.development,
    name: 'development',
    displayName: 'Development',
  );

  static const staging = AppEnvironment._(
    flavor: AppFlavor.staging,
    name: 'staging',
    displayName: 'Staging',
  );

  static const production = AppEnvironment._(
    flavor: AppFlavor.production,
    name: 'production',
    displayName: 'Production',
  );

  final AppFlavor flavor;
  final String name;
  final String displayName;

  bool get isProduction => flavor == AppFlavor.production;
}
