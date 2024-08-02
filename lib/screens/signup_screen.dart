import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join WeSafe'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset('assets/img.png', height: 150),
              ),
              SizedBox(height: 20),
              CustomTextField(
                label: 'Email',
                controller: emailController,
              ),
              CustomTextField(
                label: 'Create Password',
                controller: passwordController,
                obscureText: true,
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  // Handle sign up
                },
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Already have an account? Sign In Now!'),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('or'),
                  ),
                  Expanded(
                    child: Divider(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'Sign Up with Mobile',
                onPressed: () {
                  // Handle mobile sign up
                },
              ),
              CustomButton(
                text: 'Sign Up with Google',
                onPressed: () {
                  // Handle Google sign up
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
