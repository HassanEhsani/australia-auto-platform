import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import type { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: true,
    credentials: true,
  },
})
export class RealtimeGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  handleConnection(client: Socket) {
    console.log(`[realtime] connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`[realtime] disconnected: ${client.id}`);
  }

  emitVehicleCreated(payload: unknown) {
    this.server.emit('vehicle.created', payload);
  }

  emitVehicleUpdated(payload: unknown) {
    this.server.emit('vehicle.updated', payload);
  }

  emitVehicleArchived(payload: unknown) {
    this.server.emit('vehicle.archived', payload);
  }

  emitVehiclePriceChanged(payload: unknown) {
    this.server.emit('vehicle.price_changed', payload);
  }

  emitReservationCreated(payload: unknown) {
    this.server.emit('reservation.created', payload);
  }

  emitNotInterestedChanged(payload: unknown) {
    this.server.emit('not_interested.changed', payload);
  }
}
