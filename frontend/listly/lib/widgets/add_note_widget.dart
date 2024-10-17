import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/services.dart';
import 'package:parchment_delta/parchment_delta.dart';
import '../models/note.dart'; // Import your Note model
import 'dart:convert';
import '../providers/notes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../services/socket_service_notes.dart'; // Import SocketService
import '../providers/socket_service_provider.dart';
import '../providers/auth_providers.dart'; // Import the AuthService provider

class AddNoteWidget extends ConsumerWidget {
  final Note? note; // Keep 'note' here as final

  const AddNoteWidget({Key? key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
  Note? _currentNote;
  late SocketService socketService;
  bool isEditing = false; // Track if the note is in edit mode

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _getToken();
    socketService = widget.ref
        .read(socketServiceProvider); // Get the globally initialized socket

    // Initialize title and content if editing an existing note
    if (_currentNote != null) {
      titleController.text = _currentNote!.title;
      if (_currentNote!.content.isNotEmpty) {
        dynamic content = jsonDecode(_currentNote!.content);
        _setDocumentFromJson(content);
      }
      isEditing = true; // Set to editing mode after initialization
      _listenForNoteUpdates(); // Listen for updates
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
          jsonDecode(result) as List<dynamic>,
          heuristics: heuristics);
      _controller = FleatherController(document: doc);
    } catch (err, st) {
      print('Cannot read welcome.json: $err\n$st');
      _controller = FleatherController(); // Initialize with an empty document
    }
    setState(() {});
  }

  void _setDocumentFromJson(dynamic content) {
    try {
      final List<dynamic> parsedContent =
          content is String ? jsonDecode(content) : content;
      final delta = Delta();
      for (var item in parsedContent) {
        if (item is Map<String, dynamic> && item.containsKey('insert')) {
          delta.insert(item['insert'], item['attributes'] ?? {});
        }
      }
      final newDocument = ParchmentDocument.fromDelta(delta);
      _controller = FleatherController(document: newDocument);
    } catch (e) {
      _controller = FleatherController();
    }
    setState(() {});
  }

  Future<void> _getToken() async {
    final authService = widget.ref.read(authServiceProvider);
    _token = await authService.getToken();

    if (_token != null) {
      socketService.connect(
          _token!, _handleNoteUpdate); // Pass the token and callback function
    } else {
      print('Token not found, unable to connect to socket.');
    }
  }

  void _handleNoteUpdate(Note updatedNote) {
    if (_currentNote != null && _currentNote!.id == updatedNote.id) {
      // Update the current note if it matches the updated one
      _setDocumentFromJson(jsonDecode(updatedNote.content));
      titleController.text = updatedNote.title;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note updated remotely')),
      );
    }
  }

  void _listenForNoteUpdates() {
    if (_currentNote != null && _currentNote!.id.isNotEmpty) {
      socketService.onNoteUpdate(_currentNote!.id, _handleNoteUpdate);
    }
  }

  void _saveOrUpdateNote() async {
    final title = titleController.text.isEmpty
        ? ''
        : titleController.text; // Ensure there's always a title
    final content = _controller?.document;

    // Check if content is null, otherwise use an empty document
    String contentJson = content != null ? jsonEncode(content.toJson()) : '[]';

    print('Saving note with title: $title');
    print('Content JSON: $contentJson');

    if (_token != null) {
      try {
        // Check if we're editing an existing note or adding a new one
        final isEditingNow =
            _currentNote != null && _currentNote!.id.isNotEmpty;

        // Create the note object, ensuring all fields are non-null
        final note = Note(
          id: isEditingNow
              ? _currentNote!.id
              : '', // Retain the note's ID if editing, otherwise create new note with empty ID
          title: title.isEmpty ? '' : title,
          content: contentJson.isEmpty ? '[]' : contentJson,
          createdAt: isEditingNow ? _currentNote!.createdAt : DateTime.now(),
        );

        // Log the note details for debugging
        print(
            'Saving note with id: ${note.id}, title: ${note.title}, content: ${note.content}');

        // Save or update the note via your provider
        final notesNotifier = widget.ref.read(notesProvider(_token!).notifier);
        final updatedNote = await notesNotifier.addOrUpdateNote(note);

        // After saving, update _currentNote with the returned note (including the new ID if it was a new note)
        setState(() {
          _currentNote = updatedNote; // Update with the saved note
          isEditing = true; // Always in editing mode after the first save
        });

        // Emit the note update to other devices via Socket.IO
        final emittedNote = _currentNote!.toJson(); // Use updated note
        socketService.emitNoteUpdate(emittedNote);

        // Dismiss the keyboard after saving
        FocusScope.of(context).unfocus();

        // Show a Snackbar to confirm the save
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note saved successfully')),
        );
      } catch (e) {
        // Handle any errors and show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: ${e.toString()}')),
        );
        print('Error saving note: $e');
      }
    } else {
      // Handle the case when the user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
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
