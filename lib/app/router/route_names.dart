abstract final class RouteNames {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String events = '/events';
  static const String eventDetails = '/event/:id';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout-success';
  static const String tickets = '/tickets';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String organizer = '/organizer';

  static const String eventIdParam = 'id';
  static const String checkoutEventQuery = 'eventId';

  static String eventDetailsWith(String eventId) => '/event/$eventId';

  static String checkoutWith(String eventId) => '/checkout?eventId=$eventId';
}