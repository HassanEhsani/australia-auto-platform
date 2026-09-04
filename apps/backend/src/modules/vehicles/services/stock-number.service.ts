import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';

@Injectable()
export class StockNumberService {
  constructor(private readonly prisma: PrismaService) {}

  async generate(): Promise<string> {
    const year = Number(
      new Intl.DateTimeFormat('en-AU', {
        timeZone: 'Australia/Brisbane',
        year: 'numeric',
      }).format(new Date()),
    );

    const result = await this.prisma.$queryRaw<Array<{ last_number: number }>>`
      INSERT INTO vehicle_sequences (id, year, last_number, created_at, updated_at)
      VALUES (
        gen_random_uuid(),
        ${year},
        1,
        NOW(),
        NOW()
      )
      ON CONFLICT (year)
      DO UPDATE SET
        last_number = vehicle_sequences.last_number + 1,
        updated_at = NOW()
      RETURNING last_number;
    `;

    const number = result[0]?.last_number;

    if (!number) {
      throw new Error('Failed to generate stock number');
    }

    return `KA-${year}-${String(number).padStart(5, '0')}`;
  }
}
