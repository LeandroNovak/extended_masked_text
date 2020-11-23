import 'package:flutter/widgets.dart';

class MoneyMaskedTextController extends TextEditingController {
  MoneyMaskedTextController({
    double initialValue,
    this.decimalSeparator = ',',
    this.thousandSeparator = '.',
    this.rightSymbol = '',
    this.leftSymbol = '',
    this.precision = 2,
  }) {
    _validateConfig();

    addListener(() {
      updateValue(numberValue);
    });

    _lastValue = 0;
    updateValue(initialValue);
  }

  final String decimalSeparator;
  final String thousandSeparator;
  final String rightSymbol;
  final String leftSymbol;
  final int precision;

  double _lastValue;
  double get numberValue {
    final parts = _getOnlyNumbers(text).split('').toList(growable: true);

    if (parts.length > precision) {
      parts.insert(parts.length - precision, '.');
      return double.parse(parts.join());
    } else {
      return 0;
    }
  }

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

    if (masked != text) {
      text = masked;

      final cursorPosition = super.text.length - rightSymbol.length;
      selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      );
    }
  }

  void _validateConfig() {
    final rightSymbolHasNumbers = _getOnlyNumbers(rightSymbol).isNotEmpty;

    if (rightSymbolHasNumbers) {
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
