# extended_masked_text

A small set of custom TextEditingControllers that allows masked text inputs for flutter apps

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