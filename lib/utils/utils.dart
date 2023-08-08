import 'package:flutter/material.dart';

import '../views/text_widget.dart';

class Utils {
  BuildContext context;
  Utils(this.context);
  Size get screenSize => MediaQuery.of(context).size;
}
