import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../widgets/add_note_widget.dart';
import 'dart:convert';
import '../providers/socket_service_provider.dart'; // Import the SocketService provider
import 'package:intl/intl.dart'; // Import for formatting dates and times

class NotesScreen extends ConsumerStatefulWidget {
  final String token;

  NotesScreen({Key? key, required this.token}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Ensure the notes are fetched when the screen is first loaded
    Future.microtask(
        () => ref.read(notesProvider(widget.token).notifier).fetchNotes());
  }

  @override
  Widget build(BuildContext context) {
    final notesAsyncValue = ref.watch(notesProvider(widget.token));

    return Scaffold(
      backgroundColor:
          Color.fromARGB(248, 248, 248, 248), // Set the screen background color
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notes',
                style: TextStyle(
                  color: Color(0xFFFF725E),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildSearchBar(),
          Expanded(
            child: notesAsyncValue.when(
              data: (notes) {
                // Filter notes based on the search query
                final filteredNotes = notes.where((note) {
                  return note.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      _extractPlainText(note.content)
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                })
                    // Sort by 'createdAt' in descending order (latest first)
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return Dismissible(
                      key: Key(note.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await _deleteNoteAndEmit(note.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Note deleted')),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNoteWidget(note: note),
                            ),
                          ).then((_) {
                            // Fetch the latest notes when returning from the add note screen
                            ref
                                .read(notesProvider(widget.token).notifier)
                                .fetchNotes();
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 100),
                          child: Card(
                            color: Colors
                                .white, // Set the card background color to pure white
                            elevation: .5,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Format date and time using intl package
                                  Text(
                                    _formatDateTime(note.createdAt),
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    note.title.isEmpty ? '' : note.title,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _extractPlainText(note.content),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  // Format Date and Time for the card display
  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss'); // Customize the format
    return formatter.format(dateTime);
  }

  // Handle deleting a note and emitting a socket update for deletion
  Future<void> _deleteNoteAndEmit(String noteId) async {
    final notesNotifier = ref.read(notesProvider(widget.token).notifier);
    final socketService = ref.read(socketServiceProvider);

    try {
      await notesNotifier.deleteNote(noteId);
      socketService.emitNoteUpdate(
          {'id': noteId, 'deleted': true}); // Emit delete event via socket
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: ${e.toString()}')),
      );
    }
  }

  // Helper function to extract plain text from note content
  String _extractPlainText(String content) {
    try {
      final parsedContent = jsonDecode(content);
      if (parsedContent is List) {
        final buffer = StringBuffer();
        for (var item in parsedContent) {
          if (item is Map<String, dynamic> && item.containsKey('insert')) {
            buffer.write(item['insert']);
          }
        }
        return buffer.toString();
      }
      return content;
    } catch (e) {
      return content;
    }
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Card(
        color: Color.fromARGB(
            238, 243, 243, 243), // Set the search bar background to pure white
        elevation: .5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
          child: TextField(
            cursorColor: Color(0xFFFF725E),
            style: TextStyle(fontSize: 14.0),
            decoration: InputDecoration(
              labelText: 'Search Notes',
              focusColor: Colors.black,
              labelStyle: TextStyle(fontSize: 14.0, color: Color(0xFFFF725E)),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search,
                  size: 20.0, color: Color.fromARGB(255, 196, 196, 196)),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
