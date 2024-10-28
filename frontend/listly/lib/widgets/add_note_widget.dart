import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/services.dart';
import 'package:parchment_delta/parchment_delta.dart';
import '../models/note.dart';
import 'dart:convert';
import '../providers/notes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service_notes.dart';
import '../providers/socket_service_provider.dart';
import '../providers/auth_providers.dart';

class AddNoteWidget extends ConsumerWidget {
  final Note? note;

  const AddNoteWidget({Key? key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AddNoteWidgetContent(note: note, ref: ref);
  }
}

class _AddNoteWidgetContent extends StatefulWidget {
  final Note? note;
  final WidgetRef ref;

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
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _getToken();
    socketService = widget.ref.read(socketServiceProvider);

    if (_currentNote != null) {
      titleController.text = _currentNote!.title;
      if (_currentNote!.content.isNotEmpty) {
        dynamic content = jsonDecode(_currentNote!.content);
        _setDocumentFromJson(content);
      }
      isEditing = true;
      _listenForNoteUpdates();
    } else {
      _initController();
    }
  }

  Future<void> _initController() async {
    _controller = FleatherController(
        document: ParchmentDocument()); // Use named parameter for document
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
      socketService.connect(_token!, _handleNoteUpdate);
    } else {
      print('Token not found, unable to connect to socket.');
    }
  }

  void _handleNoteUpdate(Note updatedNote) {
    if (_currentNote != null && _currentNote!.id == updatedNote.id) {
      _setDocumentFromJson(jsonDecode(updatedNote.content));
      titleController.text = updatedNote.title;
    }
  }

  void _listenForNoteUpdates() {
    if (_currentNote != null && _currentNote!.id.isNotEmpty) {
      socketService.onNoteUpdate(_currentNote!.id, _handleNoteUpdate);
    }
  }

  void _saveOrUpdateNote() async {
    final title = titleController.text.isEmpty ? '' : titleController.text;
    final content = _controller?.document;
    String contentJson = content != null ? jsonEncode(content.toJson()) : '[]';

    if (_token != null) {
      try {
        final isEditingNow =
            _currentNote != null && _currentNote!.id.isNotEmpty;

        final note = Note(
          id: isEditingNow ? _currentNote!.id : '',
          title: title.isEmpty ? '' : title,
          content: contentJson.isEmpty ? '[]' : contentJson,
          createdAt: isEditingNow ? _currentNote!.createdAt : DateTime.now(),
        );

        final notesNotifier = widget.ref.read(notesProvider(_token!).notifier);
        final updatedNote = await notesNotifier.addOrUpdateNote(note);

        setState(() {
          _currentNote = updatedNote;
          isEditing = true;
        });

        socketService.emitNoteUpdate(_currentNote!.toJson());

        FocusScope.of(context).unfocus();

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

  Future<void> _confirmDeleteNote() async {
    // Show a confirmation dialog before deleting
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text(
              'Are you sure you want to delete this note? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Color(0xFFFF725E))),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // If the user confirmed deletion, proceed to delete the note
    if (shouldDelete == true) {
      _deleteNote();
    }
  }

  Future<void> _deleteNote() async {
    if (_currentNote == null || _currentNote!.id.isEmpty) return;

    try {
      final notesNotifier = widget.ref.read(notesProvider(_token!).notifier);
      await notesNotifier.deleteNote(_currentNote!.id);

      socketService.emitNoteUpdate({'id': _currentNote!.id, 'deleted': true});

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: ${e.toString()}')),
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
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: isEditing ? _confirmDeleteNote : null,
            tooltip: 'Delete Note',
            color: isEditing ? Color.fromARGB(255, 165, 46, 31) : Colors.grey,
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
