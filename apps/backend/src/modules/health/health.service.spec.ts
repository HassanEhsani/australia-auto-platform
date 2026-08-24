import { HealthService } from './health.service';

describe('HealthService', () => {
  let service: HealthService;

  beforeEach(() => {
    service = new HealthService();
  });

  it('should report the application as healthy', () => {
    const result = service.getHealth();

    expect(result.status).toBe('ok');
    expect(Number.isNaN(Date.parse(result.timestamp))).toBe(false);
  });

  it('should report the application as ready', () => {
    const result = service.getReadiness();

    expect(result.status).toBe('ready');
    expect(Number.isNaN(Date.parse(result.timestamp))).toBe(false);
  });
});
