import 'package:flutter/material.dart';

import '../../core/playlist.dart';
import '../../core/playlist_store.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final _store = PlaylistStore();
  bool _loading = true;
  List<Playlist> _playlists = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final data = await _store.load();
    setState(() {
      _playlists = data;
      _loading = false;
    });
  }

  Future<void> _createPlaylist() async {
    final name = await _promptName(title: '新建歌单', hint: '歌单名称');
    if (name == null || name.trim().isEmpty) return;
    final p = Playlist(
      playlistId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      items: const [],
    );
    final next = [..._playlists, p];
    await _store.save(next);
    setState(() => _playlists = next);
  }

  Future<void> _renamePlaylist(Playlist p) async {
    final name = await _promptName(title: '重命名歌单', hint: '歌单名称', initial: p.name);
    if (name == null || name.trim().isEmpty) return;
    final next = _playlists
        .map((x) => x.playlistId == p.playlistId
            ? Playlist(playlistId: x.playlistId, name: name.trim(), items: x.items)
            : x)
        .toList();
    await _store.save(next);
    setState(() => _playlists = next);
  }

  Future<void> _deletePlaylist(Playlist p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除歌单？'),
        content: Text('将删除「${p.name}」，此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    final next = _playlists.where((x) => x.playlistId != p.playlistId).toList();
    await _store.save(next);
    setState(() => _playlists = next);
  }

  Future<String?> _promptName({
    required String title,
    required String hint,
    String? initial,
  }) async {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('歌单（本地）'),
          actions: [
            IconButton(onPressed: _createPlaylist, icon: const Icon(Icons.add)),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _playlists.isEmpty
                ? const Center(child: Text('暂无歌单，点击右上角 + 创建'))
                : ListView.separated(
                    itemCount: _playlists.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = _playlists[i];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text('${p.items.length} 首'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'rename') _renamePlaylist(p);
                            if (v == 'delete') _deletePlaylist(p);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'rename', child: Text('重命名')),
                            PopupMenuItem(value: 'delete', child: Text('删除')),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
