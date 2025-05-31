import 'package:aksumfit/services/api_service.dart'; // Import ApiService
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authResponse = await ApiService().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (authResponse.success && mounted) {
          // Show a success message and navigate to login
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Registration Successful'),
              content: const Text('You can now login with your new account.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _errorMessage = authResponse.message ?? 'Registration failed. Please try again.';
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sign Up'),
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
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: cupertinoTheme.textTheme.navLargeTitleTextStyle
                        .copyWith(color: CupertinoColors.label),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your fitness journey with AxumFit.',
                    textAlign: TextAlign.center,
                    style: cupertinoTheme.textTheme.textStyle
                        .copyWith(color: CupertinoColors.secondaryLabel),
                  ),
                  const SizedBox(height: 48),
                  CupertinoFormSection(
                    header: const Text('Account Information'),
                    children: [
                      CupertinoTextFormFieldRow(
                        controller: _nameController,
                        prefix: const Text('Full Name'),
                        placeholder: 'Enter your full name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
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
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        controller: _confirmPasswordController,
                        prefix: const Text('Confirm'),
                        placeholder: 'Confirm your password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                          onPressed: _register,
                          child: const Text('Create Account'),
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: cupertinoTheme.textTheme.textStyle
                            .copyWith(color: CupertinoColors.secondaryLabel),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Login',
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
