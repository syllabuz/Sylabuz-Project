class ApiConfig {
  // Change this to your laptop IP for real device testing
  //static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator
  static const String baseUrl =
      'http://192.168.1.16:8000/api'; // Real Device (ganti XXX dengan IP lu)

  static const int timeout = 30000;

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String dashboard = '/user/dashboard';
  static const String programs = '/programs';
  static const String weeks = '/weeks';
  static const String tasks = '/tasks';
}
