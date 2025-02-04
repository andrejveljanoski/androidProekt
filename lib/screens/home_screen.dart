import 'package:flutter/material.dart';
import 'package:foody/widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> restaurants = [
    {
      'imageUrl': 'https://example.com/image1.jpg',
      'restaurantName': 'Pizza Palace',
      'rating': 4,
      'averagePrice': 20,
    },
    {
      'imageUrl': 'https://example.com/image2.jpg',
      'restaurantName': 'Sushi Central',
      'rating': 5,
      'averagePrice': 35,
    },
    {
      'imageUrl': 'https://example.com/image3.jpg',
      'restaurantName': 'Burger Bonanza',
      'rating': 3,
      'averagePrice': 15,
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
            }));
  }
}
