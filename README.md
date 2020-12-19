<p align="center">
    <img src="assets/logo.png" alt="Extended Masked Text Logo" />
</p>

# Extended Masked Text

This package is based on the source code of [flutter_masked_text](https://pub.dev/packages/flutter_masked_text) and is an attempt to fix some bugs and continue the development of the original one.

## Usage

Import the library

```dart
import 'package:extended_masked_text/extended_masked_text.dart';
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