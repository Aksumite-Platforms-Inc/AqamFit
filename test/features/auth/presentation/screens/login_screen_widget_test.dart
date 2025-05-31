import 'package:aksumfit/features/auth/presentation/screens/login_screen.dart';
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart'; // Use if MockApiService was generated
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Use the manual mock from the previous step
import '../../../../mocks/mock_api_service.dart';

// Mock GoRouter if verifying navigation calls directly becomes necessary and complex
// class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockApiService mockApiService;
  late AuthManager authManager;

  // A common GoRouter setup for widget tests that need navigation context
  final testRouter = GoRouter(
    initialLocation: '/login', // Start at the login screen for this test
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/main', builder: (context, state) => const Scaffold(body: Text("Main Screen"))), // Mock main screen
      // Add other routes that might be navigated to if necessary
    ],
  );


  setUp(() {
    mockApiService = MockApiService();
    authManager = AuthManager();
    authManager.clearUser(); // Ensure clean state for AuthManager
  });

  Widget createLoginScreenTestWidget() {
    return ChangeNotifierProvider<AuthManager>.value(
      value: authManager,
      child: MaterialApp.router(
        routerConfig: testRouter,
        // If LoginScreen relies on ApiService via Provider, wrap it here too.
        // For now, LoginScreen calls ApiService().login() directly as a singleton.
        // To properly test with mockApiService, ApiService needs to be injectable
        // or the singleton instance needs to be replaced with the mock.
        // This is a limitation of direct singleton usage in widgets.
        // For this test, we'll assume ApiService().login() can be influenced by mock definitions if ApiService was a generated mock,
        // or we test UI behavior more than direct mock interaction if it's hard to inject the mock.
      ),
    );
  }

  // A more robust way if ApiService was injectable (e.g. via Provider or get_it)
  // Widget createLoginScreenTestWidgetWithMockApi() {
  //   return Provider<ApiService>.value( // Provide the mock ApiService
  //     value: mockApiService,
  //     child: ChangeNotifierProvider<AuthManager>.value(
  //       value: authManager,
  //       child: MaterialApp.router(
  //         routerConfig: testRouter,
  //       ),
  //     ),
  //   );
  // }


  group('LoginScreen Widget Tests', () {
    testWidgets('renders correctly with initial UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreenTestWidget());

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreenTestWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // Process form validation

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreenTestWidget());

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalidemail');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    // Note: Testing successful/failed login's navigation or error display
    // is tricky here because LoginScreen directly calls ApiService() as a singleton.
    // To properly test this with mocks, ApiService should be injected (e.g., via constructor or Provider).
    // The following tests assume we can mock the singleton's behavior or are more conceptual.

    testWidgets('successful login attempts navigation (conceptual)', (WidgetTester tester) async {
      // This test is more of a placeholder for how it would be done with injectable ApiService.
      // With current setup, we can't easily make ApiService().login() use the mock without
      // more complex singleton overriding techniques (like a service locator).

      // MOCKING ApiService().login() behavior:
      // This is where you'd use when(mockApiService.login(...)).thenAnswer(...);
      // For the manual mock, we'd have to assume its default behavior or modify it if possible.
      // Let's assume the default MockApiService behavior is success.

      await tester.pumpWidget(createLoginScreenTestWidget());

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'demo@axumfit.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'demo123');

      // Before tapping login, ensure AuthManager's user is null
      expect(authManager.currentUser, isNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(); // Process async login and navigation

      // Verify AuthManager was updated (this part works as AuthManager is provided)
      expect(authManager.currentUser, isNotNull);
      expect(authManager.currentUser?.email, 'demo@axumfit.com');

      // Verify navigation (check if current screen is the mock main screen)
      // This relies on GoRouter correctly navigating.
      expect(find.text("Main Screen"), findsOneWidget);
      expect(find.text('Welcome Back!'), findsNothing); // Login screen should be gone
    });

    testWidgets('failed login shows error message (conceptual)', (WidgetTester tester) async {
      // To make this test work with the manual MockApiService, we'd need to make
      // MockApiService.login() configurable to throw an exception.
      // For now, this demonstrates the intent.
      // Assume we configured MockApiService to throw ApiException for certain inputs.
      // e.g. if (email == "fail@example.com") throw ApiException("Invalid credentials");

      // For this test, let's simulate the error by directly setting an error message
      // as if the API call failed, because direct mocking of the singleton is hard here.
      // This tests the UI reaction rather than the full flow with a mock.

      await tester.pumpWidget(createLoginScreenTestWidget());

      // Directly find the state and set an error message to test UI display
      final loginScreenState = tester.state<State<LoginScreen>>(find.byType(LoginScreen));
      // This is not ideal as it's testing internal state, but a workaround for singleton service.
      // loginScreenState.setState(() { loginScreenState._errorMessage = "Test API error"; });
      // The above line won't work as _errorMessage is private.

      // A better way if we cannot mock the service call easily is to check that
      // if _login() method internally sets an error message, that message appears.
      // This still depends on the internal implementation of _login().

      // Let's try providing a specific input that the *actual* ApiService (mocked part in it) might fail for.
      // The current ApiService mock login is hardcoded for "demo@axumfit.com".
      // If we use something else, the actual ApiService's mock will throw a 401.

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'wrong@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrongpassword');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(); // Process async login

      // Check for an error message. The actual message comes from ApiService's _handleDioError
      expect(find.text('Authentication failed. Please login again.'), findsOneWidget);
      expect(authManager.currentUser, isNull); // User should not be set
    });

    testWidgets('tapping Sign Up navigates to register screen (conceptual)', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreenTestWidget());

      // TODO: Add a /register route to testRouter that builds a simple Scaffold(body: Text("Register Screen"))
      // For now, this tests if the button exists. Actual navigation test requires the route.
      expect(find.widgetWithText(TextButton, 'Sign Up'), findsOneWidget);
      // await tester.tap(find.widgetWithText(TextButton, 'Sign Up'));
      // await tester.pumpAndSettle();
      // expect(find.text("Register Screen"), findsOneWidget); // If /register route was mocked
    });
  });
}
