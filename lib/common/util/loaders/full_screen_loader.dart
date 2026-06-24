import 'package:flutter/material.dart';

/// A utility class for managing a full-screen loading dialog.
class JFullScreenLoader {
  /// Stop the currently open loading dialog.
  /// This method doesn't return anything.
  static void stopLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } // Close the dialog using the Navigator
  }
}
