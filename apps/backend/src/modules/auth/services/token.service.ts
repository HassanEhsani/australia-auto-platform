import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { randomBytes, createHash } from 'node:crypto';

export interface AccessTokenPayload {
  sub: string;
  sessionId: string;
  roles: string[];
}

export interface IssuedTokens {
  accessToken: string;
  refreshToken: string;
  refreshTokenHash: string;
  refreshTokenExpiresAt: Date;
}

@Injectable()
export class TokenService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async issueTokens(input: {
    userId: string;
    sessionId: string;
    roles: string[];
  }): Promise<IssuedTokens> {
    const accessSecret =
      this.configService.getOrThrow<string>('JWT_ACCESS_SECRET');

    const accessTtlSeconds =
      this.configService.get<number>('JWT_ACCESS_TTL_SECONDS') ?? 900;

    const issuer = this.configService.get<string>('JWT_ISSUER') ?? 'king-auto';

    const audience =
      this.configService.get<string>('JWT_AUDIENCE') ??
      'king-auto-customer-app';

    const refreshTokenTtlDays =
      this.configService.get<number>('REFRESH_TOKEN_TTL_DAYS') ?? 30;

    const accessToken = await this.jwtService.signAsync<AccessTokenPayload>(
      {
        sub: input.userId,
        sessionId: input.sessionId,
        roles: input.roles,
      },
      {
        secret: accessSecret,
        expiresIn: accessTtlSeconds,
        issuer,
        audience,
      },
    );

    const refreshToken = randomBytes(48).toString('base64url');
    const refreshTokenHash = this.hashRefreshToken(refreshToken);

    const refreshTokenExpiresAt = new Date(
      Date.now() + refreshTokenTtlDays * 24 * 60 * 60 * 1000,
    );

    return {
      accessToken,
      refreshToken,
      refreshTokenHash,
      refreshTokenExpiresAt,
    };
  }

  hashRefreshToken(refreshToken: string): string {
    return createHash('sha256').update(refreshToken).digest('hex');
  }
}
