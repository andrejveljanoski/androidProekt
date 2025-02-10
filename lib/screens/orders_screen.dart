import 'package:flutter/material.dart';
import 'package:foody/widgets/bottom_navigation.dart';
import 'package:foody/widgets/order_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // First, check if the user is a restaurant
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('is_restaurant')
          .eq('id', user.id)
          .single();
      
      final isRestaurant = profileResponse['is_restaurant'] ?? false;

      // Fetch orders based on user type
      final orders = await Supabase.instance.client
          .from('orders')
          .select('''
            *,
            restaurant:profiles!orders_restaurant_id_fkey(restaurant_name),
            items:orders_table(
              quantity,
              price_at_order,
              meal:meals(name)
            ),
            delivery_fee
          ''')
          .eq(isRestaurant ? 'restaurant_id' : 'customer_id', user.id);

      return List<Map<String, dynamic>>.from(orders);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return OrderWidget(
                  orderId: order['id'].toString(),
                  date: DateTime.parse(order['date_of_order']),
                  amount: order['amount'].toDouble(),
                  restaurantName: order['restaurant']['restaurant_name'],
                  items: List<Map<String, dynamic>>.from(order['items']),
                  deliveryFee: order['delivery_fee'].toDouble(),  // Add this line
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 1,
        onDestinationSelected: (int index) async {
          if (index == 0) {
            final currentUser = Supabase.instance.client.auth.currentUser;
            if (currentUser == null) {
              Navigator.pushNamed(context, '/');
            } else {
              final response = await Supabase.instance.client
                  .from('profiles')
                  .select('is_restaurant')
                  .eq('id', currentUser.id)
                  .single();
              final dynamic userRole = response['is_restaurant'];

              if (userRole) {
                Navigator.pushNamed(context, '/restauranthomepage');
              } else {
                Navigator.pushNamed(context, '/homescreen');
              }
            }
          } else if (index == 2) {
            Navigator.pushNamed(context, '/account');
          }
        },
      ),
    );
  }
}
