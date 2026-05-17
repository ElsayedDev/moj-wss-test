import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('defines development environment metadata', () {
      const environment = AppEnvironment.development;

      expect(environment.flavor, AppFlavor.development);
      expect(environment.name, 'development');
      expect(environment.displayName, 'Development');
      expect(environment.isProduction, isFalse);
    });

    test('defines staging environment metadata', () {
      const environment = AppEnvironment.staging;

      expect(environment.flavor, AppFlavor.staging);
      expect(environment.name, 'staging');
      expect(environment.displayName, 'Staging');
      expect(environment.isProduction, isFalse);
    });

    test('defines production environment metadata', () {
      const environment = AppEnvironment.production;

      expect(environment.flavor, AppFlavor.production);
      expect(environment.name, 'production');
      expect(environment.displayName, 'Production');
      expect(environment.isProduction, isTrue);
    });
  });
}
