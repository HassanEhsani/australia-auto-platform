import {
  BadRequestException,
  ConflictException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { AuthProvider, Prisma, RoleScope } from '../../generated/prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { PasswordService } from './services/password.service';

export interface RegisteredCustomer {
  id: string;
  firstName: string | null;
  lastName: string | null;
  email: string;
  phone: string | null;
  status: string;
  createdAt: Date;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwordService: PasswordService,
  ) {}

  async register(dto: RegisterDto): Promise<RegisteredCustomer> {
    const email = dto.email.trim().toLowerCase();
    const phone = this.normalizeAustralianMobile(dto.phone);

    const existingIdentity = await this.prisma.authIdentity.findUnique({
      where: {
        provider_identifier: {
          provider: AuthProvider.PASSWORD,
          identifier: email,
        },
      },
      select: {
        id: true,
      },
    });

    if (existingIdentity) {
      throw new ConflictException('An account with this email already exists.');
    }

    const customerRole = await this.prisma.role.findUnique({
      where: {
        code: 'CUSTOMER',
      },
      select: {
        id: true,
      },
    });

    if (!customerRole) {
      throw new InternalServerErrorException(
        'Customer role is not configured.',
      );
    }

    const passwordHash = await this.passwordService.hash(dto.password);

    try {
      return await this.prisma.$transaction(async (tx) => {
        const user = await tx.user.create({
          data: {
            firstName: dto.firstName.trim(),
            lastName: dto.lastName.trim(),
            phone,
          },
          select: {
            id: true,
            firstName: true,
            lastName: true,
            phone: true,
            status: true,
            createdAt: true,
          },
        });

        await tx.authIdentity.create({
          data: {
            userId: user.id,
            provider: AuthProvider.PASSWORD,
            identifier: email,
            passwordHash,
          },
        });

        await tx.userRoleAssignment.create({
          data: {
            userId: user.id,
            roleId: customerRole.id,
            scope: RoleScope.GLOBAL,
            branchId: null,
          },
        });

        return {
          ...user,
          email,
        };
      });
    } catch (error: unknown) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException(
          'An account with this email already exists.',
        );
      }

      throw error;
    }
  }

  private normalizeAustralianMobile(phone: string): string {
    const normalized = phone.replace(/[\s()-]/g, '');

    if (/^\+614\d{8}$/.test(normalized)) {
      return normalized;
    }

    if (/^04\d{8}$/.test(normalized)) {
      return `+61${normalized.slice(1)}`;
    }

    if (/^614\d{8}$/.test(normalized)) {
      return `+${normalized}`;
    }

    throw new BadRequestException(
      'Phone must be a valid Australian mobile number.',
    );
  }
}
