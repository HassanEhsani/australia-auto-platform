import { Module } from '@nestjs/common';

import { VehiclesController } from './vehicles.controller';
import { VehiclesService } from './vehicles.service';
import { StockNumberService } from './services/stock-number.service';

@Module({
  controllers: [VehiclesController],
  providers: [VehiclesService, StockNumberService],
  exports: [VehiclesService],
})
export class VehiclesModule {}
