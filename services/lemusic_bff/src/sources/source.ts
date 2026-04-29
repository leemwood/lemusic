import { SearchResult, SourceCapabilities, SourceId, Track } from '../domain/types';

export interface MusicSource {
  id: SourceId;
  getCapabilities(): Promise<SourceCapabilities>;
  search(q: string): Promise<SearchResult>;
  getTrack(trackId: string): Promise<Track | null>;
}

