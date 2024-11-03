import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logger.dart';


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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _showAlert(String message, {bool navigateToHome = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFCFF008),
        title: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (navigateToHome) {
                Navigator.pushReplacementNamed(context, '/home');
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
      _showAlert("Successfully signed in!", navigateToHome: true);
    } on FirebaseAuthException catch (e) {
      _showAlert("Failed to sign in: ${e.message}");
    } catch (e) {
      _showAlert("An error occurred: $e");
    }
  }

  Future<void> _signUp() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showAlert("Passwords do not match.");
      return;
    }
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showAlert("Account created successfully! Please log in.");
      setState(() => isSignIn = true); // Switch to the sign-in view
    } on FirebaseAuthException catch (e) {
      _showAlert("Failed to create account: ${e.message}");
    } catch (e) {
      _showAlert("An error occurred: $e");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showAlert("Error logging in with Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                      backgroundColor:
                          isSignIn ? Colors.grey : Color(0xFFCFF008),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Sign Up",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => isSignIn = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSignIn ? Color(0xFFCFF008) : Colors.grey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Log In",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                isSignIn ? "Welcome Back" : "Create your account",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              SizedBox(height: 20),
              isSignIn
                  ? SignInForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      signIn: _signIn,
                      signInWithGoogle: _signInWithGoogle,
                    )
                  : SignUpForm(
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      signUp: _signUp,
                      signInWithGoogle: _signInWithGoogle,
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
  final Function signInWithGoogle;

  SignInForm({
    required this.emailController,
    required this.passwordController,
    required this.signIn,
    required this.signInWithGoogle,
  });

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
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // Navigate to sign up if not already there
          },
          child: Text(
            "Don't have an account? Sign Up",
            style: TextStyle(color: Colors.yellowAccent),
          ),
        ),
        DividerWithText(text: "OR"),
        SizedBox(height: 10),
        SocialButtons(signInWithGoogle: signInWithGoogle),
      ],
    );
  }

  Widget _buildLabeledField(
      String label, TextEditingController controller, bool obscureText) {
    return RoundedTextField(
        controller: controller, hintText: label, obscureText: obscureText);
  }
}

class SignUpForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function signUp;
  final Function signInWithGoogle;

  SignUpForm({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.signUp,
    required this.signInWithGoogle,
  });

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
        SizedBox(height: 40),
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
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        DividerWithText(text: "OR"),
        SizedBox(height: 10),
        SocialButtons(signInWithGoogle: signInWithGoogle),
      ],
    );
  }

  Widget _buildLabeledField(
      String label, TextEditingController controller, bool obscureText) {
    return RoundedTextField(
        controller: controller, hintText: label, obscureText: obscureText);
  }
}

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
  final Function signInWithGoogle;

  const SocialButtons({Key? current_key, required this.signInWithGoogle}) : super(key: current_key);
  
  
  @override
  Widget build(BuildContext context) {
    AppLogger.instance.i('key',key);
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => signInWithGoogle(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            side: BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
            fixedSize: Size(400, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/google_logo.png',
                height: 24, // Adjust height as needed
                width: 24,  // Adjust width as needed
              ),
              SizedBox(width: 10), // Spacing between icon and text
              Text(
                "Continue with Google",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Implement Facebook sign-in here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            side: BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
            fixedSize: Size(400, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/facebook_logo.png',
                height: 24, // Adjust height as needed
                width: 24,  // Adjust width as needed
              ),
              SizedBox(width: 10), // Spacing between icon and text
              Text(
                "Continue with Facebook",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const RoundedTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      this.obscureText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
