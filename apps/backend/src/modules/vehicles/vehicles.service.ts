import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';
import { StockNumberService } from './services/stock-number.service';

@Injectable()
export class VehiclesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly stockNumberService: StockNumberService,
  ) {}

  async create(createVehicleDto: CreateVehicleDto) {
    const stockNumber = await this.stockNumberService.generate();

    return this.prisma.vehicle.create({
      data: {
        ...createVehicleDto,
        stockNumber,
      },
    });
  }

  findAll() {
    return this.prisma.vehicle.findMany({
      include: {
        media: true,
        attributes: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  findOne(id: string) {
    return this.prisma.vehicle.findUnique({
      where: {
        id,
      },
      include: {
        media: true,
        attributes: true,
      },
    });
  }

  update(id: string, updateVehicleDto: UpdateVehicleDto) {
    return this.prisma.vehicle.update({
      where: {
        id,
      },
      data: updateVehicleDto,
    });
  }

  async publish(id: string) {
    const vehicle = await this.prisma.vehicle.findUnique({
      where: {
        id,
      },
    });

    if (!vehicle) {
      throw new Error('Vehicle not found');
    }

    if (vehicle.status !== 'DRAFT') {
      throw new Error(
        `Vehicle cannot be published from status ${vehicle.status}`,
      );
    }

    return this.prisma.vehicle.update({
      where: {
        id,
      },
      data: {
        status: 'AVAILABLE',
      },
    });
  }

  remove(id: string) {
    return this.prisma.vehicle.delete({
      where: {
        id,
      },
    });
  }
}
