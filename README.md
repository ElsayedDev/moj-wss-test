# MOJ WSS Notification

A Flutter assessment submission for a backend-agnostic multi-channel
notification engine and a polished single-screen notification history
dashboard.

The project focuses on Clean Architecture, SOLID design, runtime provider
switching, Cubit state management, list rendering, validation, and maintainable
extension points for adding new notification channels.

## Demo

- [Android demo](docs/demo/android-demo.gif)
- [iOS demo](docs/demo/ios-demo.mp4)

## Quick Start

Requirements:

- Flutter 3.38.3 or compatible stable release
- Dart 3.10.1 or compatible SDK from Flutter

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

The default `lib/main.dart` entrypoint boots the production environment.

Run checks:

```bash
flutter test
flutter analyze
```

Optional environment entrypoints:

```bash
flutter run -t lib/main_development.dart
flutter run -t lib/main_staging.dart
flutter run -t lib/main_production.dart
```

Android product flavors are also configured:

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor production -t lib/main_production.dart
```

## What Is Included

- Multi-channel notification engine with Email, SMS, and Push providers.
- Runtime notification type switching through a shared provider registry.
- Recipient and message input form with typed validation errors.
- Send action that delegates to the selected provider.
- Newest-first notification history list with provider icon, recipient,
  timestamp, and message content.
- Empty-state rendering when no notifications match the current filter.
- Single-screen dashboard with a compose sheet and channel filter.
- Liquid-glass styled surfaces for the composer and filter controls.
- Light and dark Material themes.
- English localization through Flutter generated localizations.

## Architecture

The notification feature is split with Clean Architecture boundaries:

- `domain`: entities, repository contracts, channel contracts, validation, and
  typed failures.
- `application`: `SendNotification`, `LoadNotificationHistory`, and
  `ChannelRegistry`.
- `data`: mocked Email, SMS, and Push channel implementations plus in-memory
  history storage.
- `presentation`: Cubit state management, dashboard widgets, channel visuals,
  compose UI, filters, and responsive layout metrics.

Providers implement the `NotificationChannel` interface and are resolved by
`ChannelRegistry`, which applies the Strategy pattern. `SendNotification`
depends on abstractions, validates common fields, delegates provider-specific
recipient validation, sends through the selected channel, stores the provider
receipt, and records history.

Dependency injection is handled by `get_it` in the app and feature composition
roots. The domain and application layers do not access Flutter widgets or the
service locator directly.

## State Management And UI

`NotificationCubit` owns the selected channel, available channel metadata,
history, submit status, field errors, and general send errors. It receives
`SendNotification` and `LoadNotificationHistory` through dependency injection.

The UI listens to Cubit state, updates the list after successful sends, prevents
duplicate submits while a send is already in progress, and maps typed failures
to field or general errors without string matching.

Channel-specific icons, SF Symbols, keyboard types, and hints are isolated
behind `NotificationChannelPresentationFactory`, so UI widgets do not hardcode
provider-specific presentation rules.

## Testing

The test suite covers the logic and UI requirements:

- channel recipient validation and mocked send behavior
- provider registry resolution and duplicate-channel protection
- `SendNotification` validation, provider selection, timeouts, receipts, and
  repository failure handling
- in-memory repository ordering and defensive copies
- dependency registration
- Cubit state transitions and duplicate-submit protection
- dashboard rendering, filters, compose flow, empty states, validation errors,
  localization, long messages, and responsive phone/iPad layouts

Run all tests with:

```bash
flutter test
```

Run static analysis with:

```bash
flutter analyze
```

## Current Limitations

These are deliberate assessment-scope boundaries:

- Email, SMS, and Push providers are mocked local implementations.
- Notification history is stored in memory and resets when the app restarts.
- No real backend, gateway, API key, sender ID, or push token integration is
  required.
- No `.env` file is needed for the current mock implementation.
- No connectivity detection, offline queue, retry replay, or cross-device sync
  is implemented.

## Production Recommendations

For a production notification product, the next improvements would be:

- Replace mocked providers with real gateway adapters behind
  `NotificationChannel`.
- Persist notification history with a local database or backend repository.
- Add offline queueing, retry backoff, cancellation, and replay for failed sends.
- Add connectivity-aware sending and clear offline states.
- Add rate limits, quotas, timeout policy, and circuit-breaker protection.
- Add observability for provider latency, send success rate, failures, and quota
  usage.
- Store sensitive gateway URLs, API keys, tokens, and sender IDs in environment
  or platform secrets, never in source control.
- Run `flutter test` and `flutter analyze` in CI before merging.

## Adding A Provider

To add a provider such as WhatsApp:

1. Create a class implementing `NotificationChannel`.
2. Provide a stable `id`, display `label`, and `recipientInputKind`.
3. Implement provider-specific `validateRecipient`.
4. Implement `send` and return a `NotificationSendReceipt` on success.
5. Register the provider in `features/notifications/di/notification_di.dart`.
6. Optionally register provider visual metadata in
   `defaultNotificationChannelVisualSpecs`.
7. Add unit and widget tests for the new provider.

`SendNotification` should not need to change when a new provider is added.
