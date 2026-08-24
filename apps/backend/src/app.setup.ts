import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export function configureApplication(
  app: INestApplication,
  configService: ConfigService,
): void {
  const apiPrefix = configService.getOrThrow<string>('API_PREFIX');

  app.setGlobalPrefix(apiPrefix);
}
