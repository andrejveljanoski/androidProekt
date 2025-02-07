import 'package:flutter/material.dart';
import 'package:foody/widgets/icon_text_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  // final SupabaseClient _client = Supabase.instance.client;

// Future<void> _signInWithEmail() async {
//   // final response = await
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            IconTextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              text: 'Continue with email',
              icon: Image.asset('lib/assets/icons/email.png'),
            ),
            const SizedBox(height: 16),
            IconTextButton(
              onPressed: () {},
              text: 'Continue with Google',
              icon: Image.asset('lib/assets/icons/google.png'),
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 16),
            IconTextButton(
              onPressed: () {},
              text: 'Continue with Apple',
              icon: Image.asset('lib/assets/icons/apple.png'),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}
