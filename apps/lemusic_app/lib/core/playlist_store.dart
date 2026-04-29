import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'playlist.dart';

class PlaylistStore {
  static const _key = 'lemusic.playlists.v1';

  Future<List<Playlist>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final arr = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return arr.map(Playlist.fromJson).toList();
  }

  Future<void> save(List<Playlist> playlists) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(playlists.map((p) => p.toJson()).toList());
    await sp.setString(_key, raw);
  }
}

