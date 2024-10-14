import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/services.dart';
import 'package:parchment_delta/parchment_delta.dart';
import '../services/api_service.dart'; // Import your ApiService
import '../models/note.dart'; // Import your Note model
import '../services/auth_service.dart'; // Import your AuthService
import 'dart:convert';
import '../providers/notes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

class AddNoteWidget extends ConsumerWidget {
  // Change to ConsumerWidget
  final Note? note; // Keep 'note' here as final

  const AddNoteWidget({Key? key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the ref in build method
    return _AddNoteWidgetContent(
        note: note, ref: ref); // Pass ref to the content
  }
}

class _AddNoteWidgetContent extends StatefulWidget {
  final Note? note;
  final WidgetRef ref; // Add reference to WidgetRef

  const _AddNoteWidgetContent({Key? key, this.note, required this.ref})
      : super(key: key);

  @override
  _AddNoteWidgetContentState createState() => _AddNoteWidgetContentState();
}

class _AddNoteWidgetContentState extends State<_AddNoteWidgetContent> {
  final TextEditingController titleController = TextEditingController();
  FleatherController? _controller;
  String? _token;
  Note? _currentNote; // Local variable to store the current note

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note; // Initialize _currentNote with widget's note
    _getToken();

    // Initialize title and content if editing an existing note
    if (_currentNote != null) {
      titleController.text = _currentNote!.title;

      // Decode the content from the note and set the document
      if (_currentNote!.content.isNotEmpty) {
        dynamic content = jsonDecode(_currentNote!.content);
        _setDocumentFromJson(content);
      }
    } else {
      _initController(); // Call only when adding a new note (not editing)
    }
  }

  Future<void> _initController() async {
    try {
      final result = await rootBundle.loadString('assets/welcome.json');
      final heuristics = ParchmentHeuristics(
        formatRules: [],
        insertRules: [],
        deleteRules: [],
      ).merge(ParchmentHeuristics.fallback);
      final doc = ParchmentDocument.fromJson(
        jsonDecode(result) as List<dynamic>, // Ensure this is a List
        heuristics: heuristics,
      );
      _controller = FleatherController(document: doc);
    } catch (err, st) {
      print('Cannot read welcome.json: $err\n$st');
      _controller = FleatherController(); // Initialize with an empty document
    }
    setState(() {});
  }

  void _setDocumentFromJson(dynamic content) {
    print('Raw content received: $content');

    try {
      // If the content is a string, parse it to JSON
      final List<dynamic> parsedContent = content is String
          ? jsonDecode(content)
          : content; // Handle pre-parsed List<dynamic>

      // Initialize an empty Delta
      final delta = Delta();

      // Iterate through the parsed content and populate the Delta
      for (var item in parsedContent) {
        if (item is Map<String, dynamic> && item.containsKey('insert')) {
          // Check if there are attributes like bold and pass them as well
          Map<String, dynamic>? attributes;
          if (item.containsKey('attributes')) {
            attributes = Map<String, dynamic>.from(item['attributes']);
          }

          // Insert the text with any associated attributes
          delta.insert(item['insert'], attributes);
        } else {
          print('Unrecognized content format: $item');
        }
      }

      // Create a new ParchmentDocument from the Delta and set the controller
      final newDocument = ParchmentDocument.fromDelta(delta);
      _controller = FleatherController(document: newDocument);
      print('Successfully created document from raw content.');
    } catch (e) {
      print('Failed to create document: $e');
      _controller = FleatherController(); // Fallback to an empty document
    }

    setState(() {});
  }

  Future<void> _getToken() async {
    final authService = AuthService();
    _token = await authService.getToken();
  }

  @override
  void dispose() {
    titleController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _saveOrUpdateNote() async {
    final title = titleController.text.isEmpty ? '' : titleController.text;
    final content = _controller?.document;

    String contentJson = jsonEncode(content?.toJson() ?? []);

    if (_token != null) {
      try {
        final isEditing = _currentNote != null && _currentNote!.id.isNotEmpty;

        final note = Note(
          id: isEditing ? _currentNote!.id : '',
          title: title,
          content: contentJson,
          createdAt: isEditing ? _currentNote!.createdAt : DateTime.now(),
        );

        final notesNotifier =
            widget.ref.read(notesProvider(_token!).notifier); // Use ref here
        await notesNotifier.addOrUpdateNote(note); // Add or update note

        // Dismiss the keyboard
        FocusScope.of(context).unfocus();

        // Optionally show a Snackbar to confirm save
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
    }
  }

  void _resetEditor() {
    _controller = FleatherController();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentNote == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveOrUpdateNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 4),
          Expanded(
            child: _controller == null
                ? Center(child: const CircularProgressIndicator())
                : FleatherEditor(
                    controller: _controller!,
                    focusNode: FocusNode(),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
          ),
          _controller == null
              ? SizedBox.shrink()
              : Container(
                  color: Colors.grey[200],
                  child: FleatherToolbar.basic(controller: _controller!),
                ),
        ],
      ),
    );
  }
}
