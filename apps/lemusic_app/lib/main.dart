import 'package:flutter/material.dart';

import 'features/player/player_page.dart';
import 'features/playlist/playlist_page.dart';
import 'features/search/search_page.dart';

void main() {
  runApp(const LeMusicApp());
}

class LeMusicApp extends StatelessWidget {
  const LeMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeMusic',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      SearchPage(),
      PlayerPage(),
      PlaylistPage(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
          NavigationDestination(icon: Icon(Icons.play_circle), label: '播放'),
          NavigationDestination(icon: Icon(Icons.queue_music), label: '歌单'),
        ],
      ),
    );
  }
}
