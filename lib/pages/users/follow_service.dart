import 'package:shared_preferences/shared_preferences.dart';

class FollowService {
  static const String _followedKey = 'followed_list';

  static Future<List<String>> loadFollowed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_followedKey) ?? [];
  }

  static Future<void> toggleFollow(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> followed = prefs.getStringList(_followedKey) ?? [];

    if (followed.contains(id)) {
      followed.remove(id);
    } else {
      followed.add(id);
    }

    await prefs.setStringList(_followedKey, followed);
  }

  static Future<bool> isFollowed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> followed = prefs.getStringList(_followedKey) ?? [];
    return followed.contains(id);
  }
}
