import 'package:flutter/material.dart';

class AOrderWidget extends StatelessWidget {
  final String orderId;
  final DateTime date;
  final double price;
  final String customerId;
  final String restauramtId;

  const AOrderWidget({
    Key? key,
    required this.orderId,
    required this.date,
    required this.price,
    required this.customerId,
    required this.restauramtId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Order ID: $orderId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            Text('Price: $price'),
            Text('Customer ID: $customerId'),
            Text('Restaurant ID: $restauramtId'),
          ],
        ),
      ),
    );
  }
}
