import 'package:flutter/material.dart';
import '../../../dialogs/loading_dialog.dart';
import '../../../services/api_service.dart';
import '../../../providers/socket_service_provider.dart';
import '../../../providers/socket_service_tasks_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClearDataScreen extends ConsumerWidget {
  final String email;
  final String token;

  ClearDataScreen({required this.email, required this.token});

  Future<void> _handleClearData(BuildContext context, WidgetRef ref) async {
    print("In ClearDataScreen - Token: $token, Email: $email");

    if (token.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token or email is missing.')),
      );
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(message: 'Clearing Data...'),
    );

    try {
      // Fetch tasks with error handling
      final tasks = await ApiService.fetchTasks(token);
      print("Fetched tasks: $tasks");

      if (tasks.isNotEmpty) {
        final socketServiceTasks = ref.read(socketServiceTasksProvider);
        for (var task in tasks) {
          final taskId = task['_id'];
          if (taskId != null && taskId is String) {
            await ApiService.deleteTask(taskId, token);
            socketServiceTasks.emitTaskUpdate({'_id': taskId, 'deleted': true});
          } else {
            print("Invalid or null task ID: $taskId");
          }
        }
      }

      // Fetch notes with error handling
      final notes = await ApiService.fetchNotes(token);
      print("Fetched notes: $notes");

      if (notes.isNotEmpty) {
        final socketServiceNotes = ref.read(socketServiceProvider);
        for (var note in notes) {
          if (note.id.isNotEmpty) {
            await ApiService.deleteNote(note.id, token);
            socketServiceNotes.emitNoteUpdate({'id': note.id, 'deleted': true});
          } else {
            print("Invalid or empty note ID: ${note.id}");
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All data cleared successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear data: ${e.toString()}')),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF725E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Clear Data',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/clear_data.png',
              height: 150,
              width: 150,
            ),
            SizedBox(height: 30),
            Text(
              'Are you sure you want to clear all data?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'This will permanently delete all Notes and Tasks stored on your account. This action cannot be undone.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: screenWidth * 0.7,
              child: ElevatedButton(
                onPressed: () => _handleClearData(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF725E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Clear Data',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
