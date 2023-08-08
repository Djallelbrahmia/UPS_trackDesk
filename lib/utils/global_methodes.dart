import 'package:flutter/material.dart';

import '../views/text_widget.dart';

class GlobalMethods {
  static Future<void> WarningDialog(
      {required String title,
      required String subtitle,
      required Function fct,
      required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Image.asset(
                "assets/img/warning-sign.png",
                height: 24,
                width: 24,
                fit: BoxFit.fill,
              ),
              const SizedBox(
                width: 16,
              ),
              Text(title)
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              child: const TextWidget(
                text: "Cancel",
                color: Colors.cyan,
                textsize: 20,
              ),
            ),
            TextButton(
              onPressed: () async {
                fct();
              },
              child: const TextWidget(
                text: "Yes",
                color: Colors.red,
                textsize: 20,
              ),
            ),
          ],
          content: Text(subtitle),
        );
      },
    );
  }

  static Future<void> ErrorDialog(
      {required String subtitle, required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Image.asset(
                "assets/img/warning-sign.png",
                height: 24,
                width: 24,
                fit: BoxFit.fill,
              ),
              const SizedBox(
                width: 16,
              ),
              const Text("An Error Occured")
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              child: const TextWidget(
                text: "Ok",
                color: Colors.cyan,
                textsize: 20,
              ),
            ),
          ],
          content: Text(subtitle),
        );
      },
    );
  }
}
