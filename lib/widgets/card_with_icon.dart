import 'package:flutter/material.dart';

class CardWithIcon extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final Color? color;
  final bool? showDescription;

  const CardWithIcon({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.color,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: icon!,
            )
          else
            const SizedBox(width: 0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black,
                  ),
                ),
                if (showDescription == true && description != null)
                  Row(
                    children: [
                      Icon(Icons.add),
                      Text(
                        description!,
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
