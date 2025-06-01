import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportify_mobile/models/stadium.dart';
import 'package:sportify_mobile/providers/stadium_provider.dart';
import 'package:sportify_mobile/screens/booking_screen.dart';
import 'package:sportify_mobile/widgets/stadium_card.dart';

class StadiumListScreen extends StatelessWidget {
  final bool showOnlyMine;

  const StadiumListScreen({super.key, required this.showOnlyMine});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StadiumProvider>(context);
    List<Stadium> filteredStadiums = showOnlyMine
        ? provider.stadiums.where((s) => s.id! % 2 == 0).toList() // Mock "my" stadiums
        : provider.stadiums;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredStadiums.length,
      itemBuilder: (context, index) {
        final stadium = filteredStadiums[index];
        return StadiumCard(
          stadium: stadium,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(stadium: stadium),
            ),
          ),
          onEdit: showOnlyMine
              ? () => Navigator.pushNamed(
                    context,
                    '/edit',
                    arguments: stadium,
                  )
              : null,
        );
      },
    );
  }
}