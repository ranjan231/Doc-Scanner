import 'package:flutter/material.dart';

class ShowAlert {
  // Custom Alert Dialog with Yes/No and Callbacks
  static void showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onYes, // Callback for Yes
    required VoidCallback onNo, // Callback for No
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                onYes(); // Execute Yes callback
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                onNo(); // Execute No callback
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }
}
