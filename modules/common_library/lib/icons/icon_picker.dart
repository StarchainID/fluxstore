import 'package:flutter/material.dart';

import 'cupertino.dart';
import 'line_icons.dart';
import 'material.dart';

IconData? iconPicker(String name, String fontFamily) {
  switch (fontFamily) {
    case 'CupertinoIcons':
      return cupertinoIcons[name];
    case 'LineAwesomeIcons':
      return lineAwesomeIcons[name];
    default:
      return materialIcon[name];
  }
}

String iconPickerName(IconData icon) {
  return 'Icon';
}
