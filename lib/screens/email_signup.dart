import 'package:flutter/material.dart';
import 'package:foody/widgets/input_field.dart';
import 'package:foody/widgets/primary_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class EmailSignup extends StatefulWidget {
  const EmailSignup({super.key});

  @override
  State<EmailSignup> createState() => _EmailSignupState();
}

class _EmailSignupState extends State<EmailSignup> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
          _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
        });
      } else {
        Navigator.pushReplacementNamed(context, '/homescreen');
        // submit form
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.previousPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InputField(
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    labelText: 'Password',
                    keyboardType: TextInputType.text,
                    controller:
                        _passwordController, // Ensure you have this controller
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    onPressed: _nextStep,
                    text: 'Next',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InputField(
                    labelText: 'First Name',
                    keyboardType: TextInputType.text,
                    controller:
                        _firstNameController, // Ensure you have this controller
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    labelText: 'Last Name',
                    keyboardType: TextInputType.text,
                    controller:
                        _lastNameController, // Ensure you have this controller
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: _prevStep,
                          text: 'Back',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: _nextStep,
                          text: 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Address info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                      child: FutureBuilder(
                    future: _determinePosition(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(snapshot.data!.latitude,
                                snapshot.data!.longitude),
                            zoom: 14,
                          ),
                        );
                      } else {
                        return Center(
                          child: Text('No data found'),
                        );
                      }
                    },
                  )),
                  const SizedBox(height: 16),
                  InputField(
                    labelText: 'Address',
                    keyboardType: TextInputType.text,
                    controller:
                        _addressController, // Ensure you have this controller
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: _prevStep,
                          text: 'Back',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: _nextStep,
                          text: 'Submit',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add more steps as needed
          ],
        ),
      ),
    );
  }
}
