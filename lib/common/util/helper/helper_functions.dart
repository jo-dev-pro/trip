import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class JHelperFunctions {
  
  static String formatDate(DateTime date) {
      return DateFormat('yy/MM/dd').format(date);
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
