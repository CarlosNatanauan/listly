import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main_page.dart';
import '../../providers/auth_providers.dart';
import '../../change_password/forgot_password.dart';
import '../onboarding_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isInvalidCredentials = false; // Flag for incorrect login attempts

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _isInvalidCredentials = false; // Reset the flag on new login attempt
    });

    final authService = ref.read(authServiceProvider);
    final user = await authService.login(username, password, ref);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      ref.read(userProvider.notifier).state = user;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainPage(userName: '${user.username}!'),
        ),
      );
    } else {
      setState(() {
        _isInvalidCredentials = true; // Set the flag if login fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => OnboardingScreen()),
            );
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/login_image.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _usernameController,
                  cursorColor: Color(0xFFFF725E),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    floatingLabelStyle: TextStyle(
                        color: Color(0xFFFF725E)), // Set floating label color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  cursorColor: Color(0xFFFF725E),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    floatingLabelStyle: TextStyle(color: Color(0xFFFF725E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
                if (_isInvalidCredentials) // Show error message if login fails
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Username or password is incorrect',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFFFF725E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: Color(0xFFFF725E),
                    size: 50,
                  ),
                SizedBox(height: 10),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF725E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 13.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
