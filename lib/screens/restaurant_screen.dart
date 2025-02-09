import 'package:flutter/material.dart';
import 'package:foody/widgets/meal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foody/widgets/meal_list.dart';

class RestaurantScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  late Future<Map<String, dynamic>?> _restaurantDetails;
  final Map<dynamic, Map<String, dynamic>> _selectedMeals = {};
  List<Map<String, dynamic>> _meals = [];  // Add this line

  @override
  void initState() {
    super.initState();
    _restaurantDetails = _fetchRestaurantDetails();
  }

  Future<Map<String, dynamic>?> _fetchRestaurantDetails() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', widget.restaurant['id'])
          .single();
      return data;
    } catch (e) {
      debugPrint('Error fetching restaurant details: $e');
      return null;
    }
  }

  Future<List<dynamic>> _fetchMeals() async {
    try {
      final data = await Supabase.instance.client
          .from('meals')
          .select()
          .eq('restaurant_id', widget.restaurant['id']);
      _meals = List<Map<String, dynamic>>.from(data); // Store the meals
      return data;
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      return [];
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    _selectedMeals.forEach((_, meal) {
      total += (meal['price'] as num) * (meal['quantity'] as int);
    });
    return total + 20;
  }

  int _getTotalItems() {
    int total = 0;
    _selectedMeals.forEach((_, meal) {
      total += meal['quantity'] as int;
    });
    return total;
  }

  void _handleQuantityChanged(String id, int quantity) {
    setState(() {
      if (quantity > 0) {
        final meal = _meals.firstWhere((m) => m['id'] == id);
        _selectedMeals[id] = {...meal, 'quantity': quantity};
      } else {
        _selectedMeals.remove(id);
      }
    });
  }

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
                color: Colors.white,
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: widget.restaurant['img_url'] != null
                    ? NetworkImage(widget.restaurant['img_url'])
                        as ImageProvider<Object>
                    : const AssetImage('lib/assets/images/background.avif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _restaurantDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error loading restaurant details'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No restaurant details found'));
          } else {
            final details = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Information updated from restaurant data
                    Text(
                      details['restaurant_name'] ?? 'Restaurant Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      details['description'] ?? 'Mixed Cuisine',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // Restaurant Info Card (remains unchanged)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Restaurant Info',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.place, size: 16),
                                const SizedBox(width: 4),
                                Text(details['address'] ?? 'Address'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('Delivery Fee: \$20'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Meals List Header
                    const Text(
                      'Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Meals List using FutureBuilder without Expanded
                    FutureBuilder<List<dynamic>>(
                      future: _fetchMeals(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Error fetching meals'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No meals available'));
                        }

                        final meals = List<Map<String, dynamic>>.from(snapshot.data!);
                        return MealList(
                          meals: meals,
                          selectedMeals: _selectedMeals,
                          onQuantityChanged: _handleQuantityChanged,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: _selectedMeals.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Your Order'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._selectedMeals.entries.map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${entry.value['name']} x${entry.value['quantity']}'),
                                    Text('\$${(entry.value['price'] * entry.value['quantity']).toStringAsFixed(2)}'),
                                  ],
                                ),
                              )),
                          const Divider(),
                          const Text('Delivery Fee: \$20.00'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${_calculateTotalPrice().toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle checkout
                            Navigator.of(context).pop();
                          },
                          child: const Text('Confirm Order'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text('View Cart (${_getTotalItems()} items)'),
              ),
            )
          : null,
    );
  }
}
