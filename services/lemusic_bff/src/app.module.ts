import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { V1Controller } from './http/v1.controller';
import { SourceRegistry } from './sources/source-registry';

@Module({
  imports: [],
  controllers: [AppController, V1Controller],
  providers: [AppService, SourceRegistry],
})
export class AppModule {}
