import { MusicSource } from '../source';
import { SearchResult, SourceCapabilities, Track } from '../../domain/types';

/**
 * 番茄畅听：未发现可供第三方统一搜索/播放/歌单接入的公开官方 API/SDK 文档，
 * MVP 仅 external 跳转。
 */
export class FanqieStubSource implements MusicSource {
  public readonly id = 'fanqie' as const;

  async getCapabilities(): Promise<SourceCapabilities> {
    return {
      source: this.id,
      search: false,
      playbackMode: 'external',
      playlist: 'local_only',
      auth: 'none',
      available: false,
      degradeReason: '未发现可用的官方开放 API/SDK（MVP 仅外部跳转）。',
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
      title: `番茄畅听（外部打开）${trackId}`,
      artists: [],
      playability: {
        kind: 'external',
        url: 'https://www.fanqie.com/',
      },
    };
  }
}

