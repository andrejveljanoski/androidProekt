import 'package:flutter/material.dart';
import 'package:foody/widgets/card_with_icon.dart';
import 'package:foody/widgets/bottom_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
// Needed for address update:
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:foody/widgets/input_field.dart';
import 'package:foody/widgets/primary_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Existing state variable for profile image.
  String? _profileImageUrl;

  // New controllers for address and account details.
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Add helper methods from email_signup.dart for location/address.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _addressController.text =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      // Fallback to coordinates string on error.
    }
    return "${position.latitude}, ${position.longitude}";
  }

  // Helper method to sign out the user.
  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Helper method to change profile image by picking from the gallery and uploading.
  Future<void> _changeProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        Uint8List bytes = await image.readAsBytes();
        // Generate a unique filename, e.g., using the current timestamp.
        final String fileName =
            'image_${DateTime.now().millisecondsSinceEpoch}${image.name}';
        final String uploadResult = await Supabase.instance.client.storage
            .from('images')
            .uploadBinary(fileName, bytes);

        // Check if uploadResult is non-empty.
        if (uploadResult.isNotEmpty) {
          final String publicUrl = Supabase.instance.client.storage
              .from('images')
              .getPublicUrl(fileName);
          if (!mounted) return;
          setState(() {
            _profileImageUrl = publicUrl;
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading image.")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exception: $e")),
        );
      }
    }
  }

  // Updated _changeAddress method with the requested UI
  void _changeAddress() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
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
                            if (addressSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (addressSnapshot.hasData) {
                              if (_addressController.text.trim().isEmpty) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _addressController.text =
                                      addressSnapshot.data!;
                                });
                              }
                            } else if (addressSnapshot.hasError) {
                              if (_addressController.text.trim().isEmpty) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _addressController.text =
                                      "${position.latitude}, ${position.longitude}";
                                });
                              }
                            }
                            return GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    position.latitude, position.longitude),
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
                  controller: _addressController,
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () => Navigator.pop(context),
                        text: 'Save',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated _editAccountDetails method with the requested UI
  void _editAccountDetails() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Account Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InputField(
              controller: _firstNameController,
              labelText: 'First Name',
            ),
            SizedBox(height: 16),
            InputField(
              controller: _lastNameController,
              labelText: 'Last Name',
            ),
            SizedBox(height: 16),
            PrimaryButton(
              text: 'Change Profile Picture',
              onPressed: _changeProfileImage,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            text: 'Save Changes',
            onPressed: () {
              // TODO: Implement save changes logic
              Navigator.pop(context);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Profile image: use uploaded image if available.
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : AssetImage('lib/assets/images/background.avif')
                          as ImageProvider,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Account 1',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                InkWell(
                  onTap: _changeAddress,
                  child: CardWithIcon(
                    icon: Icon(Icons.home),
                    title: 'Delivery Address',
                    description: 'skopje 1000',
                  ),
                ),
                InkWell(
                  onTap: _editAccountDetails,
                  child: CardWithIcon(
                    icon: Icon(Icons.manage_accounts),
                    title: 'Account Details',
                    description: 'Details',
                  ),
                ),
                InkWell(
                  onTap: _signOut,
                  child: CardWithIcon(
                    icon: Icon(Icons.login),
                    title: 'Sign Out',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 2,
        onDestinationSelected: (index) {},
      ),
    );
  }
}
