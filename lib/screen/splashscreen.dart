import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF4A9FE7), Color(0xFF87CEEB), Colors.white],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildSplashPage(
                    title: "Welcome to Syllabuz",
                    subtitle: "Your learning journey starts here",
                  ),
                  _buildSplashPage(
                    title: "Learn Effectively",
                    subtitle: "Master your curriculum with ease",
                  ),
                  _buildNavigationPage(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildDot(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplashPage({required String title, required String subtitle}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 2),
        Text(
          'Syllabuz',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: Color(0xFF1976D2),
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        Spacer(flex: 3),
      ],
    );
  }

  Widget _buildNavigationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 2),
        Text(
          'Syllabuz',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: Color(0xFF1976D2),
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 40),
        Text(
          'Get Started',
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 60),

        // Sign Up Button
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 40),
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: 16),

        // Login Button
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 40),
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFF2196F3), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ),

        Spacer(flex: 3),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Color(0xFF1976D2) : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
