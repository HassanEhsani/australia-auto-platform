import { Controller, Get } from '@nestjs/common';
import { HealthService } from './health.service';
import type { HealthStatus, ReadinessStatus } from './health.service';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  getHealth(): HealthStatus {
    return this.healthService.getHealth();
  }

  @Get('ready')
  getReadiness(): ReadinessStatus {
    return this.healthService.getReadiness();
  }
}
