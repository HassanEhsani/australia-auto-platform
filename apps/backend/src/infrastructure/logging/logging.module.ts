import { randomUUID } from 'node:crypto';
import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerModule } from 'nestjs-pino';

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

function serializeRequest(value: unknown): Record<string, unknown> {
  if (!isRecord(value)) {
    return {};
  }

  return {
    id:
      typeof value.id === 'string' || typeof value.id === 'number'
        ? value.id
        : undefined,
    method: typeof value.method === 'string' ? value.method : undefined,
    url: typeof value.url === 'string' ? value.url : undefined,
  };
}

function serializeResponse(value: unknown): Record<string, unknown> {
  if (!isRecord(value)) {
    return {};
  }

  return {
    statusCode:
      typeof value.statusCode === 'number' ? value.statusCode : undefined,
  };
}

@Module({
  imports: [
    LoggerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        pinoHttp: {
          level:
            configService.get<string>('NODE_ENV') === 'production'
              ? 'info'
              : 'debug',

          genReqId: (req, res) => {
            const existingRequestId = req.headers['x-request-id'];

            if (typeof existingRequestId === 'string') {
              res.setHeader('x-request-id', existingRequestId);
              return existingRequestId;
            }

            const requestId = randomUUID();

            res.setHeader('x-request-id', requestId);

            return requestId;
          },

          redact: {
            paths: [
              'req.headers.authorization',
              'req.headers.cookie',
              'req.body.password',
              'req.body.password_confirmation',
              'req.body.refresh_token',
              'req.body.access_token',
              'res.headers["set-cookie"]',
            ],
            censor: '[REDACTED]',
          },

          serializers: {
            req: serializeRequest,
            res: serializeResponse,
          },
        },
      }),
    }),
  ],
})
export class LoggingModule {}
