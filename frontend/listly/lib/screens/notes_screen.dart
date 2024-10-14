import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';
import '../widgets/add_note_widget.dart'; // Import the AddNoteWidget
import 'dart:convert';

class NotesScreen extends ConsumerWidget {
  final String token;

  NotesScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsyncValue = ref.watch(notesProvider(token));

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notes',
                style: TextStyle(
                  color: Colors.black54,
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
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
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
                        // Call delete method on the notifier
                        await ref
                            .read(notesProvider(token).notifier)
                            .deleteNote(note.id);
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
                            // This will be triggered after returning from AddNoteWidget
                            ref
                                .read(notesProvider(token).notifier)
                                .fetchNotes();
                          });
                        },
                        child: Container(
                          width: double
                              .infinity, // Ensure the card takes full width
                          constraints: BoxConstraints(
                            minHeight: 100, // Minimum height for all cards
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${note.createdAt.toIso8601String().split("T").first}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    note.title.isEmpty ? '' : note.title,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _extractPlainText(note.content),
                                    style: TextStyle(fontSize: 16),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
          child: TextField(
            style: TextStyle(fontSize: 14.0),
            decoration: InputDecoration(
              labelText: 'Search Notes',
              labelStyle: TextStyle(fontSize: 14.0),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, size: 20.0, color: Colors.grey),
            ),
            onChanged: (value) {
              // Placeholder for search functionality
            },
          ),
        ),
      ),
    );
  }
}
