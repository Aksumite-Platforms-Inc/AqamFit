import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

// If using @GenerateMocks with build_runner:
// @GenerateMocks([GoRouter])
// Then import 'mock_router.mocks.dart'

class MockGoRouter extends Mock implements GoRouter {
  // Add default behaviors for methods commonly used if not overridden in tests
  @override
  void go(String location, {Object? extra}) {
    // In tests, use `verify(mockGoRouter.go(captureAny, extra: captureAnyNamed('extra')))`
    // This default implementation helps avoid MissingStubError if not explicitly stubbed.
    super.noSuchMethod(Invocation.method(#go, [location], {#extra: extra}), returnValueForMissingStub: null);
  }

  @override
  bool canPop() {
    // Default to true, can be overridden with `when(mockGoRouter.canPop()).thenReturn(false);`
    return (super.noSuchMethod(Invocation.method(#canPop, []), returnValue: true) as bool);
  }

  @override
  void pop<T extends Object?>([T? result]) {
    super.noSuchMethod(Invocation.method(#pop, [result]), returnValueForMissingStub: null);
  }
}

// Helper function to pump a widget that uses GoRouter,
// providing a MaterialApp with a router configuration.
// This is useful if the widget itself doesn't instantiate MaterialApp.router.
// For testing widgets that are routed to by GoRouter (screens),
// you typically wrap them in MaterialApp and provide providers.
// The GoRouter instance itself can be provided via Provider or RouterScope.
Widget pumpWidgetWithProvidersAndRouter({
  required Widget child,
  required GoRouter router, // Use the mock router here
  Map<Type, Object> providers = const {}, // For ViewModels, Services
}) {
  Widget widget = child;

  // Apply providers if any
  providers.forEach((type, instance) {
    // This is a simplified way; real Provider setup might differ based on Provider type (Provider, ChangeNotifierProvider, etc.)
    // For ChangeNotifierProvider, it would be:
    // widget = ChangeNotifierProvider(create: (_) => instance as ChangeNotifier, child: widget);
    // This example assumes direct Provider.value or similar if instance is already created.
    // For this project, direct use in MultiProvider is more common.
  });


  // Wrap with MaterialApp.router
  // A simple GoRouter setup for testing a single screen/widget
  final testRouter = GoRouter(
    // Use the provided mock router instance for navigation interception
    // This is tricky because GoRouter.routerDelegate and .routeInformationParser
    // are final. We can't directly replace the GoRouter instance used by MaterialApp.router
    // after it's created with a new mock for each test easily without complex setups.
    //
    // A more common approach for widget tests is to NOT test the routing behavior itself,
    // but to mock the GoRouter provided to the widget IF it's directly accessed via Provider
    // or to use a NavigatorObserver to check pushed routes if using standard Navigator.
    //
    // If context.go() is called, the GoRouter needs to be "above" in the widget tree.
    // One way is to use RouterConfig:
    // routerConfig: GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => child)]),
    // and then somehow make *that* GoRouter instance use our mock for its navigation methods,
    // or use a testing-specific GoRouter setup.
    //
    // For widget tests focusing on the widget's behavior *before* navigation,
    // providing a mock GoRouter via Provider is often the most straightforward.
    // Let's assume the widget under test will look up GoRouter via Provider.
    // This means the test setup needs to include:
    // Provider<GoRouter>.value(value: mockGoRouter, child: MaterialApp(home: widgetUnderTest))
    // OR if it's a routed screen:
    // MaterialApp.router(routerConfig: testScreenRouteConfig(mockGoRouter))
    // where testScreenRouteConfig would use the mock.

    // Simpler for now: MaterialApp with home, and assume GoRouter is provided higher up or we use a mock navigator.
    // This helper might not be universally applicable without more context on how GoRouter is provided to widgets.
    // For most of our screen tests, we will build a MaterialApp and provide the MockGoRouter via Provider.
    routes: [
      GoRoute(path: '/', builder: (context, state) => Material(child: child) /* Ensure Material for Scaffold descendants */),
      // Add other dummy routes if the widget tries to navigate to them and you want to test that interaction.
      GoRoute(path: '/register', builder: (context, state) => const Material(child: Scaffold(body: Text("Mock Register")))),
      GoRoute(path: '/setup/weight-height', builder: (context, state) => const Material(child: Scaffold(body: Text("Mock WH")))),
      GoRoute(path: '/setup/fitness-goal', builder: (context, state) => const Material(child: Scaffold(body: Text("Mock FG")))),
      GoRoute(path: '/setup/experience-level', builder: (context, state) => const Material(child: Scaffold(body: Text("Mock EL")))),
      GoRoute(path: '/setup/training-prefs', builder: (context, state) => const Material(child: Scaffold(body: Text("Mock TP")))),
      GoRoute(path: '/setup/additional-info', builder: (context, state) => const Material(child: Scaffold(body: Text("Mock AI")))),
      GoRoute(path: '/main', builder: (context, state) => const Material(child: Scaffold(body: Text("Mock Main")))),
    ]
  );
  
  return MaterialApp.router(routerConfig: testRouter);

  // Fallback if RouterConfig is too complex for simple widget test:
  // return MaterialApp(home: child); // Then rely on Provider for GoRouter mock.
}
