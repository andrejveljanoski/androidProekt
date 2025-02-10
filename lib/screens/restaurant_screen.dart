// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foody/widgets/meal_list.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  late Future<Map<String, dynamic>?> _restaurantDetails;
  final Map<dynamic, Map<String, dynamic>> _selectedMeals = {};
  List<Map<String, dynamic>> _meals = []; // Add this line
  double? _deliveryFee;
  String? _estimatedTime;

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

      // Calculate delivery details after fetching restaurant data
      if (data['address'] != null) {
        await _calculateDeliveryDetails(data['address']);
      }

      return data;
    } catch (e) {
      debugPrint('Error fetching restaurant details: $e');
      return null;
    }
  }

  Future<void> _calculateDeliveryDetails(String restaurantAddress) async {
    try {
      // Get current location
      final Position currentPosition = await Geolocator.getCurrentPosition();

      // Get restaurant coordinates from address
      final List<Location> restaurantCoords =
          await locationFromAddress(restaurantAddress);

      if (restaurantCoords.isEmpty) {
        throw Exception('Could not find restaurant location');
      }

      // Calculate distance in kilometers
      final double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        restaurantCoords.first.latitude,
        restaurantCoords.first.longitude,
      );

      final double distanceInKm = distanceInMeters / 1000;

      // Calculate delivery fee: Base fee $5 + $2 per km, rounded to 1 decimal place
      final double fee =
          double.parse((5 + (distanceInKm * 2)).toStringAsFixed(1));

      // Calculate ETA: Assume average speed of 30 km/h
      final double timeInHours = distanceInKm / 30;
      final int timeInMinutes = (timeInHours * 60).round();

      setState(() {
        _deliveryFee = fee;
        _estimatedTime = '$timeInMinutes min';
      });
    } catch (e) {
      debugPrint('Error calculating delivery details: $e');
      // Fallback to default values
      setState(() {
        _deliveryFee = 20.0; // Make sure default is also clean
        _estimatedTime = '45 min';
      });
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
      // Convert price to double if it's an int
      final price = (meal['price'] is int)
          ? (meal['price'] as int).toDouble()
          : meal['price'] as double;
      total += price * (meal['quantity'] as int);
    });
    return total + (_deliveryFee ?? 20);
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

  Future<void> _createOrder() async {
    try {
      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to place an order')),
        );
        return;
      }

      // Create order
      final orderData = await Supabase.instance.client
          .from('orders')
          .insert({
            'amount': _calculateTotalPrice(),
            'date_of_order': DateTime.now().toIso8601String(),
            'customer_id': user.id,
            'restaurant_id': widget.restaurant['id'],
            'delivery_fee':
                _deliveryFee ?? 5.0, // Add delivery fee to the order
          })
          .select()
          .single();

      // Create order items
      final orderItems = _selectedMeals.entries
          .map((entry) => {
                'order_id': orderData['id'],
                'meal_id': entry.key,
                'quantity': entry.value['quantity'],
                'price_at_order': entry.value['price'],
              })
          .toList();

      await Supabase.instance.client.from('orders_table').insert(orderItems);

      // Show success message and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.of(context).pushReplacementNamed('/orders');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Delivery Fee: \$${_deliveryFee?.toStringAsFixed(2) ?? "Calculating..."}'),
                                Text(
                                    'ETA: ${_estimatedTime ?? "Calculating..."}'),
                              ],
                            ),
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
                          return const Center(
                              child: Text('Error fetching meals'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No meals available'));
                        }

                        final meals =
                            List<Map<String, dynamic>>.from(snapshot.data!);
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${entry.value['name']} x${entry.value['quantity']}'),
                                    Text(
                                        '\$${(entry.value['price'] * entry.value['quantity']).toStringAsFixed(2)}'),
                                  ],
                                ),
                              )),
                          const Divider(),
                          Text('Delivery Fee: \$$_deliveryFee'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
                            Navigator.of(context).pop();
                            _createOrder();
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
