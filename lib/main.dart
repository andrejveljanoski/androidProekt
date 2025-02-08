import 'package:flutter/material.dart';
import 'package:foody/screens/account_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Uncommented supabase import
import 'package:foody/screens/email_signup.dart';
import 'package:foody/screens/home_screen.dart';
import 'package:foody/screens/restaurant_homepage.dart';
import 'screens/welcome_page.dart';
import 'screens/login_form.dart';
import 'screens/orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Uncomment and add your Supabase initialization details here
    await Supabase.initialize(
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpwY2NnYXVodGdlYmlrcnJlYXB1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4NTEyMDksImV4cCI6MjA1MzQyNzIwOX0.Vjp2fwaGE8q_-UZuUgv2vBL4CiM3aVn_j_Ln2SeSCW8', // replace with your Supabase URL
      url:
          'https://jpccgauhtgebikrreapu.supabase.co', // replace with your Supabase anon key
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization failed: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // Start with LoginPage first for better flow
      home: const WelcomePage(),
      routes: {
        '/login': (context) => const RestaurantHomepage(),
        '/home': (context) => const MyHomePage(title: 'Foody'),
        '/signup': (context) => const EmailSignup(),
        '/homescreen': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/restauranthomepage': (context) => const RestaurantHomepage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text("Hello"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        tooltip: 'Nav',
        child: const Icon(Icons.login),
      ),
    );
  }
}
