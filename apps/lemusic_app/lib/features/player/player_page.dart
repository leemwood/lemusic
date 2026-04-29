import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../core/player_facade.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final PlayerFacade _facade;

  @override
  void initState() {
    super.initState();
    _facade = PlayerFacade();
    _facade.setQueue([
      const Track(
        source: SourceId.qqmusic,
        trackId: 'qq_stub_1',
        title: '示例曲目（外部打开）',
        artists: ['LeMusic'],
        playability: ExternalOpenPlayability(url: 'https://y.qq.com/'),
      )
    ]);
  }

  @override
  void dispose() {
    _facade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('播放器')),
        body: StreamBuilder<PlayerState>(
          stream: _facade.states,
          initialData: _facade.snapshot,
          builder: (context, snap) {
            final s = snap.data!;
            final track = s.current;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('状态：${s.status.name}'),
                  const SizedBox(height: 12),
                  Text(
                    track == null ? '未选择曲目' : track.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (track != null)
                    Text('${track.source.name} · ${track.artists.join(', ')}'),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 40,
                        onPressed: _facade.previous,
                        icon: const Icon(Icons.skip_previous),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonalIcon(
                        onPressed: _facade.playCurrent,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('播放'),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        iconSize: 40,
                        onPressed: _facade.next,
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '说明：MVP 当前只实现 PlayerFacade 与执行器骨架；\n'
                    'Direct/WebView/External 三种播放方式会在后续接入对应插件与 JS bridge。',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
