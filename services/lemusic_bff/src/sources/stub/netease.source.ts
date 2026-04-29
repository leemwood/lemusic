import { MusicSource } from '../source';
import { SearchResult, SourceCapabilities, Track } from '../../domain/types';

/**
 * 网易云：公开页能确认“开放平台入口存在”，但MVP暂不假设可立即获得可用 API/SDK。
 * 因此默认 external 降级。
 */
export class NeteaseStubSource implements MusicSource {
  public readonly id = 'netease' as const;

  async getCapabilities(): Promise<SourceCapabilities> {
    return {
      source: this.id,
      search: false,
      playbackMode: 'external',
      playlist: 'local_only',
      auth: 'oauth',
      available: false,
      degradeReason: '需获得网易云开放平台可用的官方 API/SDK 与播放链路授权后才能启用。',
    };
  }

  async search(): Promise<SearchResult> {
    return { source: this.id, items: [] };
  }

  async getTrack(trackId: string): Promise<Track | null> {
    if (!trackId) return null;
    return {
      source: this.id,
      trackId,
      title: `网易云（外部打开）${trackId}`,
      artists: [],
      playability: {
        kind: 'external',
        url: 'https://music.163.com/',
      },
    };
  }
}

