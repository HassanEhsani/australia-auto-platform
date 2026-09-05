import { Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { VehiclePublishedEvent } from '../events/vehicle-published.event';

@Injectable()
export class VehiclePublishedListener {
  @OnEvent('vehicle.published')
  handle(event: VehiclePublishedEvent): void {
    console.log(
      `[vehicle.published] ${event.stockNumber} - ${event.make} ${event.model} (${event.year})`,
    );
  }
}
