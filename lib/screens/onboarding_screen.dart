import 'package:flutter/material.dart';
import 'package:we_safe/screens/login_screen.dart';
import 'package:we_safe/screens/signup_screen.dart'; // Update with your actual path


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> _onboardingData = [
    {
      "text": "Explore and discover the safest routes for your journeys.",
      "image": "assets/img.png",
    },
    {
      "text": "Easily report incidents and stay updated with real-time alerts.",
      "image": "assets/img.png",
    },
    {
      "text": "Connect with local safety groups and collaborate on safety initiatives.",
      "image": "assets/img.png",
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildPageContent(Map<String, String> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(data["image"]!, height: 250.0),
        SizedBox(height: 20),
        Text(
          "Welcome to WeSafe",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 10),
        Text(
          data["text"]!,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => _buildPageContent(_onboardingData[index]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                    (index) => _buildDot(index),
              ),
            ),
            SizedBox(height: 20),
            if (_currentPage == _onboardingData.length - 1)
              CustomButton(
                text: "Sign Up",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
              ),
            if (_currentPage == _onboardingData.length - 1)
              CustomButton(
                text: "Login",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            if (_currentPage != _onboardingData.length - 1)
              CustomButton(
                text: "Next",
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
            TextButton(
              onPressed: () {
                // Skip to the last page
                _pageController.jumpToPage(_onboardingData.length - 1);
              },
              child: Text("Skip"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 10,
      width: _currentPage == index ? 20 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.purple : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple, // Updated parameter
          foregroundColor: Colors.white, // Updated parameter
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
