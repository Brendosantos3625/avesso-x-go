import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:avesso_x_go/features/auth/presentation/screens/login_screen.dart';
import 'package:avesso_x_go/features/auth/presentation/screens/register_screen.dart';
import 'package:avesso_x_go/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:avesso_x_go/features/checkout/presentation/screens/checkout_success_screen.dart';
import 'package:avesso_x_go/features/events/presentation/screens/event_details_screen.dart';
import 'package:avesso_x_go/features/events/presentation/screens/events_screen.dart';
import 'package:avesso_x_go/features/home/presentation/screens/home_screen.dart';
import 'package:avesso_x_go/features/organizer/presentation/screens/organizer_dashboard_screen.dart';
import 'package:avesso_x_go/features/profile/presentation/screens/profile_screen.dart';
import 'package:avesso_x_go/features/profile/presentation/screens/settings_screen.dart';
import 'package:avesso_x_go/features/tickets/presentation/screens/tickets_screen.dart';

import 'main_scaffold.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static final GoRouter router = AppRouter._build();

  static GoRouter create() => AppRouter._build();

  static GoRouter _build() {
    return GoRouter(
      initialLocation: RouteNames.home,
      routes: [
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RouteNames.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainScaffold(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.home,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.events,
                  builder: (context, state) => const EventsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.tickets,
                  builder: (context, state) => const TicketsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profile,
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.eventDetails,
          builder: (context, state) => EventDetailsScreen(
            eventId: state.pathParameters[RouteNames.eventIdParam] ?? '',
          ),
        ),
        GoRoute(
          path: RouteNames.checkout,
          builder: (context, state) => CheckoutScreen(
            eventId: state.uri.queryParameters[RouteNames.checkoutEventQuery],
          ),
        ),
        GoRoute(
          path: RouteNames.checkoutSuccess,
          builder: (context, state) => const CheckoutSuccessScreen(),
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: RouteNames.organizer,
          builder: (context, state) => const OrganizerDashboardScreen(),
        ),
      ],
    );
  }
}