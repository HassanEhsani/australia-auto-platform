export class VehiclePublishedEvent {
  constructor(
    public readonly vehicleId: string,
    public readonly stockNumber: string | null,
    public readonly make: string,
    public readonly model: string,
    public readonly year: number,
  ) {}
}
