import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../sources/bff_client.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _client = BffClient(baseUri: Uri.parse('http://localhost:3000'));

  bool _loading = false;
  Object? _error;
  List<Track> _items = const [];

  Future<void> _doSearch() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _client.search(q: q);
      setState(() => _items = items);
    } catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '搜索歌曲/歌手',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _loading ? null : _doSearch,
                  child: const Text('搜索'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '搜索失败：$_error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = _items[i];
                  return ListTile(
                    title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${t.source.name} · ${t.artists.join(', ')}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // MVP：只展示“可播放方式”，真实播放由 PlayerFacade 负责
                      final mode = switch (t.playability) {
                        DirectStreamPlayability() => '直链播放（内置播放器）',
                        EmbeddedWebPlayability() => 'WebView 官方组件播放',
                        ExternalOpenPlayability() => '外部打开/跳转',
                      };
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('播放方式'),
                          content: Text(mode),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('知道了')),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

