<p align="center">
    <img src="https://raw.githubusercontent.com/LeandroNovak/extended_masked_text/main/assets/logo.png" alt="Extended Masked Text Logo" />
</p>

# Extended Masked Text

This package is based on the source code of [flutter_masked_text](https://pub.dev/packages/flutter_masked_text) and is an attempt to fix some bugs and continue the development of the original one.

## Requirements

- Flutter 3.47.0 or later (validated with Flutter 3.47.9).
- Dart 3.13.0 or later, below 4.0.0.

The controllers depend only on Flutter's widgets library. The example uses the
standalone `material_ui` package for Material Design widgets.

For native example builds, use Java 17 or later, Android API 24 or later,
iOS 15 or later, and macOS 12 or later.

To validate the library and example:

```sh
flutter pub get
flutter analyze
flutter test
cd example
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

## Usage

Import the library and, when using Material widgets, add `material_ui` to your
application dependencies:

```dart
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:material_ui/material_ui.dart';
```

## MaskedTextController

Create your mask controller:

```dart
final controller = MaskedTextController(mask: '000.000.000-00');
```

Set controller to your text field:

```dart
return MaterialApp(
    title: 'Masked Text Demo',
    theme: ThemeData(
        primarySwatch: Colors.blue,
    ),
    home: SafeArea(
        child: Scaffold(
            body: Column(
                children: <Widget>[
                    TextField(
                        // Add controller to TextField
                        controller: controller,
                    ),
                ],
            ),
        ),
    ),
);
```

## MoneyMaskedTextController

Create your mask controller:

```dart
final controller = MoneyMaskedTextController(leftSymbol: 'R\$ ');
```

Set controller to your text field:

```dart
return MaterialApp(
    title: 'Money Masked Text Demo',
    theme: ThemeData(
        primarySwatch: Colors.blue,
    ),
    home: SafeArea(
        child: Scaffold(
            body: Column(
                children: <Widget>[
                    TextField(
                        // Add controller to TextField
                        controller: controller,
                    ),
                ],
            ),
        ),
    ),
);
```
