import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { configureApplication } from './../src/app.setup';
import { PrismaService } from './../src/infrastructure/database/prisma.service';

interface HealthResponse {
  status: 'ok' | 'ready';
  timestamp: string;
}

interface ReadinessResponse {
  status: 'ready';
  timestamp: string;
  dependencies: {
    database: 'up';
  };
}

function isHealthResponse(value: unknown): value is HealthResponse {
  if (typeof value !== 'object' || value === null) {
    return false;
  }

  const record = value as Record<string, unknown>;

  return (
    (record.status === 'ok' || record.status === 'ready') &&
    typeof record.timestamp === 'string'
  );
}

function isReadinessResponse(value: unknown): value is ReadinessResponse {
  if (typeof value !== 'object' || value === null) {
    return false;
  }

  const record = value as Record<string, unknown>;
  const dependencies = record.dependencies;

  if (typeof dependencies !== 'object' || dependencies === null) {
    return false;
  }

  const dependencyRecord = dependencies as Record<string, unknown>;

  return (
    record.status === 'ready' &&
    typeof record.timestamp === 'string' &&
    dependencyRecord.database === 'up'
  );
}

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue({
        isHealthy: jest.fn().mockResolvedValue(true),
      })
      .compile();

    app = moduleFixture.createNestApplication();

    configureApplication(app, app.get(ConfigService));

    await app.init();
  });

  it('/api/v1 (GET)', () => {
    return request(app.getHttpServer())
      .get('/api/v1')
      .expect(200)
      .expect('Hello World!');
  });

  it('/api/v1/health (GET)', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200);

    const body: unknown = response.body;

    expect(isHealthResponse(body)).toBe(true);

    if (!isHealthResponse(body)) {
      throw new Error('Invalid health response');
    }

    expect(body.status).toBe('ok');
  });

  it('/api/v1/health/ready (GET)', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/health/ready')
      .expect(200);

    const body: unknown = response.body;

    expect(isReadinessResponse(body)).toBe(true);

    if (!isReadinessResponse(body)) {
      throw new Error('Invalid readiness response');
    }

    expect(body.status).toBe('ready');
    expect(body.dependencies.database).toBe('up');
  });

  afterEach(async () => {
    await app.close();
  });
});
