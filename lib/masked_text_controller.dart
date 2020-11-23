import 'package:flutter/widgets.dart';

class MaskedTextController extends TextEditingController {
  MaskedTextController({
    String text,
    this.mask,
    Map<String, RegExp> translator,
  }) : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      updateText(this.text);
    });

    _lastUpdatedText = '';
    updateText(this.text);
  }

  String mask;
  Map<String, RegExp> translator;
  String _lastUpdatedText;

  static Map<String, RegExp> getDefaultTranslator() => {
        'A': RegExp(r'[A-Za-z]'),
        '0': RegExp(r'[0-9]'),
        '@': RegExp(r'[A-Za-z0-9]'),
        '*': RegExp(r'.*')
      };

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  void updateMask(String newMask, {bool shouldMoveCursorToEnd = true}) {
    mask = newMask;
    updateText(text);

    if (shouldMoveCursorToEnd) {
      moveCursorToEnd();
    }
  }

  void updateText(String newText) {
    text = (newText != null) ? _applyMask(mask, newText) : '';
    _lastUpdatedText = text;
  }

  void moveCursorToEnd() {
    selection = TextSelection.fromPosition(
      TextPosition(offset: (_lastUpdatedText ?? '').length),
    );
  }

  String _applyMask(String mask, String value) {
    final result = StringBuffer('');
    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (maskCharIndex != mask.length && valueCharIndex != value.length) {
      final maskChar = mask[maskCharIndex];
      final valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result.write(maskChar);
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar].hasMatch(valueChar)) {
          result.write(valueChar);
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result.write(maskChar);
      maskCharIndex += 1;
      continue;
    }

    return result.toString();
  }
}
