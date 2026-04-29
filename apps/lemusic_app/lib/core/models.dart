enum SourceId { qqmusic, kugou, netease, fanqie }

enum PlaybackMode { directStream, embeddedWeb, external }

class SourceCapabilities {
  final SourceId source;
  final bool search;
  final PlaybackMode playbackMode;
  final bool available;
  final String? degradeReason;

  const SourceCapabilities({
    required this.source,
    required this.search,
    required this.playbackMode,
    required this.available,
    this.degradeReason,
  });

  factory SourceCapabilities.fromJson(Map<String, dynamic> json) {
    final source = SourceId.values.firstWhere((e) => e.name == json['source']);
    final playbackMode =
        PlaybackMode.values.firstWhere((e) => _playbackModeToWire(e) == json['playbackMode']);
    return SourceCapabilities(
      source: source,
      search: json['search'] == true,
      playbackMode: playbackMode,
      available: json['available'] == true,
      degradeReason: json['degradeReason'] as String?,
    );
  }
}

sealed class Playability {
  const Playability();
  factory Playability.fromJson(Map<String, dynamic> json) {
    switch (json['kind']) {
      case 'direct_stream':
        return DirectStreamPlayability(
          url: json['url'] as String,
          headers: (json['headers'] as Map?)?.cast<String, String>(),
        );
      case 'embedded_web':
        return EmbeddedWebPlayability(
          provider: json['provider'] as String,
          initPayload: (json['initPayload'] as Map).cast<String, dynamic>(),
        );
      case 'external':
      default:
        return ExternalOpenPlayability(
          url: json['url'] as String,
          deeplink: json['deeplink'] as String?,
        );
    }
  }
}

class DirectStreamPlayability extends Playability {
  final String url;
  final Map<String, String>? headers;
  const DirectStreamPlayability({required this.url, this.headers});
}

class EmbeddedWebPlayability extends Playability {
  final String provider; // e.g. "kugou"
  final Map<String, dynamic> initPayload;
  const EmbeddedWebPlayability({required this.provider, required this.initPayload});
}

class ExternalOpenPlayability extends Playability {
  final String url;
  final String? deeplink;
  const ExternalOpenPlayability({required this.url, this.deeplink});
}

class Track {
  final SourceId source;
  final String trackId;
  final String title;
  final List<String> artists;
  final Playability playability;

  const Track({
    required this.source,
    required this.trackId,
    required this.title,
    required this.artists,
    required this.playability,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final source = SourceId.values.firstWhere((e) => e.name == json['source']);
    return Track(
      source: source,
      trackId: json['trackId'] as String,
      title: json['title'] as String,
      artists: (json['artists'] as List? ?? []).cast<String>(),
      playability: Playability.fromJson((json['playability'] as Map).cast<String, dynamic>()),
    );
  }
}

String _playbackModeToWire(PlaybackMode m) {
  return switch (m) {
    PlaybackMode.directStream => 'direct_stream',
    PlaybackMode.embeddedWeb => 'embedded_web',
    PlaybackMode.external => 'external',
  };
}

