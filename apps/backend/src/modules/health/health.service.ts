import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';

export interface HealthStatus {
  status: 'ok';
  timestamp: string;
}

export interface ReadinessStatus {
  status: 'ready' | 'not_ready';
  timestamp: string;
  dependencies: {
    database: 'up' | 'down';
  };
}

@Injectable()
export class HealthService {
  constructor(private readonly prisma: PrismaService) {}

  getHealth(): HealthStatus {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }

  async getReadiness(): Promise<ReadinessStatus> {
    const databaseHealthy = await this.prisma.isHealthy();

    return {
      status: databaseHealthy ? 'ready' : 'not_ready',
      timestamp: new Date().toISOString(),
      dependencies: {
        database: databaseHealthy ? 'up' : 'down',
      },
    };
  }
}
