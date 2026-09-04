import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CreateVehicleDto {
  @IsString()
  make: string;

  @IsString()
  model: string;

  @IsInt()
  @Min(1900)
  @Max(2100)
  year: number;

  @IsOptional()
  @IsString()
  stockNumber?: string;

  @IsOptional()
  @IsString()
  vin?: string;

  @IsOptional()
  @IsString()
  lotNumber?: string;

  @IsOptional()
  @IsString()
  auctionName?: string;

  @IsOptional()
  @IsString()
  vehicleType?: string;

  @IsOptional()
  @IsString()
  condition?: string;

  @IsOptional()
  @IsString()
  primaryDamage?: string;

  @IsOptional()
  @IsString()
  secondaryDamage?: string;

  @IsOptional()
  @IsString()
  color?: string;

  @IsOptional()
  @IsString()
  transmission?: string;

  @IsOptional()
  @IsString()
  fuel?: string;

  @IsOptional()
  @IsInt()
  odometer?: number;

  @IsOptional()
  @IsInt()
  cylinders?: number;

  @IsOptional()
  @IsString()
  engineType?: string;

  @IsOptional()
  @IsString()
  drivetrain?: string;

  @IsOptional()
  @IsNumber()
  price?: number;
}
