import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportify_mobile/screens/stadium_list_screen.dart';
import 'package:sportify_mobile/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sportify'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'profile') {
                  _showProfile(context);
                } else if (value == 'logout') {
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.stadium), text: 'Stadiums'),
              Tab(icon: Icon(Icons.list), text: 'My Stadiums'),
              Tab(icon: Icon(Icons.book), text: 'Bookings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StadiumListScreen(showOnlyMine: false),
            StadiumListScreen(showOnlyMine: true),
            Center(child: Text('My Bookings Screen')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user?.name ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Phone: ${user?.phoneNumber ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Role: ${user?.role.toString().split('.').last ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}