import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Future<void> _launchUrl(Uri url) async {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF725E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to MainPage
          },
        ),
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // About Image
              Center(
                child: Image.asset(
                  'assets/images/about_image.png',
                  width: screenWidth * 0.6,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),
              // About Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Welcome to ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: 'Listly',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF725E),
                      ),
                    ),
                    TextSpan(
                      text:
                          ', an app designed to help you manage both your Notes and Tasks seamlessly. It offers real-time updates, account features, and an easy way to stay organized and efficient.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Developed by Section
              Column(
                children: [
                  Text(
                    'Developed by',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    'Carlos Natanauan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // GitHub Icon Button
                      GestureDetector(
                        onTap: () async {
                          final Uri url =
                              Uri.parse('https://github.com/CarlosNatanauan');
                          await _launchUrl(url);
                        },
                        child: Image.asset(
                          'assets/icons/github_icon.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                      // LinkedIn Icon Button
                      GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse(
                              'https://linkedin.com/in/carlosnatanauan');
                          await _launchUrl(url);
                        },
                        child: Image.asset(
                          'assets/icons/linkedin_icon.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                      // Gmail Icon Button
                      GestureDetector(
                        onTap: () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'carlosbenedict@gmail.com',
                            query: 'subject=Hello Carlos',
                          );
                          await _launchUrl(emailLaunchUri);
                        },
                        child: Image.asset(
                          'assets/icons/gmail_icon.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
