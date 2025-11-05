import 'package:flutter/material.dart';
import '/widgets/input_field.dart';
import '/widgets/button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  String? errorMessage;

  void _navigateToSignIn() {
    Navigator.pushNamed(context, '/signin');
  }

  void _navigateToHome() {
    Navigator.pushNamed(context, '/navbar');
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
                  callback: (String val) => email = val,
                  text: "email",
                  label: "email",
                  type: "email"),
              const SizedBox(height: 12),

              // password testfield
              InputField(
                  callback: (String val) => password = val,
                  text: "password",
                  label: "password",
                  type: "password"),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: Button(
                    callback: _navigateToHome, text: "Sign up", type: "filled"),
              ),
              Center(
                child: Button(
                    callback: _navigateToSignIn,
                    text: "Already have an account? Sign in",
                    type: "text"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
