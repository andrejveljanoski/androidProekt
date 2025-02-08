import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foody/widgets/input_field.dart';
import 'package:foody/widgets/primary_button.dart';
import 'package:foody/widgets/restaurant_card.dart';
import 'package:image_picker/image_picker.dart'; // new import for image picker
import 'package:foody/widgets/bottom_navigation.dart'; // new import for bottom navigation

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

  // Hardcoded meals with imageAsset key
  final List<Map<String, dynamic>> _meals = [
    {
      'mealName': 'Spaghetti',
      'price': 12.99,
      'ingredients': 'Pasta, Tomato, Basil',
      'imageAsset': 'lib/assets/images/spaghetti.png'
    },
    {
      'mealName': 'Burger',
      'price': 9.99,
      'ingredients': 'Bun, Beef, Lettuce, Tomato',
      'imageAsset': 'lib/assets/images/burger.png'
    },
    {
      'mealName': 'Salad',
      'price': 7.50,
      'ingredients': 'Lettuce, Cucumber, Carrot',
      'imageAsset': 'lib/assets/images/salad.png'
    },
  ];

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _addMeal() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _meals.add({
          'mealName': _mealNameController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'description': _mealNameController.text,

          // If a new image is selected, store its path; otherwise leave as empty
          'imageAsset': _selectedImage != null
              ? _selectedImage!.path
              : 'lib/assets/images/default.png',
        });
        _mealNameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _ingredientsList.clear();
        _selectedImage = null;
      });
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
                    labelText: 'Price',
                    keyboardType: TextInputType.number,
                    controller: _priceController,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    labelText: 'Description',
                    keyboardType: TextInputType.text,
                    controller: _descriptionController,
                    obscureText: false,
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
                  if (File(meal['imageAsset']).existsSync()) {
                    mealImage = Image.file(
                      File(meal['imageAsset']),
                      fit: BoxFit.cover,
                    );
                  } else {
                    mealImage = Image.asset(
                      meal['imageAsset'] ?? 'lib/assets/images/default.png',
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
