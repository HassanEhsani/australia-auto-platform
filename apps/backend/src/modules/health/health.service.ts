import { Injectable } from '@nestjs/common';

export interface HealthStatus {
  status: 'ok';
  timestamp: string;
}

export interface ReadinessStatus {
  status: 'ready';
  timestamp: string;
}

@Injectable()
export class HealthService {
  getHealth(): HealthStatus {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }

  getReadiness(): ReadinessStatus {
    return {
      status: 'ready',
      timestamp: new Date().toISOString(),
    };
  }
}
