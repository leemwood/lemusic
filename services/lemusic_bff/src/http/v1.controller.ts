import { Controller, Get, Param, Query } from '@nestjs/common';
import { SourceRegistry } from '../sources/source-registry';
import type { SearchResult, SourceCapabilities, SourceId, Track } from '../domain/types';

@Controller('/v1')
export class V1Controller {
  constructor(private readonly registry: SourceRegistry) {}

  @Get('/sources')
  async listSources(): Promise<SourceCapabilities[]> {
    const caps = await Promise.all(this.registry.list().map((s) => s.getCapabilities()));
    return caps;
  }

  @Get('/search')
  async search(
    @Query('q') q: string,
    @Query('sources') sources?: string,
  ): Promise<{ q: string; results: SearchResult[] }> {
    const wanted = (sources ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean) as SourceId[];

    const list = this.registry
      .list()
      .filter((s) => (wanted.length ? wanted.includes(s.id) : true));

    const results = await Promise.all(list.map((s) => s.search(q ?? '')));
    return { q: q ?? '', results };
  }

  @Get('/tracks/:source/:trackId')
  async getTrack(
    @Param('source') source: SourceId,
    @Param('trackId') trackId: string,
  ): Promise<Track> {
    const src = this.registry.get(source);
    if (!src) {
      // Nest 默认会返回 500；MVP 先简化，后续统一错误码中间件再做规范化
      throw new Error(`unknown source: ${source}`);
    }
    const track = await src.getTrack(trackId);
    if (!track) throw new Error('track not found');
    return track;
  }
}
