import 'package:aksumfit/services/api_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/services/settings_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register(String fullName, String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResponse = await ApiService().register(
        name: fullName,
        email: email,
        password: password,
      );

      if (mounted) {
        final user = authResponse.user;
        Provider.of<AuthManager>(context, listen: false).setUser(user);
        Provider.of<SettingsService>(context, listen: false).setHasCompletedOnboarding(true); // This seems to be for general app onboarding, not profile setup

        if (user != null && user.hasCompletedSetup == true) {
          context.go('/main');
        } else {
          // User is new or hasn't completed setup, navigate to setup flow
          context.go('/setup/weight-height');
        }
      } else {
        // This case might be rare if mounted is false, but good to have a fallback.
        // If not mounted, can't use context.go. Error message is for the current screen if it were to rebuild.
        setState(() {
          _errorMessage = "Registration failed. Please try again.";
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sign Up'),
         backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your fitness journey with AxumFit.',
                    textAlign: TextAlign.center,
                     style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  FormBuilderTextField(
                    name: 'full_name',
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'email',
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters long'),
                    ]),
                  ),
                   Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      'Use 8 or more characters with a mix of letters, numbers & symbols.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'confirm_password',
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      (val) {
                        if (val !=
                            _formKey.currentState?.fields['password']?.value) {
                          return 'Passwords do not match';
                        }
                        return null;
                      }
                    ]),
                  ),
                  const SizedBox(height: 24),
                  FormBuilderCheckbox(
                    name: 'accept_terms',
                    initialValue: false,
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'I accept the ',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          TextSpan(
                            text: 'Terms of Service',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Implement navigation to Terms of Service
                                print('Navigate to Terms of Service');
                              },
                          ),
                          TextSpan(
                              text: ' & ',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Implement navigation to Privacy Policy
                                print('Navigate to Privacy Policy');
                              },
                          ),
                        ],
                      ),
                    ),
                    validator: FormBuilderValidators.required(
                        errorText:
                            'You must accept the terms and conditions to continue'),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      errorStyle: TextStyle(color: theme.colorScheme.error),
                      border: InputBorder.none, // Remove border from checkbox itself
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
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
                              _register(formData['full_name'], formData['email'], formData['password']);
                            }
                          },
                          child: const Text('Create Account'),
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
                    icon: const Icon(Icons.g_mobiledata, color: Colors.blueAccent),
                    label: Text('Continue with Google', style: TextStyle(color: theme.colorScheme.onSurface)),
                    onPressed: () { /* Placeholder */ },
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
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.apple, color: Colors.black),
                    label: Text('Continue with Apple', style: TextStyle(color: theme.colorScheme.onSurface)),
                    onPressed: () { /* Placeholder */ },
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
                        'Already have an account?',
                         style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Login',
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
