import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('lib/assets/images/background.avif', fit: BoxFit.cover),
        Container(
          color: Colors.black.withValues(alpha: 0.3),
        ),
        Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: (Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
                child: const Text('Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    )),
              ),
            )))
      ],
    ));
  }
}
