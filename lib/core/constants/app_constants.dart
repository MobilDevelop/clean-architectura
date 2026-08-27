import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static bool get isStaging => dotenv.env['BRANCH']?.toLowerCase() == 'staging';
  static const int duration = 300;
}