# MOJ WSS Notification Chat

A Flutter evaluation app that demonstrates Clean Architecture, SOLID principles,
runtime notification provider switching, `get_it` dependency injection, Cubit
state management, localization-ready UI strings, and polished list rendering in
a chat-style notification surface.

## Requirements

- Flutter 3.38.3 or compatible stable release
- Dart 3.10.1 or compatible SDK from Flutter

## Run

Install packages:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

The default `lib/main.dart` entrypoint boots the production environment.

## Flavors

The app has three runtime environments:

- `development`
- `staging`
- `production`

Dart entrypoints live at:

- `lib/main_development.dart`
- `lib/main_staging.dart`
- `lib/main_production.dart`

Android product flavors are configured in `android/app/build.gradle.kts` with
environment-specific application ids and launcher names:

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor production -t lib/main_production.dart
```

Production build example:

```bash
flutter build apk --flavor production -t lib/main_production.dart --release
```

For platforms without native schemes configured, select the runtime environment
with the Dart target:

```bash
flutter run -t lib/main_staging.dart
```

## Verify

Run all tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Format source and tests:

```bash
dart format lib test
```

## Architecture

The notification feature uses a balanced Clean Architecture structure:

- `domain`: entities, repository contracts, channel contracts, and
  typed notification failures.
- `application`: provider registry and `SendNotification` use case.
- `data`: simulated Email, SMS, and Push channel implementations plus the
  in-memory history repository.
- `presentation`: Cubit state management, one-screen dashboard, conversation
  transcript, compose sheet, responsive layout metrics, and theme.
- `core/di/service_locator.dart`: app-level composition root backed by `get_it`.
- `core/config/app_environment.dart`: flavor/environment metadata registered in
  DI.
- `features/notifications/di/notification_di.dart`: feature-level DI module
  that wires providers, storage, use cases, Cubit factories, and presentation
  metadata.

The UI depends on the Cubit. The Cubit depends on the use case. The use case
depends on domain abstractions and a registry of notification strategies.
Concrete providers sit behind the shared `NotificationChannel` interface. The
domain layer has no Flutter dependency and never accesses the service locator.
`get_it` is confined to composition and app wiring.

## SOLID And Patterns

- Single Responsibility: validation, provider lookup, sending, storage, state,
  and rendering are split into focused classes.
- Open/Closed: new channels can be added without changing `SendNotification`.
- Liskov Substitution: all providers implement the same `NotificationChannel`
  contract.
- Interface Segregation: repository and channel contracts expose only the
  methods their consumers need.
- Dependency Inversion: application logic depends on abstractions, not concrete
  Email/SMS/Push classes.

The notification providers use the Strategy pattern. Runtime switching is done
by `ChannelRegistry`, which resolves the selected channel id to its registered
provider. `SendNotification` validates common required fields, delegates
recipient-format validation to the selected channel, sends with a timeout,
preserves the provider receipt, and records history.

The presentation layer uses an Abstract Factory and Bridge-style boundary for
channel visuals. Widgets ask `NotificationChannelPresentationFactory` for icon,
SF Symbol, keyboard, and hint metadata instead of hardcoding provider-specific
UI decisions inside dashboard or composer widgets. Concrete visual specs are
registered in the notification DI module, so unknown providers can still render
with a fallback icon.

## State Management

`NotificationCubit` owns:

- selected notification type
- available channel metadata
- history list
- submit status
- recipient validation error
- message validation error
- general send error

The Cubit receives `SendNotification` and `LoadNotificationHistory` through DI.
It loads repository history on app startup, ignores duplicate submits while a
send is already in progress, and prepends successful sends immediately.

Public Cubit user actions are named with an `on` prefix:

- `onSelectChannel`
- `onSend`
- `onLoadHistory`

Successful sends are added newest first. Typed validation failures are mapped to
field or general errors without string matching. Validation failures do not call
the provider and do not add history. Provider exceptions, provider timeouts, and
history persistence failures are mapped to typed general failures.

## Notification Receipts

Providers return a `NotificationSendReceipt` containing:

- `providerMessageId`
- `status`
- `metadata`

`SentNotification` stores this receipt alongside the channel, recipient,
message, and timestamp. This keeps the engine backend-agnostic while preserving
gateway-specific send acknowledgement data for future diagnostics or retry
flows.

## UI Design

The UI is a mobile-first notification feed with a restrained liquid-glass
treatment:

- compact chat app bar
- top-right message filter for All, Email, SMS, and Push
- scrollable all-channel message list
- message cards with channel icons, recipient, timestamp, and content
- bottom compose sheet with channel selection, recipient field, message input,
  and send action
- `liquid_glass_renderer` surfaces for the compose sheet and filter control
- tinted ink neutrals
- restrained jade accent
- Material light/dark themes
- English localization generated from `lib/l10n/app_en.arb`
- `flutter_screenutil`-backed responsive spacing, radii, icons, and panel widths
- explicit phone, iPad portrait, and iPad landscape widget coverage

`liquid_glass_renderer` is experimental and intended here for mobile targets.
`ScreenUtilInit` is configured in `NotificationApp` with
`designSize: Size(390, 844)` and `splitScreenMode: true`; typography stays
theme-driven rather than viewport-scaled.

## Localization

The app currently ships English only through Flutter's generated localization
support:

- `l10n.yaml` configures generation.
- `lib/l10n/app_en.arb` contains English strings.
- generated `AppLocalizations` is wired into `MaterialApp`.

To add another language, create a new ARB file in `lib/l10n`, such as
`app_ar.arb`, translate every key from `app_en.arb`, then run:

```bash
flutter gen-l10n
```

Flutter updates `AppLocalizations.supportedLocales` from the ARB files.

## Adding A Provider

To add a provider such as WhatsApp:

1. Create a class implementing `NotificationChannel`.
2. Provide a stable `id`, display `label`, and `recipientInputKind`.
3. Implement `validateRecipient` for provider-specific recipient rules.
4. Implement `send` and return typed `NotificationFailure` values for failures.
5. Return a `NotificationSendReceipt` from successful sends.
6. Register the provider in `features/notifications/di/notification_di.dart`.
7. Optionally register provider-specific presentation metadata in
   `defaultNotificationChannelVisualSpecs`; the UI falls back to a notification
   icon for unknown channel ids.
8. Add unit and widget tests for the new channel.

`SendNotification` should not need to change.

## Network, Permissions, And Secrets

The current app runs in mocked offline mode:

- Email, SMS, and Push providers are simulated.
- No real gateway, backend, API key, token, or sender ID is required.
- The app can be used offline because sends are local mocks.
- There is no connectivity detection, offline queue, retry replay, or sync.
- Provider sends have a default 5-second timeout and exception mapping.

Android debug and profile manifests include `INTERNET` for Flutter tooling such
as hot reload and VM service communication. The release manifest does not need
internet permission while providers remain mocked. If real gateways are added,
add the required release permissions and platform network configuration at that
time.

No `.env` file is required for the current mock implementation. Real providers
should load sensitive values such as API keys, gateway URLs, sender IDs, and
tokens from `.env` or platform secrets. Do not commit `.env`; commit only an
`.env.example` file with placeholder keys if real providers are introduced.

## Persistence

History is intentionally in-memory because the evaluation asks for notification
logic, state updates, and list rendering. The app still loads history through
`LoadNotificationHistory` on startup, so a persistent implementation can be
introduced later by replacing `NotificationRepository` with a local database or
backend-backed repository without changing presentation logic.

## Recommended Production Enhancements

- Replace mock providers with real gateway adapters behind `NotificationChannel`.
- Add connectivity detection only when real network providers exist.
- Add offline queueing, retry replay, and sync for failed real sends.
- Add a cutoff mechanism: rate limits, quota checks, timeout policy, retry
  backoff, cancellation, and a circuit breaker.
- Persist notification history across app restarts.
- Add observability around provider latency, failure rates, and quota usage.

## Repository And Branching Plan

Recommended production branch model:

- `development`: active integration branch for feature work.
- `staging`: release-candidate branch for QA and pre-production validation.
- `production`: protected release branch for shipped builds.

Recommended setup commands from a clean local checkout:

```bash
git init
git checkout -b development
git add .
git commit -m "Initial production-ready notification app"
gh repo create ElsayedDev/moj-wss-notification --private --source=. --remote=origin --push
git branch staging
git branch production
git push -u origin development staging production
gh repo edit ElsayedDev/moj-wss-notification --default-branch development
```

Recommended merge flow:

```text
feature branches -> development -> staging -> production
```

Protect `production` with required pull requests, required status checks
(`flutter test` and `flutter analyze`), and no direct pushes.
