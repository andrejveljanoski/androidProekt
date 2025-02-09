import 'package:flutter/material.dart';
import 'package:foody/widgets/bottom_navigation.dart';
import 'package:foody/widgets/restaurant_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      // Fetch profiles where is_restaurant flag is true
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('is_restaurant', true) as List<dynamic>;
      setState(() {
        _restaurants.clear();
        for (final restaurant in data) {
          _restaurants.add({
            'imageUrl': restaurant['img_url'], // adjust column names if needed
            'restaurantName': restaurant['restaurant_name'],
            'rating':
                restaurant['rating'] ?? 0.0, // default value if not provided
            'averagePrice': restaurant['average_price'] ?? 0.0, // default value
          });
        }
      });
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _restaurants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _restaurants.map((restaurant) {
                return RestaurantCard(
                  imageUrl: restaurant['imageUrl'] is String
                      ? Image.network(restaurant['imageUrl'], fit: BoxFit.cover)
                      : Image.asset('lib/assets/images/default.png',
                          fit: BoxFit.cover),
                  restaurantName: restaurant['restaurantName'] ?? '',
                  rating: restaurant['rating'],
                  averagePrice: restaurant['averagePrice'],
                );
              }).toList(),
            ),
      bottomNavigationBar: BottomNavigation(
          selectedIndex: 0, onDestinationSelected: (index) {}),
    );
  }
}
