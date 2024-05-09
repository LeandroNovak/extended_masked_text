/// An enum representing the expected behavior to the cursor
enum CursorBehavior {
  /// [unlocked] allows the user to freely change the cursor position
  unlocked,

  /// [end] forces the input to be in LTR
  end,
}

/// An enum representing the expected behavior to the cursor
@Deprecated(
  'Migrate to [CursorBehavior], notice the missing "u" letter. '
  'Will be removed in the next release',
)
typedef CursorBehaviour = CursorBehavior;
