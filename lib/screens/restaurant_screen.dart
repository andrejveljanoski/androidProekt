import 'package:flutter/material.dart';
import 'package:foody/widgets/meal.dart'; // ensure Meal is imported

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final List<Map<String, dynamic>> meals = [
    {
      'name': 'Classic Burger',
      'description': 'Juicy beef patty with fresh vegetables',
      'price': 15.99,
      'imageUrl': 'lib/assets/images/background.avif',
    },
    {
      'name': 'Chicken Salad',
      'description': 'Fresh greens with grilled chicken breast',
      'price': 12.99,
      'imageUrl': 'lib/assets/images/background.avif',
    },
    {
      'name': 'Margherita Pizza',
      'description': 'Traditional Italian pizza with fresh mozzarella',
      'price': 18.99,
      'imageUrl': 'lib/assets/images/background.avif',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(
              child: Material(
                color: Colors.white, // Circle background color
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/background.avif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        // classic background used throughout the app
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromRGBO(255, 242, 241, 1)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Restaurant Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'American cuisine',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Restaurant info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.place),
                            SizedBox(width: 8),
                            Text('Address'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Delivery Fee: 20\$'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Meal(
              name: 'Classic Burger',
              description: 'Juicy beef patty with fresh vegetables',
              price: 15.99,
              imageUrl: 'lib/assets/images/background.avif',
            ),
            const SizedBox(height: 8),
            Meal(
              name: 'Chicken Salad',
              description: 'Fresh greens with grilled chicken breast',
              price: 12.99,
              imageUrl: 'lib/assets/images/background.avif',
            ),
            const SizedBox(height: 8),
            Meal(
              name: 'Margherita Pizza',
              description: 'Traditional Italian pizza with fresh mozzarella',
              price: 18.99,
              imageUrl: 'lib/assets/images/background.avif',
            ),
          ],
        ),
      ),
    );
  }
}
