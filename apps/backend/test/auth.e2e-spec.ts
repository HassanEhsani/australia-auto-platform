import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { configureApplication } from './../src/app.setup';
import { PrismaService } from './../src/infrastructure/database/prisma.service';

interface RegisterResponse {
  id: string;
  firstName: string | null;
  lastName: string | null;
  email: string;
  phone: string | null;
  status: string;
  createdAt: string;
}

function isRegisterResponse(value: unknown): value is RegisterResponse {
  if (typeof value !== 'object' || value === null) {
    return false;
  }

  const record = value as Record<string, unknown>;

  return (
    typeof record.id === 'string' &&
    (typeof record.firstName === 'string' || record.firstName === null) &&
    (typeof record.lastName === 'string' || record.lastName === null) &&
    typeof record.email === 'string' &&
    (typeof record.phone === 'string' || record.phone === null) &&
    typeof record.status === 'string' &&
    typeof record.createdAt === 'string'
  );
}

describe('Authentication registration (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;

  const testEmail = `e2e.register.${Date.now()}@example.com`;

  async function cleanupTestUser(email: string): Promise<void> {
    const identity = await prisma.authIdentity.findUnique({
      where: {
        provider_identifier: {
          provider: 'PASSWORD',
          identifier: email,
        },
      },
      select: {
        userId: true,
      },
    });

    if (!identity) {
      return;
    }

    await prisma.$transaction([
      prisma.userRoleAssignment.deleteMany({
        where: {
          userId: identity.userId,
        },
      }),
      prisma.session.deleteMany({
        where: {
          userId: identity.userId,
        },
      }),
      prisma.authIdentity.deleteMany({
        where: {
          userId: identity.userId,
        },
      }),
      prisma.user.delete({
        where: {
          id: identity.userId,
        },
      }),
    ]);
  }

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();

    configureApplication(app, app.get(ConfigService));

    await app.init();

    prisma = app.get(PrismaService);

    await cleanupTestUser(testEmail);
  });

  afterAll(async () => {
    await cleanupTestUser(testEmail);
    await app.close();
  });

  it('registers a customer using the real database', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        firstName: 'John',
        lastName: 'Smith',
        email: testEmail,
        phone: '0412 345 678',
        password: 'StrongPassword123!',
      })
      .expect(201);

    const body: unknown = response.body;

    expect(isRegisterResponse(body)).toBe(true);

    if (!isRegisterResponse(body)) {
      throw new Error('Invalid registration response');
    }

    expect(body.email).toBe(testEmail);
    expect(body.phone).toBe('+61412345678');
    expect(body.firstName).toBe('John');
    expect(body.lastName).toBe('Smith');

    const identity = await prisma.authIdentity.findUnique({
      where: {
        provider_identifier: {
          provider: 'PASSWORD',
          identifier: testEmail,
        },
      },
      include: {
        user: {
          include: {
            roleAssignments: {
              include: {
                role: true,
              },
            },
          },
        },
      },
    });

    expect(identity).not.toBeNull();

    if (!identity) {
      throw new Error('Expected authentication identity to exist');
    }

    expect(identity.passwordHash).toBeTruthy();
    expect(identity.passwordHash).not.toBe('StrongPassword123!');
    expect(identity.passwordHash?.startsWith('$argon2id$')).toBe(true);

    expect(identity.user.phone).toBe('+61412345678');

    expect(
      identity.user.roleAssignments.some(
        (assignment) => assignment.role.code === 'CUSTOMER',
      ),
    ).toBe(true);
  });

  it('rejects duplicate registration', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        firstName: 'John',
        lastName: 'Smith',
        email: testEmail,
        phone: '0412 345 678',
        password: 'StrongPassword123!',
      })
      .expect(409);
  });

  it('rejects an invalid Australian mobile number', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        firstName: 'Jane',
        lastName: 'Smith',
        email: `invalid-phone.${Date.now()}@example.com`,
        phone: '12345',
        password: 'StrongPassword123!',
      })
      .expect(400);
  });

  it('rejects privileged fields supplied by the customer', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        firstName: 'Jane',
        lastName: 'Smith',
        email: `forbidden-field.${Date.now()}@example.com`,
        phone: '0412 345 679',
        password: 'StrongPassword123!',
        role: 'SUPER_ADMIN',
      })
      .expect(400);
  });
});
