import 'dart:math';

import 'package:flutter/widgets.dart';

typedef BeforeChangeCallback = bool Function(String previous, String next);
typedef AfterChangeCallback = void Function(String previous, String next);

enum CursorBehaviour {
  unlocked,
  start,
  end,
}

/// A [TextEditingController] extended to provide custom masks to flutter
class MaskedTextController extends TextEditingController {
  MaskedTextController({
    required this.mask,
    this.beforeChange,
    this.afterChange,
    this.cursorBehavior = CursorBehaviour.unlocked,
    String? text,
    Map<String, RegExp>? translator,
  }) : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    // Initialize the beforeChange and afterChange callbacks if they are null
    beforeChange ??= (previous, next) => true;
    afterChange ??= (previous, next) {};

    addListener(_listener);
    _lastCursor = this.text.length;
    updateText(this.text);
  }

  /// The current applied mask
  String mask;

  /// Translator from mask characters to [RegExp]
  late Map<String, RegExp> translator;

  /// A function called before the text is updated.
  /// Returns a boolean informing whether the text should be updated.
  ///
  /// Defaults to a function returning true
  BeforeChangeCallback? beforeChange;

  /// A function called after the text is updated
  ///
  /// Defaults to an empty function
  AfterChangeCallback? afterChange;

  /// Configure if the cursor should be forced
  CursorBehaviour cursorBehavior;

  String _lastUpdatedText = '';

  int _lastCursor = 0;

  /// Default [RegExp] for each character available for the mask
  ///
  /// 'A' represents a letter of the alphabet
  /// '0' represents a numeric character
  /// '@' represents a alphanumeric character
  /// '*' represents any character
  static Map<String, RegExp> getDefaultTranslator() => {
        'A': RegExp(r'[A-Za-z]'),
        '0': RegExp(r'[0-9]'),
        '@': RegExp(r'[A-Za-z0-9]'),
        '*': RegExp(r'.*')
      };

  /// Corresponding to [TextEditingController.text]
  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
    }
  }

  /// Check for user updates in the TextField
  void _listener() {
    // only changing the text
    if (text != _lastUpdatedText) {
      final previous = _lastUpdatedText;
      if (beforeChange!(previous, text)) {
        updateText(text);
        afterChange!(previous, text);
      } else {
        updateText(_lastUpdatedText);
      }
    }

    if (cursorBehavior != CursorBehaviour.unlocked) {
      cursorBehavior == CursorBehaviour.start
          ? _moveCursor(0, true)
          : _moveCursor(_lastUpdatedText.length, true);
    }

    // only changing cursor position
    if (_lastCursor != selection.baseOffset && selection.baseOffset > -1) {
      _lastCursor = selection.baseOffset;
    }
  }

  String? previousMask;

  /// Replaces [mask] with a [newMask] and moves cursor to the end if
  /// [shouldMoveCursorToEnd] is true
  void updateMask(String newMask, {bool shouldMoveCursorToEnd = true}) {
    previousMask = mask;
    mask = newMask;
    updateText(text);

    if (shouldMoveCursorToEnd) {
      moveCursorToEnd();
    }
  }

  /// Updates the current [text] with a new one applying the [mask]
  void updateText(String newText) {
    // save values for possible concurrent updates
    final _oldMask = previousMask ?? mask;
    final _mask = mask;
    final oldText = _lastUpdatedText;
    final previousCursor = _lastCursor;

    _lastUpdatedText = _applyMask(_mask, newText);
    final newCursor = _calculateCursorPosition(
      previousCursor,
      _oldMask,
      _mask,
      oldText,
      _lastUpdatedText,
    );

    previousMask = mask;
    text = _lastUpdatedText;
    // To avoid concurrent cursor update uppon text update, it is desired
    // to delay this update to ensure that the update occurs correctly
    Future.delayed(Duration.zero).then((value) => _moveCursor(newCursor));
  }

  /// Moves cursor to the end of the text
  void moveCursorToEnd() => _moveCursor(_lastUpdatedText.length, true);

  /// Moves cursor to specific position
  void _moveCursor(int index, [bool force = false]) {
    // only moves the cursor if it is not defined or text is not selected
    if (force || selection.baseOffset == selection.extentOffset) {
      final value = min(max(index, 0), _lastUpdatedText.length);
      selection = TextSelection.fromPosition(
        TextPosition(offset: value),
      );
      _lastCursor = value;
    }
  }

  /// Applies the [mask] to the [value]
  String _applyMask(String mask, String value) {
    final result = StringBuffer('');
    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (maskCharIndex != mask.length && valueCharIndex != value.length) {
      final maskChar = mask[maskCharIndex];
      final valueChar = value[valueCharIndex];

      // value equals mask, just write value to the buffer
      if (maskChar == valueChar) {
        result.write(maskChar);
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match with the current mask character
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar]!.hasMatch(valueChar)) {
          result.write(valueChar);
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }
      // not a masked value, fixed char on mask
      result.write(maskChar);
      maskCharIndex += 1;
    }
    return result.toString();
  }

  /// Removes the [mask] from the [value]
  String _removeMask(String mask, String value) {
    final result = StringBuffer('');
    var charIndex = 0;

    while (charIndex < mask.length && charIndex < value.length) {
      final maskChar = mask[charIndex];
      final valueChar = value[charIndex];

      // apply translator if match with the current mask character
      if (translator.containsKey(maskChar)
          && translator[maskChar]!.hasMatch(valueChar)) {
        result.write(valueChar);
      }

      charIndex += 1;
    }

    return result.toString();
  }

  /// Calculates next cursor position from given text alteration
  int _calculateCursorPosition(
    int oldCursor,
    String oldMask,
    String newMask,
    String oldText,
    String newText,
  ) {
    // it is better to remove mask since user can use inputFormatters
    // generating unknown alteration before listener is called
    final oldUnmask = _removeMask(oldMask, oldText);
    final newUnmask = _removeMask(newMask, newText);

    // find cursor when old text is unmask
    var oldUnmaskCursor = oldCursor;
    for (var k = 0; k < oldCursor && k < oldMask.length; k++) {
      if (!translator.containsKey(oldMask[k])) {
        oldUnmaskCursor--;
      }
    }

    // count how many new characters was added
    var newChars = newUnmask.length - oldUnmask.length;
    if (newChars == 0 &&
        oldMask == newMask &&
        oldText != newText &&
        oldText.length == newText.length &&
        oldCursor < oldMask.length) {
      // the next character was update, move cursor
      newChars++;
    }

    // find new cursor position based on new mask
    var countDown = oldUnmaskCursor + newChars;
    var maskCount = 0;
    for (var i = 0;
        i < newText.length && i < newMask.length && countDown >= 0;
        i++) {
      if (!translator.containsKey(newMask[i])) {
        maskCount++;
      } else {
        countDown--;
      }
    }

    return oldUnmaskCursor + maskCount + newChars;
  }
}
