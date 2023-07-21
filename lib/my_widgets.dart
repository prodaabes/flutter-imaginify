import 'package:flutter/material.dart';

class MyWidgets {
  static showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showAlertDialog(
    BuildContext context,
    String title,
    String message,
    String negativeText,
    Function() negativeCallback,
    String? positiveText,
    Function()? positiveCallback,
  ) {
    List<Widget> buttons = [];

    // set up the negative button
    Widget negativeButton = TextButton(
      onPressed: negativeCallback,
      child: Text(negativeText)
    );
    buttons.add(negativeButton);

    if (positiveCallback != null) {
      // set up the positive button
      Widget positiveButton = TextButton(
          onPressed: positiveCallback,
          child: Text(positiveText!)
      );
      buttons.add(positiveButton);
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: buttons
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}