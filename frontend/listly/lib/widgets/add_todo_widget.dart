import 'package:flutter/material.dart';

class AddToDoWidget extends StatelessWidget {
  final VoidCallback onClose; // For handling close action
  final TextEditingController textController;
  final VoidCallback onSave; // For handling save action

  AddToDoWidget({
    required this.onClose,
    required this.textController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -3),
              blurRadius: 6,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New To-do',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Add a to-do item',
                border: OutlineInputBorder(),
              ),
              autofocus: true, // Automatically shows the keyboard
            ),
            SizedBox(height: 16),
            // Align the Save button to the right
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to the end
              children: [
                ElevatedButton(
                  onPressed: onSave,
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFFFF725E), // Custom color for the button
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
