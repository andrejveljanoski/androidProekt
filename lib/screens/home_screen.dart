import 'package:flutter/material.dart';
import 'package:foody/widgets/bottom_navigation.dart';
import 'package:foody/widgets/restaurant_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foody/screens/restaurant_screen.dart';

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
            'id': restaurant['id'],
            'img_url': restaurant['img_url'],
            'restaurant_name': restaurant['restaurant_name'],
            'address': restaurant['address'],
            'rating': restaurant['rating'] ?? 0.0,
            'average_price': restaurant['average_price'] ?? 0.0,
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
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantScreen(restaurant: restaurant),
                      ),
                    );
                  },
                  child: RestaurantCard(
                    imageUrl: restaurant['img_url'] is String
                        ? Image.network(restaurant['img_url'], fit: BoxFit.cover)
                        : Image.asset('lib/assets/images/default.png',
                            fit: BoxFit.cover),
                    restaurantName: restaurant['restaurant_name'] ?? '',
                    rating: restaurant['rating'],
                    averagePrice: restaurant['average_price'],
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: BottomNavigation(
          selectedIndex: 0, onDestinationSelected: (index) {}),
    );
  }
}
