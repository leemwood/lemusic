export type SourceId = 'qqmusic' | 'kugou' | 'netease' | 'fanqie';

export type PlaybackMode = 'direct_stream' | 'embedded_web' | 'external';

export interface SourceCapabilities {
  source: SourceId;
  search: boolean;
  playbackMode: PlaybackMode;
  playlist: 'local_only' | 'remote_read' | 'remote_write';
  auth: 'none' | 'oauth' | 'sdk_managed';
  available: boolean;
  degradeReason?: string;
}

export type Playability =
  | {
      kind: 'direct_stream';
      url: string;
      headers?: Record<string, string>;
      expiresAt?: string;
    }
  | {
      kind: 'embedded_web';
      provider: 'kugou';
      initPayload: Record<string, unknown>;
    }
  | {
      kind: 'external';
      url: string;
      deeplink?: string;
    };

export interface Track {
  source: SourceId;
  trackId: string;
  title: string;
  artists: string[];
  album?: string;
  durationMs?: number;
  coverUrl?: string;
  playability: Playability;
}

export interface SearchResult {
  source: SourceId;
  items: Track[];
}

