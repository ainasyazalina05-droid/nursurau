import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  static const _key = "followed_suraus";

  static Future<List<String>> loadFollowed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> saveFollowed(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }

  static Future<bool> isFollowedById(String surauId) async {
    final followed = await loadFollowed();
    return followed.contains(surauId);
  }

  /// Toggle follow/unfollow AND manage FCM token subscription
  static Future<void> toggleFollowById(String surauId) async {
    final followed = await loadFollowed();
    final token = await FirebaseMessaging.instance.getToken();

    final surauRef = FirebaseFirestore.instance.collection('suraus').doc(surauId);

    if (followed.contains(surauId)) {
      followed.remove(surauId);
      if (token != null) {
        await surauRef.update({
          'followersTokens': FieldValue.arrayRemove([token])
        });
      }
    } else {
      followed.add(surauId);
      if (token != null) {
        await surauRef.update({
          'followersTokens': FieldValue.arrayUnion([token])
        });
      }
    }

    await saveFollowed(followed);
  }

  /// Return followed surau IDs
  static Future<List<String>> getFollowedSurauIds() async {
    return await loadFollowed();
  }
}
