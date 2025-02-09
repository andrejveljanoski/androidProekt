import 'package:flutter/material.dart';
import 'package:foody/widgets/primary_button.dart';
import 'package:foody/widgets/quantity_counter.dart';

class Meal extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int initialQuantity;
  final ValueChanged<int> onQuantityChanged;

  const Meal({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.initialQuantity = 0,
    required this.onQuantityChanged,
  });

  Widget buildMealImage() {
    // Check if the imageUrl is a network URL or an asset path.
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded border
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: buildMealImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            QuantityCounter(
              initialQuantity: initialQuantity,
              onQuantityChanged: onQuantityChanged,
            ),
          ],
        ),
      ),
    );
  }
}
