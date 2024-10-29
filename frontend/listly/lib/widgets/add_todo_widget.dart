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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            TextField(
              controller: textController,
              cursorColor: Color(0xFFFF725E),
              decoration: InputDecoration(
                hintText: 'Add a to-do item',
                floatingLabelStyle: TextStyle(color: Color(0xFFFF725E)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF725E)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF725E)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onSave,
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF725E),
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
