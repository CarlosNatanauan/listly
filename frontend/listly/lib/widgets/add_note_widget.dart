// add_notes_widget.dart
import 'package:flutter/material.dart';

class AddNotesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Notes'),
      ),
      body: Center(
        child: Text(
          'This is the Add Notes screen.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
