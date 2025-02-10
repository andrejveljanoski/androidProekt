// ignore_for_file: use_build_context_synchronously

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
  bool _isRestaurant = false;
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _restaurantDescriptionController =
      TextEditingController();
  // Existing state variable for profile image.
  String? _profileImageUrl;

  // New controllers for address and account details.
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // New state variable for display name
  String? _displayName;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      setState(() {
        _isRestaurant = response['is_restaurant'] == true;
        _address = response['address'] ?? '';
        // Added this line to preserve the updated profile image.
        _profileImageUrl = response['img_url'];
        if (_isRestaurant) {
          _restaurantNameController.text = response['restaurant_name'] ?? '';
          _displayName =
              (response['restaurant_name'] ?? 'Restaurant').toString();
          _restaurantDescriptionController.text =
              response['description'] ?? 'Mixed Cuisine';
        } else {
          _firstNameController.text = response['first_name'] ?? '';
          _lastNameController.text = response['last_name'] ?? '';
          _displayName =
              "${response['first_name'] ?? ''} ${response['last_name'] ?? ''}"
                  .trim();
        }
        _addressController.text = response['address'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Change map type to allow null values.
    final Map<String, Object?> updates = {
      'address': _addressController.text.trim(),
      'is_restaurant': _isRestaurant,
    };

    if (_isRestaurant) {
      updates['restaurant_name'] = _restaurantNameController.text.trim();
      updates['first_name'] = null;
      updates['last_name'] = null;
    } else {
      updates['first_name'] = _firstNameController.text.trim();
      updates['last_name'] = _lastNameController.text.trim();
      updates['restaurant_name'] = null;
    }

    await Supabase.instance.client
        .from('profiles')
        .update(updates)
        .eq('id', user.id);

    // Update local address variable for UI display
    setState(() {
      _address = _addressController.text.trim();
    });
  }

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
        final String fileName =
            'image_${DateTime.now().millisecondsSinceEpoch}${image.name}';
        final String uploadResult = await Supabase.instance.client.storage
            .from('images')
            .uploadBinary(fileName, bytes);

        if (uploadResult.isNotEmpty) {
          final String publicUrl = Supabase.instance.client.storage
              .from('images')
              .getPublicUrl(fileName);
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            await Supabase.instance.client
                .from('profiles')
                .update({'img_url': publicUrl}).eq('id', user.id);
          }
          // Force re-fetch profile to update state.
          await _fetchProfile();
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
        child: SizedBox(
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
                        onPressed: () async {
                          await _updateProfile();
                          Navigator.pop(context);
                        },
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
      builder: (_) {
        return AlertDialog(
          title: Text('Edit Account Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isRestaurant) ...[
                InputField(
                  controller: _restaurantNameController,
                  labelText: 'Restaurant Name',
                ),
                SizedBox(height: 16),
                InputField(
                  controller: _restaurantDescriptionController,
                  labelText: 'Restaurant description',
                ),
              ] else ...[
                InputField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                ),
                SizedBox(height: 16),
                InputField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                ),
              ],
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
              onPressed: () async {
                await _updateProfile();
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
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
            _displayName ?? "",
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
                    description: _address,
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
