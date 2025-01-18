import 'package:shared_preferences/shared_preferences.dart';

class TimezoneService {
  static const String _timezoneKey = 'timezone_offset';
  static const String _countryKey = 'timezone_country';

  static Future<void> setTimezoneOffset(int offset, String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timezoneKey, offset);
    await prefs.setString(_countryKey, country);
  }

  static Future<String> getCurrentCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryKey) ?? 'South Korea'; // 기본값
  }

  static Future<int> getTimezoneOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timezoneKey) ?? 9; // 기본값 UTC+9 (한국)
  }

  static DateTime getLocalTime() {
    return DateTime.now().toLocal();
  }

  static Future<DateTime> getAdjustedTime() async {
    final offset = await getTimezoneOffset();
    final now = DateTime.now().toUtc();
    return now.add(Duration(hours: offset));
  }
}
