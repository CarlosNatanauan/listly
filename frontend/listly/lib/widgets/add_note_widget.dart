import 'package:flutter/material.dart';

class AddNoteWidget extends StatefulWidget {
  @override
  _AddNoteWidgetState createState() => _AddNoteWidgetState();
}

class _AddNoteWidgetState extends State<AddNoteWidget> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  // Formatting states
  bool isBold = false;
  bool isItalic = false;
  bool isStrikethrough = false;
  bool isUnderline = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = titleController.text;
    final content = contentController.text;

    print('Title: $title');
    print('Content: $content');

    // Clear fields after saving
    titleController.clear();
    contentController.clear();
  }

  void _toggleBold() {
    setState(() {
      isBold = !isBold;
    });
    _applyTextStyle();
  }

  void _toggleItalic() {
    setState(() {
      isItalic = !isItalic;
    });
    _applyTextStyle();
  }

  void _toggleStrikethrough() {
    setState(() {
      isStrikethrough = !isStrikethrough;
    });
    _applyTextStyle();
  }

  void _toggleUnderline() {
    setState(() {
      isUnderline = !isUnderline;
    });
    _applyTextStyle();
  }

  void _applyTextStyle() {
    final selection = contentController.selection;
    // If no text is selected, do nothing
    if (selection.start == selection.end) return;

    String text = contentController.text;
    String selectedText = text.substring(selection.start, selection.end);

    // Apply formatting based on current states
    String formattedText = selectedText;
    if (isBold) {
      formattedText = "**$formattedText**"; // Represent bold
    }
    if (isItalic) {
      formattedText = "*$formattedText*"; // Represent italic
    }
    if (isStrikethrough) {
      formattedText = "~~$formattedText~~"; // Represent strikethrough
    }
    if (isUnderline) {
      formattedText = "__$formattedText"; // Represent underline
    }

    // Replace the selected text with the formatted text
    text = text.replaceRange(selection.start, selection.end, formattedText);

    // Update the content text with new formatting
    contentController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
          offset: selection.start + formattedText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: isStrikethrough
                      ? TextDecoration.lineThrough
                      : isUnderline
                          ? TextDecoration.underline
                          : TextDecoration.none,
                ),
                onChanged: (text) {
                  // Reset formatting when typing new text
                  if (text.isNotEmpty) {
                    // Reset all formatting if new text is typed
                    setState(() {
                      isBold = false;
                      isItalic = false;
                      isStrikethrough = false;
                      isUnderline = false;
                    });
                  }
                },
              ),
            ),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.format_bold,
              color: isBold ? Colors.blue : Colors.black,
            ),
            onPressed: _toggleBold,
          ),
          IconButton(
            icon: Icon(
              Icons.format_italic,
              color: isItalic ? Colors.blue : Colors.black,
            ),
            onPressed: _toggleItalic,
          ),
          IconButton(
            icon: Icon(
              Icons.format_strikethrough,
              color: isStrikethrough ? Colors.blue : Colors.black,
            ),
            onPressed: _toggleStrikethrough,
          ),
          IconButton(
            icon: Icon(
              Icons.format_underline,
              color: isUnderline ? Colors.blue : Colors.black,
            ),
            onPressed: _toggleUnderline,
          ),
        ],
      ),
    );
  }
}
