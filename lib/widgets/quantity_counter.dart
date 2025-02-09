import 'package:flutter/material.dart';

class QuantityCounter extends StatefulWidget {
  final int initialQuantity;
  final ValueChanged<int> onQuantityChanged;

  const QuantityCounter({
    super.key,
    this.initialQuantity = 0,
    required this.onQuantityChanged,
  });

  @override
  State<QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<QuantityCounter> {
  late int _quantity;
  late bool _isCounter;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _isCounter = widget.initialQuantity > 0;
  }

  void _toggleCounter() {
    setState(() {
      _isCounter = true;
      if (_quantity == 0) _quantity = 1;
    });
    widget.onQuantityChanged(_quantity);
  }

  void _updateQuantity(bool increment) {
    setState(() {
      if (increment) {
        _quantity++;
      } else if (_quantity > 1) {
        _quantity--;
      } else {
        _quantity = 0;
        _isCounter = false;
      }
    });
    widget.onQuantityChanged(_quantity);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCounter) {
      return IconButton(
        icon: const Icon(Icons.add_circle_outline, size: 30),
        onPressed: _toggleCounter,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => _updateQuantity(false),
        ),
        Text(
          '$_quantity',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _updateQuantity(true),
        ),
      ],
    );
  }
}
