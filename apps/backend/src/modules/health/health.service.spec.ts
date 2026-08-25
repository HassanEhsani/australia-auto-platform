import type { PrismaService } from '../../infrastructure/database/prisma.service';
import { HealthService } from './health.service';

describe('HealthService', () => {
  const prisma = {
    isHealthy: jest.fn(),
  } as unknown as PrismaService;

  let service: HealthService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new HealthService(prisma);
  });

  it('should report the application as healthy', () => {
    const result = service.getHealth();

    expect(result.status).toBe('ok');
    expect(Number.isNaN(Date.parse(result.timestamp))).toBe(false);
  });

  it('should report ready when database is healthy', async () => {
    jest.spyOn(prisma, 'isHealthy').mockResolvedValue(true);

    const result = await service.getReadiness();

    expect(result.status).toBe('ready');
    expect(result.dependencies.database).toBe('up');
  });

  it('should report not ready when database is unhealthy', async () => {
    jest.spyOn(prisma, 'isHealthy').mockResolvedValue(false);

    const result = await service.getReadiness();

    expect(result.status).toBe('not_ready');
    expect(result.dependencies.database).toBe('down');
  });
});
