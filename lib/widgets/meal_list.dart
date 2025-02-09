import 'package:flutter/material.dart';
import 'package:foody/widgets/meal.dart';

class MealList extends StatelessWidget {
  final List<Map<String, dynamic>> meals;
  final Map<dynamic, Map<String, dynamic>> selectedMeals;
  final Function(String id, int quantity) onQuantityChanged;

  const MealList({
    super.key,
    required this.meals,
    required this.selectedMeals,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        final initQty = selectedMeals[meal['id']]?['quantity'] ?? 0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Meal(
            key: ValueKey(meal['id']),
            id: meal['id'],
            name: meal['name'],
            description: meal['description'],
            price: meal['price'],
            imageUrl: meal['img_url'],
            initialQuantity: initQty,
            onQuantityChanged: (quantity) => 
                onQuantityChanged(meal['id'], quantity),
          ),
        );
      },
    );
  }
}
