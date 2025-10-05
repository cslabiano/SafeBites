import 'package:flutter/material.dart';
import '/widgets/input_field.dart';
import '/widgets/button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(14, 198, 178, 1),
              Color.fromRGBO(37, 212, 147, 1)
            ],
          ),
        ),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                margin: EdgeInsets.only(top: screenHeight * 0.15),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                child: Form(
                    key: _formKey,
                    child: Column(children: [
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

                      Button(
                          callback: () => (), text: "Sign in", type: "filled")
                    ])))));
  }
}
