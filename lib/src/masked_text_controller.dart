import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
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

  /// Indicates what was the last text inputted by the user with mask
  String _lastUpdatedText = '';

  /// Indicates where the last cursor position was
  int _lastCursor = 0;

  /// This flag indicates if the curosr update is pending after a [updateText]
  bool _cursorUpdatePending = false;

  /// Cursor calculated in [updateText] call
  int _cursorCalculatedPosition = 0;

  /// Save previous mask used to check for update
  String? _previousMask;

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

  /// Lock to prevent multiple calls, since it needs some shared variables
  bool _lockProcess = false;

  /// Check for user updates in the TextField
  void _listener() {
    print('${selection.baseOffset}');
    if (!_lockProcess) {
      try {
        _lockProcess = true;

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

        // this is called in next iteration, after updateText is called
        if (_cursorUpdatePending &&
            selection.baseOffset != _cursorCalculatedPosition) {
          _moveCursor(_cursorCalculatedPosition);
          _cursorUpdatePending = false;
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
      } finally {
        _lockProcess = false;
      }
    }
  }

  /// Replaces [mask] with a [newMask] and moves cursor to the end if
  /// [shouldMoveCursorToEnd] is true
  /// [shouldUpdateValue] Set to true to request a following update in the text.
  ///   If this method is being called in [beforeChange] this MUST be false,
  ///   since it will call [updateText] as next step automatically.
  void updateMask(
    String newMask, {
    bool shouldMoveCursorToEnd = true,
    bool shouldUpdateValue = false,
  }) {
    if (mask != newMask) {
      _previousMask = mask;
      mask = newMask;

      if (shouldUpdateValue) {
        updateText(text);
      }

      if (shouldMoveCursorToEnd) {
        moveCursorToEnd();
      }
    }
  }

  /// Updates the current [text] with a new one applying the [mask]
  void updateText(String newText) {
    // save values for possible concurrent updates
    final _oldMask = _previousMask ?? mask;
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

    _previousMask = mask;
    text = _lastUpdatedText;

    // Mark to update in next listner iteration
    _cursorUpdatePending = true;
    _cursorCalculatedPosition = newCursor;
    _moveCursor(_cursorCalculatedPosition);
  }

  /// Moves cursor to the end of the text
  void moveCursorToEnd() => _moveCursor(_lastUpdatedText.length, true);

  /// Retrieve current value without mask
  String get unmasked => _removeMask(mask, text);

  /// Unmask the [text] given a [mask]
  String unmask(String mask, String text) => _removeMask(mask, text);

  /// Moves cursor to specific position
  void _moveCursor(int index, [bool force = false]) {
    // only moves the cursor if it is not defined or text is not selected
    if (force || selection.baseOffset == selection.extentOffset) {
      final value = min(max(index, 0), text.length);
      selection = TextSelection.collapsed(offset: value);
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
    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (maskCharIndex != mask.length && valueCharIndex != value.length) {
      final maskChar = mask[maskCharIndex];
      final valueChar = value[valueCharIndex];

      // apply translator if match with the current mask character
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar]!.hasMatch(valueChar)) {
          result.write(valueChar);
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not a masked value, jump fixed char on mask
      maskCharIndex += 1;
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

    // NOTE: This is a bugfix for iOS platform.
    // When deleting one character, the listenner method will trigger a cursor
    // update before triggering the text update, to compensate that, this
    // condition return the cursor for the previous location before calculation.
    if (!kIsWeb && Platform.isIOS && newUnmask.length == oldUnmask.length - 1) {
      oldUnmaskCursor++;
    }

    for (var k = 0; k < oldCursor && k < oldMask.length; k++) {
      if (!translator.containsKey(oldMask[k])) {
        oldUnmaskCursor--;
      }
    }

    // count how many new characters was added
    var unmaskNewChars = newUnmask.length - oldUnmask.length;
    if (unmaskNewChars == 0 &&
        oldMask == newMask &&
        oldText != newText &&
        oldText.length == newText.length &&
        oldCursor < oldMask.length) {
      // the next character was update, move cursor
      unmaskNewChars++;
    }

    // find new cursor position based on new mask
    var countDown = oldUnmaskCursor + unmaskNewChars;
    var maskCount = 0;
    for (var i = 0;
        i < newText.length && i < newMask.length && countDown > 0;
        i++) {
      if (!translator.containsKey(newMask[i])) {
        maskCount++;
      } else {
        countDown--;
      }
    }

    return oldUnmaskCursor + maskCount + unmaskNewChars;
  }
}
