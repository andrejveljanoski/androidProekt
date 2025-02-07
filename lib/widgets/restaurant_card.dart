import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final Widget imageUrl;
  final String restaurantName; // for meal: meal name
  final double rating;
  final double averagePrice; // for meal: price
  final String? ingredients; // new optional parameter for meal ingredients

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.restaurantName,
    required this.rating,
    required this.averagePrice,
    this.ingredients, // can be null for restaurants
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use provided image widget
          SizedBox(
            height: 200,
            width: double.infinity,
            child: imageUrl,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ingredients != null 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingredients: $ingredients',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: \$${averagePrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          restaurantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.yellow),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\$${averagePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
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
