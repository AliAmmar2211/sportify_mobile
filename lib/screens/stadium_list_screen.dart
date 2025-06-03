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

    if (filteredStadiums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00B16A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                showOnlyMine ? Icons.business : Icons.stadium,
                size: 64,
                color: const Color(0xFF00B16A),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              showOnlyMine ? 'No stadiums found' : 'No stadiums available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showOnlyMine 
                  ? 'Start by adding your first stadium'
                  : 'Check back later for new venues',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final stadium = filteredStadiums[index];
                  return Hero(
                    tag: 'stadium_${stadium.id}',
                    child: StadiumCard(
                      stadium: stadium,
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              BookingScreen(stadium: stadium),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;

                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(curve: curve),
                            );

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                      onEdit: showOnlyMine
                          ? () => Navigator.pushNamed(
                                context,
                                '/edit',
                                arguments: stadium,
                              )
                          : null,
                    ),
                  );
                },
                childCount: filteredStadiums.length,
              ),              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}