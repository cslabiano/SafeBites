import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebite/providers/auth_provider.dart';

// import widgets
import '/widgets/input_field.dart';
import '/widgets/button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String? errorMessage;

  Future<void> _navigateToSignUp() async {
    Navigator.pushNamed(context, '/signup');
  }

  Future<void> _navigateToHome() async {
    Navigator.pushReplacementNamed(context, '/navbar');
  }

  // function to handle the sign-in process
  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      // call onSaved for all form fields to update email and password
      _formKey.currentState!.save();

      setState(() {
        errorMessage = null;
      });

      // call sign-in via provider and handle errors
      String? result =
          await context.read<UserAuthProvider>().signIn(email, password);

      if (result != null) {
        setState(() {
          errorMessage = result;
        });
      } else {
        // navigate to home on successful sign-in
        if (context.mounted) {
          _navigateToHome();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.1),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SafeBite",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 24),
              // email textfield
              InputField(
                  onSaved: (String? val) => email = val ?? '',
                  text: "email",
                  label: "email",
                  type: "email"),
              const SizedBox(height: 12),

              // password testfield
              InputField(
                  onSaved: (String? val) => password = val ?? '',
                  text: "password",
                  label: "password",
                  type: "password"),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: Button(
                    callback: _handleSignIn, text: "Sign in", type: "filled"),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              Center(
                child: Button(
                    callback: _navigateToSignUp,
                    text: "Don't have an account? Sign up",
                    type: "text"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
