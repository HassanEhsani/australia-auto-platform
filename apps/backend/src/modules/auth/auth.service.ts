import { randomUUID } from 'node:crypto';

import {
  BadRequestException,
  ConflictException,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import {
  AuthProvider,
  Prisma,
  RoleScope,
  UserStatus,
} from '../../generated/prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { PasswordService } from './services/password.service';
import { TokenService } from './services/token.service';

export interface LoginResult {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    firstName: string | null;
    lastName: string | null;
    email: string;
    status: string;
    roles: string[];
  };
}

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
    private readonly tokenService: TokenService,
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

  async login(dto: LoginDto): Promise<LoginResult> {
    const email = dto.email.trim().toLowerCase();

    const identity = await this.prisma.authIdentity.findUnique({
      where: {
        provider_identifier: {
          provider: AuthProvider.PASSWORD,
          identifier: email,
        },
      },
      select: {
        passwordHash: true,
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            status: true,
            roleAssignments: {
              where: {
                revokedAt: null,
              },
              select: {
                role: {
                  select: {
                    code: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!identity?.passwordHash) {
      throw new UnauthorizedException('Invalid email or password.');
    }

    const passwordValid = await this.passwordService.verify(
      identity.passwordHash,
      dto.password,
    );

    if (!passwordValid) {
      throw new UnauthorizedException('Invalid email or password.');
    }

    if (
      identity.user.status === UserStatus.SUSPENDED ||
      identity.user.status === UserStatus.DISABLED
    ) {
      throw new UnauthorizedException('Account is not available.');
    }

    const roles = identity.user.roleAssignments.map(
      (assignment) => assignment.role.code,
    );

    const sessionId = randomUUID();

    const tokens = await this.tokenService.issueTokens({
      userId: identity.user.id,
      sessionId,
      roles,
    });

    const loginAt = new Date();

    await this.prisma.$transaction([
      this.prisma.session.create({
        data: {
          id: sessionId,
          userId: identity.user.id,
          refreshTokenHash: tokens.refreshTokenHash,
          expiresAt: tokens.refreshTokenExpiresAt,
          lastUsedAt: loginAt,
        },
      }),
      this.prisma.user.update({
        where: {
          id: identity.user.id,
        },
        data: {
          lastLoginAt: loginAt,
        },
      }),
    ]);

    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        id: identity.user.id,
        firstName: identity.user.firstName,
        lastName: identity.user.lastName,
        email,
        status: identity.user.status,
        roles,
      },
    };
  }

  async logout(refreshToken: string): Promise<void> {
    const refreshTokenHash = this.tokenService.hashRefreshToken(refreshToken);

    await this.prisma.session.updateMany({
      where: {
        refreshTokenHash,
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });
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
