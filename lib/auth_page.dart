import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInSignUpPage extends StatefulWidget {
  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isSignIn = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFCFF008),
        title: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Redirect to the login page after alert
              if (isSignIn) {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pop(context); // Close alert and remain on Sign Up page
              }
            },
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showAlert("Successfully signed in!");
      Navigator.pushReplacementNamed(context, '/home'); // Navigate to home page
    } on FirebaseAuthException catch (e) {
      _showAlert("Failed to sign in: ${e.message}");
    } catch (e) {
      _showAlert("An error occurred: $e");
    }
  }

  Future<void> _signUp() async {
    try {
      if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
        _showAlert("Passwords do not match.");
        return;
      }
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showAlert("Account created successfully!");
    } on FirebaseAuthException catch (e) {
      _showAlert("Failed to create account: ${e.message}");
    } catch (e) {
      _showAlert("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Rich Printers",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFFCFF008),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => isSignIn = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSignIn ? Colors.grey : Color(0xFFCFF008),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => isSignIn = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSignIn ? Color(0xFFCFF008) : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                isSignIn ? "Welcome Back" : "Create your account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              isSignIn
                  ? SignInForm(_emailController, _passwordController, _signIn)
                  : SignUpForm(
                      _nameController,
                      _emailController,
                      _passwordController,
                      _confirmPasswordController,
                      _signUp,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function signIn;

  SignInForm(this.emailController, this.passwordController, this.signIn);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabeledField("Email", emailController, false),
        SizedBox(height: 10),
        _buildLabeledField("Password", passwordController, true),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => signIn(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFCFF008),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            "Log In",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // Navigate to sign up page if necessary
          },
          child: Text(
            "Don't have an account? Sign Up",
            style: TextStyle(color: Colors.yellowAccent),
          ),
        ),
        DividerWithText(text: "OR"),
        SocialButtons(),
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, bool obscureText) {
    return RoundedTextField(controller: controller, hintText: label, obscureText: obscureText);
  }
}

class SignUpForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function signUp;

  SignUpForm(this.nameController, this.emailController, this.passwordController, this.confirmPasswordController, this.signUp);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabeledField("Name", nameController, false),
        SizedBox(height: 10),
        _buildLabeledField("Email", emailController, false),
        SizedBox(height: 10),
        _buildLabeledField("Password", passwordController, true),
        SizedBox(height: 10),
        _buildLabeledField("Confirm Password", confirmPasswordController, true),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => signUp(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFCFF008),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 10),
        DividerWithText(text: "OR"),
        SocialButtons(),
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, bool obscureText) {
    return RoundedTextField(controller: controller, hintText: label, obscureText: obscureText);
  }
}

class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const RoundedTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white54),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: Colors.white)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(child: Divider(color: Colors.white)),
      ],
    );
  }
}

class SocialButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column( // Change to Column to stack buttons
      children: [
        // Google button
        ElevatedButton(
          onPressed: () {






            // Handle Google login
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Button background color
            foregroundColor: Colors.black, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 10), // Vertical padding
            fixedSize: Size(300, 50), // Set a fixed size for the button
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              SizedBox(
                height: 24, 
                width: 24,  
                child: Image.asset(
                  'assets/google_logo.png', 
                  fit: BoxFit.cover, 
                ),
              ),
              SizedBox(width: 10), 
              Text("Continue with Google"),
            ],
          ),
        ),
        SizedBox(height: 10), 
        // Facebook button
        ElevatedButton(
          onPressed: () {







            // Handle Facebook login
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, 
            foregroundColor: Colors.black, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 10), 
            fixedSize: Size(300, 50), 
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              SizedBox(
                height: 24, // Set fixed height for the icon
                width: 24,  // Set fixed width for the icon
                child: Image.asset(
                  'assets/facebook_logo.png', // Path to your Facebook icon
                  fit: BoxFit.cover, // Adjust to cover the size
                ),
              ),
              SizedBox(width: 10), // Add space between icon and text
              Text("Continue with Facebook"),
            ],
          ),
        ),
      ],
    );
  }
}
