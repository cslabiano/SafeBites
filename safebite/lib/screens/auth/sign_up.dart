import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebite/models/user_model.dart';
import 'package:safebite/providers/auth_provider.dart';

// import widgets
import '/widgets/input_field.dart';
import '/widgets/button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  late UserModel newUser;
  String nickname = '';
  String email = '';
  String password = '';
  String? errorMessage;

  Future<void> _navigateToSignIn() async {
    Navigator.pushNamed(context, '/signin');
  }

  Future<void> _navigateToHome() async {
    Navigator.pushReplacementNamed(context, '/navbar');
  }

  // function to handle the sign-up process
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        errorMessage = null;
      });

      final newUser = UserModel(email: email, nickname: nickname);

      String? result =
          await context.read<UserAuthProvider>().signUp(newUser, password);

      if (result != null) {
        // set error message if sign-up fails
        setState(() {
          errorMessage = result;
        });
      } else {
        // navigate to home on successful sign-up
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

              // nickname textfield
              InputField(
                  // using onsaved for form submission
                  onSaved: (String? val) => nickname = val ?? '',
                  text: "nickname",
                  label: "nickname",
                  type: "text"),
              const SizedBox(height: 12),

              // email textfield
              InputField(
                  // using onsaved for form submission
                  onSaved: (String? val) => email = val ?? '',
                  text: "email",
                  label: "email",
                  type: "email"),
              const SizedBox(height: 12),

              // password textfield
              InputField(
                  // using onsaved for form submission
                  onSaved: (String? val) => password = val ?? '',
                  text: "password",
                  label: "password",
                  type: "password"),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: Button(
                    // call the async sign up function
                    callback: _signUp,
                    text: "Sign up",
                    type: "filled"),
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
