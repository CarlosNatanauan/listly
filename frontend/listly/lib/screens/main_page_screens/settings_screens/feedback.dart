import 'package:flutter/material.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import '../../../services/api_service.dart';
import '../../../dialogs/loading_dialog.dart';

class FeedbackScreen extends StatefulWidget {
  final String email;
  final String token;

  FeedbackScreen({required this.email, required this.token}) {
    print("FeedbackScreen initialized with email: $email, token: $token");
  }

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int? rating;
  String additionalComments = "";
  bool showThankYouOverlay = false;
  final TextEditingController _commentsController = TextEditingController();

  Future<void> _submitFeedback() async {
    if (rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating before submitting.')),
      );
      return;
    }

    // Show the loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(message: 'Submitting Feedback...'),
    );

    try {
      // Call submitFeedback method to send the data to the backend
      await ApiService.submitFeedback(
          rating!, additionalComments, widget.token);

      Navigator.of(context).pop();

      // Reset fields and show the thank-you overlay
      setState(() {
        showThankYouOverlay = true;
      });
    } catch (e) {
      // Dismiss the loading dialog on error
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFFF725E),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'Feedback',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/feedback.png',
                    width: screenWidth * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
                Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Please rate your experience',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        EmojiFeedback(
                          rating: rating,
                          animDuration: Duration(milliseconds: 10),
                          curve: Curves.bounceIn,
                          inactiveElementScale: .5,
                          inactiveElementBlendColor: Colors.grey,
                          onChanged: (value) {
                            setState(() {
                              rating = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Additional Comments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _commentsController,
                          maxLines: 5,
                          onChanged: (text) {
                            additionalComments = text;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: screenWidth * 0.7,
                          child: ElevatedButton(
                            onPressed: _submitFeedback,
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
                              'Submit Feedback',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showThankYouOverlay)
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: screenWidth * 0.8,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black54),
                          onPressed: () {
                            setState(() {
                              // Reset rating and additionalComments, and clear the TextField
                              rating = null;
                              additionalComments = "";
                              _commentsController.clear();
                              showThankYouOverlay = false;
                            });
                          },
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/thankyou.png',
                      width: screenWidth * 0.7,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Thank You!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your feedback is valuable to us and helps improve our service.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
