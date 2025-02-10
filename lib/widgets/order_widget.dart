import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderWidget extends StatelessWidget {
  final String orderId;
  final DateTime date;
  final double amount;
  final String restaurantName;
  final List<Map<String, dynamic>> items;
  final double deliveryFee;  // Add this line

  const OrderWidget({
    super.key,
    required this.orderId,
    required this.date,
    required this.amount,
    required this.restaurantName,
    required this.items,
    required this.deliveryFee,  // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text('Order #$orderId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: $restaurantName'),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(date)}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Total: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['meal']['name']} x${item['quantity']}',
                          ),
                          Text(
                            '\$${(item['price_at_order'] * item['quantity']).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery Fee:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('\$$deliveryFee'),  // Update this line
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
