import { Injectable } from '@nestjs/common';
import { MusicSource } from './source';
import { FanqieStubSource } from './stub/fanqie.source';
import { KugouStubSource } from './stub/kugou.source';
import { NeteaseStubSource } from './stub/netease.source';
import { QqMusicStubSource } from './stub/qqmusic.source';

@Injectable()
export class SourceRegistry {
  private readonly sources: MusicSource[] = [
    new QqMusicStubSource(),
    new KugouStubSource(),
    new NeteaseStubSource(),
    new FanqieStubSource(),
  ];

  list(): MusicSource[] {
    return this.sources;
  }

  get(id: string): MusicSource | undefined {
    return this.sources.find((s) => s.id === id);
  }
}

