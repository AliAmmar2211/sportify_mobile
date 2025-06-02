import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportify_mobile/providers/stadium_provider.dart';
import 'package:sportify_mobile/providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_edit_stadium_screen.dart';
import 'package:sportify_mobile/screens/booking_screen.dart';
import 'package:sportify_mobile/models/stadium.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => StadiumProvider()..loadStadiums()),
      ],
      child: MaterialApp(
        title: 'Sportify - Stadium Booking',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/add': (context) => const AddEditStadiumScreen(),
          '/edit': (context) => const AddEditStadiumScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}