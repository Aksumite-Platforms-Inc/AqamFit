import 'package:aksumfit/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@axumfit.com'); // For easier testing
  final _passwordController = TextEditingController(text: 'demo123'); // For easier testing
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Use ApiService for login
        final authResponse = await ApiService().login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (authResponse.success && mounted) {
          context.go('/main'); // Navigate to main app screen
        } else {
          setState(() {
            _errorMessage = authResponse.message ?? 'Login failed. Please try again.';
          });
        }
      } on ApiException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue your fitness journey.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      // Password length check can be removed if API handles it
                      // if (value.length < 6) {
                      //   return 'Password must be at least 6 characters';
                      // }
                      return null;
                    },
                  ),
                  // Forgot Password Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password navigation/logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Forgot Password clicked')),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Adjusted spacing
                  // Error Message Display
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Login Button
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16), // Taller button
                          ),
                          child: const Text('Login'),
                        ),
                  const SizedBox(height: 24),
                  // Navigate to Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/register'); // Navigate to registration screen
                        },
                        child: Text(
                          'Sign Up',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
