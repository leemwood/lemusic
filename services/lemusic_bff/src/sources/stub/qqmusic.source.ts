import { MusicSource } from '../source';
import { SearchResult, SourceCapabilities, Track } from '../../domain/types';

/**
 * QQ音乐：MVP 先提供可跑通的 stub。
 * 实际接入需按官方 OpenAPI 做签名/鉴权/频控/缓存，并可能涉及“听歌流水上报”等合规要求。
 */
export class QqMusicStubSource implements MusicSource {
  public readonly id = 'qqmusic' as const;

  async getCapabilities(): Promise<SourceCapabilities> {
    return {
      source: this.id,
      search: true,
      playbackMode: 'external',
      playlist: 'local_only',
      auth: 'oauth',
      available: false,
      degradeReason: 'MVP 仅提供接口骨架；需配置 QQ 音乐官方 OpenAPI 资质后启用。',
    };
  }

  async search(q: string): Promise<SearchResult> {
    return {
      source: this.id,
      items: q
        ? [
            {
              source: this.id,
              trackId: 'qq_stub_1',
              title: `QQ音乐（示例）- ${q}`,
              artists: ['QQ Artist'],
              playability: {
                kind: 'external',
                url: 'https://y.qq.com/',
              },
            },
          ]
        : [],
    };
  }

  async getTrack(trackId: string): Promise<Track | null> {
    if (!trackId) return null;
    return {
      source: this.id,
      trackId,
      title: `QQ音乐（示例曲目）${trackId}`,
      artists: ['QQ Artist'],
      playability: {
        kind: 'external',
        url: 'https://y.qq.com/',
      },
    };
  }
}

