import 'package:asset_borrowing_system_mobile/common_pages/login.dart';
import 'package:flutter/material.dart';

const Color bgColor = Colors.white;
const Color primaryColor = Colors.blue;

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "text": "Welcome to the Shop!",
      "description":
          "Borrow what you need, when you need it—IT equipment and more, right at your fingertips!",
      "buttonText": "Continue",
      "image": "images/welcome.jpg",
    },
    {
      "text": "Explore a World of Options",
      "description":
          "Choose from a variety of devices available for quick and easy rental.",
      "buttonText": "Continue",
      "image": "images/aboutthisapp.jpg",
    },
    {
      "text": "Start Your Journey!",
      "description":
          "Get ready to experience the convenience of renting with us.",
      "buttonText": "Get Started",
      "image": "images/howtouse.jpg",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: onboardingData.length,
              itemBuilder: (context, index) => OnboardingContent(
                text: onboardingData[index]["text"]!,
                description: onboardingData[index]["description"]!,
                buttonText: onboardingData[index]["buttonText"]!,
                image: onboardingData[index]["image"]!,
                onButtonPressed: _nextPage,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(index: index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? primaryColor
            : primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String text, description, buttonText, image;
  final VoidCallback onButtonPressed;

  const OnboardingContent({
    Key? key,
    required this.text,
    required this.description,
    required this.buttonText,
    required this.image,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 560,
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Column(
            children: [
              const Spacer(),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(buttonText.toUpperCase()),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}
