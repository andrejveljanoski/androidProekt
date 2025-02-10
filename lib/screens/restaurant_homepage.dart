import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foody/widgets/input_field.dart';
import 'package:foody/widgets/primary_button.dart';
import 'package:foody/widgets/restaurant_card.dart';
import 'package:image_picker/image_picker.dart'; // new import for image picker
import 'package:foody/widgets/bottom_navigation.dart'; // new import for bottom navigation
import 'package:supabase_flutter/supabase_flutter.dart'; // new import for supabase

class RestaurantHomepage extends StatefulWidget {
  const RestaurantHomepage({super.key});

  @override
  State<RestaurantHomepage> createState() => _RestaurantHomepageState();
}

class _RestaurantHomepageState extends State<RestaurantHomepage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _ingredientsList = []; // list of ingredients
  File? _selectedImage; // selected image file from phone
  final ImagePicker _picker = ImagePicker(); // image picker instance

  // Initialize meals as an empty list
  final List<Map<String, dynamic>> _meals = [];

  @override
  void initState() {
    super.initState();
    _fetchMeals(); // new call to load meals from Supabase
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // Update _addMeal to be asynchronous and insert to supabase before updating _meals
  Future<void> _addMeal() async {
    if (!_formKey.currentState!.validate()) return;
    // New logic to parse price as double even if an integer is entered:
    final priceText = _priceController.text;
    double price = double.tryParse(priceText) ?? 
        (int.tryParse(priceText)?.toDouble() ?? 0.0);
  
    final String? bossId = Supabase.instance.client.auth.currentUser?.id;
    if (bossId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Boss profile not found')),
      );
      return;
    }

    // Upload image if selected; use default if not.
    String imageUrl = 'https://example.com/default.png';
    if (_selectedImage != null) {
      final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.png';
      try {
        // Upload image; the upload call now returns a String,
        // so simply await its completion.
        await Supabase.instance.client.storage
            .from('meals')
            .upload(fileName, _selectedImage!);
        final publicURLResponse = Supabase.instance.client.storage
            .from('meals')
            .getPublicUrl(fileName);
        imageUrl = publicURLResponse; // updated to use the returned String
      } catch (uploadError) {
        debugPrint('Image upload error: $uploadError');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $uploadError')),
        );
        return;
      }
    }

    try {
      final insertedMeals =
          await Supabase.instance.client.from('meals').insert({
        'name': _mealNameController.text,
        'price': price,
        'rating': 0,
        'restaurant_id': bossId,
        'img_url': imageUrl, // using uploaded image URL (or default)
        'description': _descriptionController.text
      }).select();
      if (!mounted) return;
      if (insertedMeals.isNotEmpty) {
        final insertedMeal = insertedMeals[0];
        setState(() {
          _meals.add({
            'mealName': insertedMeal['name'],
            'price': insertedMeal['price'],
            'description': insertedMeal['description'],
            'imageAsset': insertedMeal['img_url']
          });
          _mealNameController.clear();
          _priceController.clear();
          _descriptionController.clear();
          _ingredientsList.clear();
          _selectedImage = null;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No meal data returned')),
        );
      }
    } catch (e) {
      // Log the error to the console for debugging
      debugPrint('Error adding meal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding meal: ${e.toString()}')),
      );
    }
  }

  // New function to fetch meals for the current restaurant
  Future<void> _fetchMeals() async {
    final bossId = Supabase.instance.client.auth.currentUser?.id;
    if (bossId == null) return;
    try {
      final meals = await Supabase.instance.client
          .from('meals')
          .select()
          .eq('restaurant_id', bossId) as List<dynamic>;
      setState(() {
        _meals.clear();
        for (final meal in meals) {
          _meals.add({
            'mealName': meal['name'],
            'price': meal['price'],
            'description': meal['description'],
            'imageAsset': meal['img_url'],
            'ingredients': meal['ingredients'],
          });
        }
      });
    } catch (e) {
      debugPrint('Error fetching meals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Homepage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Meal insert form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  InputField(
                    labelText: 'Meal Name',
                    keyboardType: TextInputType.text,
                    controller: _mealNameController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a meal name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Replace image asset text input with image picker button and preview
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Upload Image'),
                      ),
                      const SizedBox(width: 16),
                      _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : const Text('No image selected'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    labelText: 'Price(also add decimal point)',
                    keyboardType: TextInputType.number,
                    controller: _priceController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    labelText: 'Description',
                    keyboardType: TextInputType.text,
                    controller: _descriptionController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a description';
                      }
                      return null;
                    },
                  ),
                  // Ingredient input and add button

                  const SizedBox(height: 8),
                  // Display the list of added ingredients
                  Wrap(
                    spacing: 8,
                    children: _ingredientsList
                        .map((ing) => Chip(label: Text(ing)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    onPressed: _addMeal,
                    text: 'Add Meal',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // List of meals using RestaurantCard
            Expanded(
              child: ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  // Check if imageAsset is a file path or asset path
                  Widget mealImage;
                  if (meal['imageAsset']?.startsWith('http') ?? false) {
                    mealImage =
                        Image.network(meal['imageAsset'], fit: BoxFit.cover);
                  } else if (File(meal['imageAsset'] ?? '').existsSync()) {
                    mealImage =
                        Image.file(File(meal['imageAsset']), fit: BoxFit.cover);
                  } else {
                    mealImage = Image.asset(
                      'lib/assets/images/default.png',
                      fit: BoxFit.cover,
                    );
                  }
                  return RestaurantCard(
                    imageUrl: mealImage,
                    restaurantName: meal['mealName'] ?? '',
                    rating: 0.0, // not used for meals
                    averagePrice: meal['price'],
                    ingredients: meal[
                        'ingredients'], // pass ingredients for meal display
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // New bottom navigation bar
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // ...handle navigation...
        },
      ),
    );
  }
}
