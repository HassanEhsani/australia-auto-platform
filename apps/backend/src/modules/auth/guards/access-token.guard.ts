import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import type { Request } from 'express';

import { PrismaService } from '../../../infrastructure/database/prisma.service';
import type { AccessTokenPayload } from '../services/token.service';

export interface AuthenticatedRequest extends Request {
  user?: AccessTokenPayload;
}

@Injectable()
export class AccessTokenGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();

    const authorization = request.headers.authorization;

    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing access token.');
    }

    const token = authorization.slice('Bearer '.length).trim();

    if (!token) {
      throw new UnauthorizedException('Missing access token.');
    }

    const secret = this.configService.getOrThrow<string>('JWT_ACCESS_SECRET');

    const issuer = this.configService.get<string>('JWT_ISSUER') ?? 'king-auto';

    const audience =
      this.configService.get<string>('JWT_AUDIENCE') ??
      'king-auto-customer-app';

    let payload: AccessTokenPayload;

    try {
      payload = await this.jwtService.verifyAsync<AccessTokenPayload>(token, {
        secret,
        issuer,
        audience,
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired access token.');
    }

    const session = await this.prisma.session.findUnique({
      where: {
        id: payload.sessionId,
      },
      select: {
        userId: true,
        expiresAt: true,
        revokedAt: true,
      },
    });

    if (
      !session ||
      session.userId != payload.sub ||
      session.revokedAt != null ||
      session.expiresAt <= new Date()
    ) {
      throw new UnauthorizedException('Session is not active.');
    }

    request.user = payload;

    return true;
  }
}
