import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FollowService {
  static const _key = "followed_suraus";

  /// Load followed surau IDs from local storage
  static Future<List<String>> loadFollowed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data;
  }

  /// Save followed surau IDs
  static Future<void> saveFollowed(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }

  /// Check if a surau is followed
  static Future<bool> isFollowedById(String surauId) async {
    final followed = await loadFollowed();
    return followed.contains(surauId);
  }

  /// Toggle follow/unfollow
  static Future<void> toggleFollowById(String surauId) async {
    final followed = await loadFollowed();
    if (followed.contains(surauId)) {
      followed.remove(surauId);
    } else {
      followed.add(surauId);
    }
    await saveFollowed(followed);
  }

  static decode(String r) {}

  static Future isFollowedByName(String surauName) async {}

  static Future<void> toggleFollowByName(String surauName, String currentImageUrl) async {}
}
