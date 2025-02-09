import 'package:flutter/material.dart';
import 'package:foody/widgets/primary_button.dart';

class Meal extends StatefulWidget {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const Meal({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<Meal> createState() => _MealState();
}

class _MealState extends State<Meal> {
  bool _isCounter = false;
  int _quantity = 0;

  void _toggleCounter() {
    setState(() {
      _isCounter = true;
      _quantity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // rounded border
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isCounter)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 80, minHeight: 36), // added constraints
                child: PrimaryButton(
                  onPressed: _toggleCounter,
                  text: 'Add',
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (_quantity > 0) _quantity--;
                      });
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
