import 'models.dart';

class TrackRef {
  final SourceId source;
  final String trackId;
  final String title;
  final List<String> artists;

  const TrackRef({
    required this.source,
    required this.trackId,
    required this.title,
    required this.artists,
  });

  Map<String, dynamic> toJson() => {
        'source': source.name,
        'trackId': trackId,
        'title': title,
        'artists': artists,
      };

  factory TrackRef.fromJson(Map<String, dynamic> json) => TrackRef(
        source: SourceId.values.firstWhere((e) => e.name == json['source']),
        trackId: json['trackId'] as String,
        title: json['title'] as String,
        artists: (json['artists'] as List? ?? []).cast<String>(),
      );

  factory TrackRef.fromTrack(Track t) => TrackRef(
        source: t.source,
        trackId: t.trackId,
        title: t.title,
        artists: t.artists,
      );
}

class Playlist {
  final String playlistId;
  final String name;
  final List<TrackRef> items;

  const Playlist({
    required this.playlistId,
    required this.name,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'playlistId': playlistId,
        'name': name,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        playlistId: json['playlistId'] as String,
        name: json['name'] as String,
        items: ((json['items'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(TrackRef.fromJson)
            .toList(),
      );
}

