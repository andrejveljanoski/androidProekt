import 'package:flutter/material.dart';
import 'package:foody/widgets/input_field.dart';
import 'package:foody/widgets/primary_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // new import for Supabase auth
import 'package:geocoding/geocoding.dart'; // new import for reverse geocoding

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

  bool _isRestaurant = false; // new state variable
  bool _isProcessing = false; // New flag to prevent rapid API calls

  // Updated _signupApi function to log error details for debugging error 400
  Future<bool> _signupApi({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required bool isRestaurant,
    required String address,
  }) async {
    final AuthResponse authResponse =
        await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    // Remove check for authResponse.error and only check if user is null
    if (authResponse.user == null) {
      print("SignUp Error: user is null");
      return false;
    }
    final response = await Supabase.instance.client.from('profiles').insert({
      // Remove int.parse conversion as id is non-numeric (UUID).
      'id': authResponse.user!.id, // <-- fix applied
      'first_name': firstName,
      'last_name': lastName,
      'is_restaurant': isRestaurant,
      'address': address,
    });
    if (response.error != null) {
      print("Profile Insert Error: ${response.error!.message}");
      return false;
    }
    return true;
  }

  // Updated _signUp function to use signupApi
  Future<void> _signUp() async {
    if (_isProcessing) return; // Prevent duplicate calls
    setState(() {
      _isProcessing = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final address = _addressController.text.trim();

    try {
      bool success = await _signupApi(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        isRestaurant: _isRestaurant,
        address: address,
      );
      if (!mounted) return;
      if (success) {
        if (_isRestaurant) {
          Navigator.pushReplacementNamed(context, '/restauranthomepage');
        } else {
          Navigator.pushReplacementNamed(context, '/homescreen');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/loginscreen');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Add login function to check for auth and return an error if the account doesn't exist
  Future<void> _login() async {
    if (_isProcessing) return; // Prevent duplicate login calls
    setState(() {
      _isProcessing = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      final AuthResponse response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (response.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No account found. Please sign up first.")),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/homescreen');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

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
        // Instead of immediate navigation, call the sign-up function.
        _signUp();
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

  // New helper to convert coordinates to a readable address.
  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      // Fallback to coordinates string on error.
    }
    return "${position.latitude}, ${position.longitude}";
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
                    onPressed: _login, // updated login functionality
                    text: 'Login',
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    onPressed: _nextStep,
                    text: 'Sign Up',
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
                  // New Switch for selecting user type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Customer'),
                      Switch(
                        value: _isRestaurant,
                        onChanged: (value) {
                          setState(() {
                            _isRestaurant = value;
                          });
                        },
                      ),
                      const Text('Restaurant'),
                    ],
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
                          return Center(child: Text('error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final position = snapshot.data as Position;
                          return FutureBuilder<String>(
                            future: _getAddressFromCoordinates(position),
                            builder: (context, addressSnapshot) {
                              if (addressSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (addressSnapshot.hasData) {
                                if (_addressController.text.trim().isEmpty) {
                                  _addressController.text = addressSnapshot.data!;
                                }
                              } else if (addressSnapshot.hasError) {
                                if (_addressController.text.trim().isEmpty) {
                                  _addressController.text = "${position.latitude}, ${position.longitude}";
                                }
                              }
                              return GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(position.latitude, position.longitude),
                                  zoom: 14,
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(child: Text('No data found'));
                        }
                      },
                    ),
                  ),
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
