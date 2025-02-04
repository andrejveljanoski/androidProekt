import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foody/screens/email_signup.dart';
import 'package:foody/screens/home_screen.dart';
import 'screens/welcome_page.dart';
import 'screens/login_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // await dotenv.load(fileName: ".env");
    // await Supabase.initialize(
    //   url: dotenv.env['SUPABASE_URL']!,
    //   anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    // );
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
        '/login': (context) => const LoginForm(),
        '/home': (context) => const MyHomePage(title: 'Foody'),
        '/signup': (context) => const EmailSignup(),
        '/homescreen': (context) => const HomeScreen(),
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
