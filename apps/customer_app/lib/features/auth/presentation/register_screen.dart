import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join King Auto',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const TextField(
                    decoration: InputDecoration(labelText: 'First name'),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Last name'),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Australian mobile number',
                      hintText: '0412 345 678',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Create account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
