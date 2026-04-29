import { MusicSource } from '../source';
import { SearchResult, SourceCapabilities, Track } from '../../domain/types';

/**
 * 酷狗：MVP 先按“mini 酷狗（H5 组件）”的 embedded_web 模式建模。
 * 实际接入需要服务端按官方网关获取 ticket（有效期 2 小时并缓存）。
 */
export class KugouStubSource implements MusicSource {
  public readonly id = 'kugou' as const;

  async getCapabilities(): Promise<SourceCapabilities> {
    return {
      source: this.id,
      search: true,
      playbackMode: 'embedded_web',
      playlist: 'local_only',
      auth: 'sdk_managed',
      available: false,
      degradeReason: 'MVP 仅提供接口骨架；需配置酷狗 openappid/appkey 并实现 ticket 获取后启用。',
    };
  }

  async search(q: string): Promise<SearchResult> {
    return {
      source: this.id,
      items: q
        ? [
            {
              source: this.id,
              trackId: 'kg_stub_hash_1',
              title: `酷狗（示例）- ${q}`,
              artists: ['Kugou Artist'],
              playability: {
                kind: 'embedded_web',
                provider: 'kugou',
                initPayload: {
                  // 真实接入时应包含 hash / album_audio_id 等字段，供 H5 组件定位曲目
                  hash: 'kg_stub_hash_1',
                },
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
      title: `酷狗（示例曲目）${trackId}`,
      artists: ['Kugou Artist'],
      playability: {
        kind: 'embedded_web',
        provider: 'kugou',
        initPayload: { hash: trackId },
      },
    };
  }
}

