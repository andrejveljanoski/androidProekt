import 'package:flutter/material.dart';
import 'package:foody/widgets/card_with_icon.dart';
import 'package:foody/widgets/bottom_navigation.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          CardWithIcon(
            icon: Icon(Icons.home),
            title: 'Delivery Address',
            description: 'skopje 1000',
          ),
          CardWithIcon(
            icon: Icon(Icons.manage_accounts),
            title: 'Account Details',
            description: 'Details',
          ),
          CardWithIcon(
            icon: Icon(Icons.login),
            title: 'Sign Out',
            color: Colors.red,
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
