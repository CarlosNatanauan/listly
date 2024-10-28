import 'package:flutter/material.dart';
import '../../../dialogs/loading_dialog.dart';
import '../../../services/api_service.dart';

class AccountDeletion extends StatelessWidget {
  final String email;
  final String token;

  AccountDeletion({required this.email, required this.token});

  Future<void> _handleAccountDeletion(BuildContext context) async {
    // Show the loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(message: 'Deleting...'),
    );
    await ApiService.deleteAccount(email, token);

    await Future.delayed(Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
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
          'Delete Account',
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
            Center(
              child: Image.asset(
                'assets/images/delete_account.png',
                width: screenWidth * 0.7,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'This action is irreversible. All your saved Notes and Tasks will be permanently deleted and cannot be restored.',
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
                onPressed: () => _handleAccountDeletion(context),
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
                  'Delete Account',
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
