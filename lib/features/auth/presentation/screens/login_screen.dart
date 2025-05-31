import 'package:aksumfit/services/api_service.dart'; // Import ApiService
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

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
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: SafeArea(
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
                    style: cupertinoTheme.textTheme.navLargeTitleTextStyle
                        .copyWith(color: CupertinoColors.label),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue your fitness journey.',
                    textAlign: TextAlign.center,
                    style: cupertinoTheme.textTheme.textStyle
                        .copyWith(color: CupertinoColors.secondaryLabel),
                  ),
                  const SizedBox(height: 48),
                  CupertinoFormSection(
                    header: const Text('Credentials'),
                    children: [
                      CupertinoTextFormFieldRow(
                        controller: _emailController,
                        prefix: const Text('Email'),
                        placeholder: 'Enter your email',
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
                      CupertinoTextFormFieldRow(
                        controller: _passwordController,
                        prefix: const Text('Password'),
                        placeholder: 'Enter your password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        onPressed: () {
                          // TODO: Implement forgot password navigation/logic
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Forgot Password'),
                              content: const Text(
                                  'Password recovery is not yet implemented.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: cupertinoTheme.textTheme.actionTextStyle,
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
                        style: cupertinoTheme.textTheme.textStyle
                            .copyWith(color: CupertinoColors.destructiveRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : CupertinoButton.filled(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: cupertinoTheme.textTheme.textStyle
                            .copyWith(color: CupertinoColors.secondaryLabel),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: Text(
                          'Sign Up',
                          style: cupertinoTheme.textTheme.actionTextStyle
                              .copyWith(fontWeight: FontWeight.bold),
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
