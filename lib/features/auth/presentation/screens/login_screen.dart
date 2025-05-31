import 'package:aksumfit/services/api_service.dart';
import 'package:flutter/material.dart'; // Added Material import
import 'package:flutter_form_builder/flutter_form_builder.dart'; // Added FormBuilder
import 'package:form_builder_validators/form_builder_validators.dart'; // Added Validators
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Added Provider for AuthManager
import 'package:aksumfit/services/auth_manager.dart'; // Added AuthManager

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>(); // Changed to FormBuilderState
  bool _obscurePassword = true; // State for password visibility
  bool _isLoading = false;
  String? _errorMessage;

  // Adapted _login method
  Future<void> _login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResponse = await ApiService().login(
        email: email,
        password: password,
      );

      if (authResponse.user != null && authResponse.token != null && mounted) {
        // Use Provider to set user and token
        Provider.of<AuthManager>(context, listen: false).setUser(authResponse.user!, authResponse.token!);
        context.go('/main');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get Material theme

    return Scaffold( // Changed to Scaffold
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar( // Changed to AppBar
        title: const Text('Login'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),

      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder( // Changed to FormBuilder
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue your fitness journey.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 48),
                  FormBuilderTextField(
                    name: 'email',
                    initialValue: 'demo@axumfit.com', // For easier testing
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'password',
                    initialValue: 'demo123', // For easier testing
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    obscureText: _obscurePassword,
                    validator: FormBuilderValidators.required(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton( // Changed to TextButton
                        onPressed: () {
                          // TODO: Implement forgot password navigation/logic
                          showDialog( // Changed to showDialog for Material
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Forgot Password'),
                              content: const Text(
                                  'Password recovery is not yet implemented.'),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator()) // Changed to CircularProgressIndicator
                      : ElevatedButton( // Changed to ElevatedButton
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(12.0),
                             ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.saveAndValidate() ?? false) {
                              final formData = _formKey.currentState!.value;
                              _login(formData['email'], formData['password']);
                            }
                          },
                          child: const Text('Login'),
                        ),
                  const SizedBox(height: 32),
                  Row(
                    children: <Widget>[
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('OR', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent), // Placeholder, replace with actual Google icon
                    label: Text('Continue with Google', style: TextStyle(color: theme.colorScheme.onSurface)),
                    onPressed: () { /* Placeholder for Google Sign In */ },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerLowest, // Light background
                      foregroundColor: theme.colorScheme.onSurface, // Text color
                      side: BorderSide(color: theme.dividerColor), // Border color
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12.0),
                       ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.apple, color: Colors.black), // Placeholder, replace with actual Apple icon
                    label: Text('Continue with Apple', style: TextStyle(color: theme.colorScheme.onSurface)),
                    onPressed: () { /* Placeholder for Apple Sign In */ },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerLowest,
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.dividerColor),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12.0),
                       ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      TextButton( // Changed to TextButton
                        onPressed: () {
                          context.go('/register');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold),
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
