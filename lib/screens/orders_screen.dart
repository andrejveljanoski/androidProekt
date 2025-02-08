import 'package:flutter/material.dart';
import 'package:foody/widgets/bottom_navigation.dart';
import 'package:foody/widgets/aorder_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: ListView(
        children: [
          AOrderWidget(
            orderId: '1',
            date: DateTime(2023, 1, 1),
            price: 29.99,
            customerId: 'customer1',
            restauramtId: 'restaurant1',
          ),
          AOrderWidget(
            orderId: '2',
            date: DateTime(2023, 1, 2),
            price: 49.99,
            customerId: 'customer2',
            restauramtId: 'restaurant2',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 1,
        onDestinationSelected: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/account');
          }
        },
      ),
    );
  }
}
