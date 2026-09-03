import { Body, Controller, Post } from '@nestjs/common';
import { RealtimeGateway } from './realtime.gateway';

@Controller('realtime')
export class RealtimeController {
  constructor(private readonly realtimeGateway: RealtimeGateway) {}

  @Post('test-vehicle-updated')
  emitVehicleUpdated(@Body() body: Record<string, unknown>) {
    this.realtimeGateway.emitVehicleUpdated(body);

    return {
      emitted: true,
      event: 'vehicle.updated',
      payload: body,
    };
  }
}
