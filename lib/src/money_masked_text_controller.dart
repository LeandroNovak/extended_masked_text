import 'package:flutter/widgets.dart';

/// A [TextEditingController] extended to apply masks to currency values
class MoneyMaskedTextController extends TextEditingController {
  MoneyMaskedTextController({
    double initialValue,
    this.decimalSeparator = ',',
    this.thousandSeparator = '.',
    this.rightSymbol = '',
    this.leftSymbol = '',
    this.precision = 2,
  })  : assert(decimalSeparator != null),
        assert(thousandSeparator != null),
        assert(rightSymbol != null),
        assert(leftSymbol != null),
        assert(precision != null) {
    _validateConfig();
    _shouldApplyTheMask = true;

    addListener(() {
      if (_shouldApplyTheMask) {
        var parts = _getOnlyNumbers(text).split('').toList(growable: true);

        if (parts.isNotEmpty) {
          // Ensures that the list of parts contains the minimum amount of
          // characters to fit the precision
          if (parts.length < precision + 1) {
            parts = [...List.filled(precision, '0'), ...parts];
          }

          parts.insert(parts.length - precision, '.');
          updateValue(double.parse(parts.join()));
        }
      }
    });

    updateValue(initialValue);
  }

  /// Character used as decimal separator
  ///
  /// Defaults to ',' and must not be null.
  final String decimalSeparator;

  /// Character used as thousand separator
  ///
  /// Defaults to '.' and must not be null.
  final String thousandSeparator;

  /// Character used as right symbol
  ///
  /// Defaults to empty string. Must not be null.
  final String rightSymbol;

  /// Character used as left symbol
  ///
  /// Defaults to empty string. Must not be null.
  final String leftSymbol;

  /// Numeric precision to fraction digits
  ///
  /// Defaults to 2
  final int precision;

  /// The last valid numeric value
  double _lastValue;

  /// Used to ensure that the listener will not try to update the mask when
  /// updating the text internally, thus reducing the number of operations when
  /// applying a mask (works as a mutex)
  bool _shouldApplyTheMask;

  /// The numeric value of the text
  double get numberValue {
    final parts = _getOnlyNumbers(text).split('').toList(growable: true);

    if (parts.isEmpty) {
      return 0;
    }

    parts.insert(parts.length - precision, '.');
    return double.parse(parts.join());
  }

  /// Updates the value and applies the mask
  void updateValue(double value) {
    if (value == null) {
      return;
    }

    var valueToUse = value;

    if (value.toStringAsFixed(0).length > 12) {
      valueToUse = _lastValue;
    } else {
      _lastValue = value;
    }

    var masked = _applyMask(valueToUse);

    if (rightSymbol.isNotEmpty) {
      masked += rightSymbol;
    }

    if (leftSymbol.isNotEmpty) {
      masked = leftSymbol + masked;
    }

    _updateText(masked);
  }

  void _updateText(String newText) {
    if (text != newText) {
      _shouldApplyTheMask = false;
      text = newText;
      _shouldApplyTheMask = true;

      _updateCursorPosition();
    }
  }

  /// Moves the cursor
  void _updateCursorPosition() {
    final cursorPosition = text.length - rightSymbol.length;
    selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition),
    );
  }

  /// Ensures [rightSymbol] does not contains numbers
  void _validateConfig() {
    if (_getOnlyNumbers(rightSymbol).isNotEmpty) {
      throw ArgumentError('rightSymbol must not have numbers.');
    }
  }

  String _getOnlyNumbers(String text) => text.replaceAll(RegExp(r'[^\d]'), '');

  String _applyMask(double value) {
    final textRepresentation = value
        .toStringAsFixed(precision)
        .replaceAll('.', '')
        .split('')
        .reversed
        .toList(growable: true);

    textRepresentation.insert(precision, decimalSeparator);

    for (var i = precision + 4; textRepresentation.length > i; i += 4) {
      if (textRepresentation.length > i) {
        textRepresentation.insert(i, thousandSeparator);
      }
    }

    return textRepresentation.reversed.join('');
  }
}
