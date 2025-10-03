import 'package:shared_preferences/shared_preferences.dart';

class FollowService {
  static const String _followedKey = 'followed_list';

  /// Returns raw list entries in the format "name|image"
  static Future<List<String>> loadFollowed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_followedKey) ?? [];
  }

  /// Add a followed entry (name + image). If a follow for the same name already exists, it will not add another.
  static Future<void> addFollow(String name, String image) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> followed = prefs.getStringList(_followedKey) ?? [];
    // keep only one entry per name
    final exists = followed.any((e) => e.split("|").first == name);
    if (!exists) {
      followed.add(_encode(name, image));
      await prefs.setStringList(_followedKey, followed);
    }
  }

  /// Remove any followed entry with the given name.
  static Future<void> removeFollowByName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> followed = prefs.getStringList(_followedKey) ?? [];
    followed.removeWhere((e) => e.split("|").first == name);
    await prefs.setStringList(_followedKey, followed);
  }

  /// Toggle follow by name. If not followed -> add with image; if followed -> remove.
  static Future<void> toggleFollowByName(String name, String image) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> followed = prefs.getStringList(_followedKey) ?? [];
    final index = followed.indexWhere((e) => e.split("|").first == name);
    if (index >= 0) {
      // remove existing
      followed.removeAt(index);
    } else {
      followed.add(_encode(name, image));
    }
    await prefs.setStringList(_followedKey, followed);
  }

  /// Returns true if there is any followed entry for this name.
  static Future<bool> isFollowedByName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> followed = prefs.getStringList(_followedKey) ?? [];
    return followed.any((e) => e.split("|").first == name);
  }

  /// Helper encode/decode
  static String _encode(String name, String image) {
    // use '|' as separator; ensure we don't contain '|' in names (unlikely). If you expect '|', change separator.
    return "$name|$image";
  }

  static Map<String, String> decode(String raw) {
    final parts = raw.split("|");
    final name = parts.isNotEmpty ? parts[0] : "";
    final image = parts.length > 1 ? parts.sublist(1).join("|") : "";
    return {"name": name, "image": image};
  }
}
