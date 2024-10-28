import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';
import '../../providers/auth_providers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isEmailValid = false;
  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  String _emailValidationMessage = '';
  String _usernameValidationMessage = '';

  void _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    final authService = ref.read(authServiceProvider);
    try {
      final response = await authService.register(username, email, password);
      if (response && mounted) {
        // Check if the widget is still mounted
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration successful. Please log in.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    setState(() {
      if (value.isEmpty) {
        _emailValidationMessage = '';
        _isEmailValid = false;
      } else if (!emailRegex.hasMatch(value)) {
        _emailValidationMessage = 'Please enter a valid email address';
        _isEmailValid = false;
      } else {
        _emailValidationMessage = 'Email is valid';
        _isEmailValid = true;
      }
    });
  }

  void _validateUsername(String value) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]+$'); // Alphanumeric check

    setState(() {
      if (value.length > 8) {
        // Truncate to 8 characters if exceeded
        _usernameController.text = value.substring(0, 8);
        _usernameController.selection = TextSelection.fromPosition(
            TextPosition(offset: _usernameController.text.length));
      }

      if (value.isEmpty) {
        _usernameValidationMessage = '';
        _isUsernameValid = false;
      } else if (value.length < 8) {
        _usernameValidationMessage = 'Username must be 8 characters';
        _isUsernameValid = false;
      } else if (!usernameRegex.hasMatch(value)) {
        _usernameValidationMessage =
            'Username can only contain letters and numbers';
        _isUsernameValid = false;
      } else {
        _usernameValidationMessage = 'Username is valid';
        _isUsernameValid = true;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.length >= 8) {
        _isPasswordValid = true;
      } else {
        _isPasswordValid = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
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
                  'assets/images/sign_up_image.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
                Text(
                  'Register',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                SizedBox(height: 10),

                // Username TextField with validation
                TextField(
                  controller: _usernameController,
                  onChanged: _validateUsername,
                  maxLength: 8, // Limit to 8 characters
                  decoration: InputDecoration(
                    labelText: 'Username',
                    counterText: '', // Hides the max length counter
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                ),
                SizedBox(height: 10),

                // Email TextField with validation
                TextField(
                  controller: _emailController,
                  onChanged: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                ),
                SizedBox(height: 10),

                // Password TextField with visibility toggle
                TextField(
                  controller: _passwordController,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
                SizedBox(height: 20),

                if (_isLoading)
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: Color(0xFFFF725E),
                    size: 50,
                  ),

                // Register button
                SizedBox(
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    onPressed: _isEmailValid &&
                            _isUsernameValid &&
                            _isPasswordValid &&
                            !_isLoading
                        ? _register
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isEmailValid && _isUsernameValid && _isPasswordValid
                              ? Color(0xFFFF725E)
                              : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 13.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Validation messages below button
                Column(
                  children: [
                    Text(
                      _usernameValidationMessage,
                      style: TextStyle(
                        color: _isUsernameValid ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _emailValidationMessage,
                      style: TextStyle(
                        color: _isEmailValid ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
