import 'package:flutter/material.dart';
import 'package:foody/widgets/bottom_navigation.dart';
import 'package:foody/widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> restaurants = [
    {
      'imageUrl': Image.asset('lib/assets/images/background.avif'),
      'restaurantName': 'Pizza Palace',
      'rating': 4.0,
      'averagePrice': 20.99,
    },
    {
      'imageUrl': Image.asset('lib/assets/images/background.avif'),
      'restaurantName': 'Sushi Central',
      'rating': 5.0,
      'averagePrice': 35.00,
    },
    {
      'imageUrl': Image.asset('lib/assets/images/background.avif'),
      'restaurantName': 'Burger Bonanza',
      'rating': 3.2,
      'averagePrice': 15.99,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantCard(
              imageUrl: restaurant['imageUrl'],
              restaurantName: restaurant['restaurantName'],
              rating: restaurant['rating'],
              averagePrice: restaurant['averagePrice'],
            );
          }),
      bottomNavigationBar:
          BottomNavigation(selectedIndex: 0, onDestinationSelected: (index) {}),
    );
  }
}
