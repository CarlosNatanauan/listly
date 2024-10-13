import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';

class NotesScreen extends ConsumerWidget {
  final String token; // This should be passed from the login or main screen

  NotesScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsyncValue = ref.watch(notesProvider(token));

    return Scaffold(
      body: Column(
        children: [
          // Title for the Notes screen
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
                    return Card(
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
                              "${note.createdAt.toIso8601String().split("T").first}", // Display date
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Text(
                              note.title,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            // Truncate content with ellipsis if it exceeds 2 lines
                            Text(
                              note.content,
                              style: TextStyle(fontSize: 16),
                              maxLines: 2, // Limit to 2 lines
                              overflow: TextOverflow.ellipsis, // Add ellipsis
                            ),
                          ],
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
            // You may want to handle the search functionality later
            style: TextStyle(
              fontSize: 14.0, // Adjusted font size
            ),
            decoration: InputDecoration(
              labelText: 'Search Notes',
              labelStyle:
                  TextStyle(fontSize: 14.0), // Adjust the label font size
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search,
                  size: 20.0, color: Colors.grey), // Smaller icon size
            ),
            onChanged: (value) {
              // Placeholder for search functionality
              // You can implement the logic later
            },
          ),
        ),
      ),
    );
  }
}
