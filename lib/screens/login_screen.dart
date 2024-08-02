import 'package:flutter/material.dart';
import 'package:we_safe/screens/map_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';


class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login to WeSafe'),
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
                label: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  // Implement your login logic here
                  // For demonstration, we will navigate to MapScreen
                  // You should verify the login credentials before navigating
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                },
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text('Don\'t have an account? Sign Up Now!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
