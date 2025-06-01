import 'package:flutter/material.dart';
import 'package:sportify_mobile/models/stadium.dart';

class StadiumCard extends StatelessWidget {
  final Stadium stadium;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const StadiumCard({
    super.key,
    required this.stadium,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [                Expanded(
                  child: Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.stadium,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stadium.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stadium.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: onEdit,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}