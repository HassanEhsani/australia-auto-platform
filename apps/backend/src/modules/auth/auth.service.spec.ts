import {
  BadRequestException,
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';
import { AuthProvider, RoleScope } from '../../generated/prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { PasswordService } from './services/password.service';

describe('AuthService', () => {
  const authIdentityFindUniqueMock = jest.fn();
  const roleFindUniqueMock = jest.fn();
  const userCreateMock = jest.fn();
  const userUpdateMock = jest.fn();
  const userFindUniqueMock = jest.fn();
  const authIdentityCreateMock = jest.fn();
  const userRoleAssignmentCreateMock = jest.fn();
  const transactionMock = jest.fn();

  const passwordHashMock = jest.fn();
  const passwordVerifyMock = jest.fn();

  const prisma = {
    authIdentity: {
      findUnique: authIdentityFindUniqueMock,
    },
    role: {
      findUnique: roleFindUniqueMock,
    },
    user: {
      update: userUpdateMock,
      findUnique: userFindUniqueMock,
    },
    $transaction: transactionMock,
  } as unknown as PrismaService;

  const passwordService = {
    hash: passwordHashMock,
    verify: passwordVerifyMock,
  } as unknown as PasswordService;

  let service: AuthService;

  const dto: RegisterDto = {
    firstName: 'John',
    lastName: 'Smith',
    email: 'john@example.com',
    phone: '0412 345 678',
    password: 'StrongPassword123!',
  };

  beforeEach(() => {
    jest.clearAllMocks();

    service = new AuthService(prisma, passwordService);

    transactionMock.mockImplementation(
      async (
        callback: (tx: {
          user: { create: typeof userCreateMock };
          authIdentity: { create: typeof authIdentityCreateMock };
          userRoleAssignment: {
            create: typeof userRoleAssignmentCreateMock;
          };
        }) => Promise<unknown>,
      ) =>
        callback({
          user: {
            create: userCreateMock,
          },
          authIdentity: {
            create: authIdentityCreateMock,
          },
          userRoleAssignment: {
            create: userRoleAssignmentCreateMock,
          },
        }),
    );
  });

  it('registers a customer with normalized data and CUSTOMER role', async () => {
    authIdentityFindUniqueMock.mockResolvedValue(null);
    roleFindUniqueMock.mockResolvedValue({
      id: 'customer-role-id',
    });
    passwordHashMock.mockResolvedValue('argon2-hash');

    userCreateMock.mockResolvedValue({
      id: 'user-id',
      firstName: 'John',
      lastName: 'Smith',
      phone: '+61412345678',
      status: 'PENDING_VERIFICATION',
      createdAt: new Date('2026-08-25T10:00:00.000Z'),
    });

    authIdentityCreateMock.mockResolvedValue({
      id: 'identity-id',
    });

    userRoleAssignmentCreateMock.mockResolvedValue({
      id: 'assignment-id',
    });

    const result = await service.register(dto);

    expect(passwordHashMock).toHaveBeenCalledWith('StrongPassword123!');

    expect(userCreateMock).toHaveBeenCalledWith({
      data: {
        firstName: 'John',
        lastName: 'Smith',
        phone: '+61412345678',
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

    expect(authIdentityCreateMock).toHaveBeenCalledWith({
      data: {
        userId: 'user-id',
        provider: AuthProvider.PASSWORD,
        identifier: 'john@example.com',
        passwordHash: 'argon2-hash',
      },
    });

    expect(userRoleAssignmentCreateMock).toHaveBeenCalledWith({
      data: {
        userId: 'user-id',
        roleId: 'customer-role-id',
        scope: RoleScope.GLOBAL,
        branchId: null,
      },
    });

    expect(result).toEqual({
      id: 'user-id',
      firstName: 'John',
      lastName: 'Smith',
      phone: '+61412345678',
      status: 'PENDING_VERIFICATION',
      createdAt: new Date('2026-08-25T10:00:00.000Z'),
      email: 'john@example.com',
    });
  });

  it('rejects an already registered email', async () => {
    authIdentityFindUniqueMock.mockResolvedValue({
      id: 'existing-identity-id',
    });

    await expect(service.register(dto)).rejects.toBeInstanceOf(
      ConflictException,
    );

    expect(passwordHashMock).not.toHaveBeenCalled();
    expect(transactionMock).not.toHaveBeenCalled();
  });

  it('rejects an invalid Australian mobile number', async () => {
    const invalidDto: RegisterDto = {
      ...dto,
      phone: '12345',
    };

    await expect(service.register(invalidDto)).rejects.toBeInstanceOf(
      BadRequestException,
    );

    expect(authIdentityFindUniqueMock).not.toHaveBeenCalled();
    expect(transactionMock).not.toHaveBeenCalled();
  });

  it('accepts an Australian mobile already in E.164 format', async () => {
    authIdentityFindUniqueMock.mockResolvedValue(null);
    roleFindUniqueMock.mockResolvedValue({
      id: 'customer-role-id',
    });
    passwordHashMock.mockResolvedValue('argon2-hash');

    userCreateMock.mockResolvedValue({
      id: 'user-id',
      firstName: 'John',
      lastName: 'Smith',
      phone: '+61412345678',
      status: 'PENDING_VERIFICATION',
      createdAt: new Date('2026-08-25T10:00:00.000Z'),
    });

    authIdentityCreateMock.mockResolvedValue({
      id: 'identity-id',
    });

    userRoleAssignmentCreateMock.mockResolvedValue({
      id: 'assignment-id',
    });

    await service.register({
      ...dto,
      phone: '+61412345678',
    });

    expect(userCreateMock).toHaveBeenCalledWith({
      data: {
        firstName: 'John',
        lastName: 'Smith',
        phone: '+61412345678',
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
  });

  it('updates the current user profile and preserves the current session', async () => {
    userUpdateMock.mockResolvedValue({
      id: 'user-id',
    });

    userFindUniqueMock.mockResolvedValue({
      id: 'user-id',
      firstName: 'Jane',
      lastName: 'Customer',
      phone: '+61412345678',
      status: 'ACTIVE',
      authIdentities: [
        {
          identifier: 'jane@example.com',
        },
      ],
      roleAssignments: [
        {
          role: {
            code: 'CUSTOMER',
          },
        },
      ],
    });

    const result = await service.updateCurrentUser(
      'user-id',
      'current-session-id',
      {
        firstName: '  Jane  ',
        lastName: '  Customer  ',
        phone: '0412 345 678',
      },
    );

    expect(userUpdateMock).toHaveBeenCalledWith({
      where: {
        id: 'user-id',
      },
      data: {
        firstName: 'Jane',
        lastName: 'Customer',
        phone: '+61412345678',
      },
    });

    expect(userFindUniqueMock).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          id: 'user-id',
        },
      }),
    );

    expect(result).toEqual({
      id: 'user-id',
      firstName: 'Jane',
      lastName: 'Customer',
      email: 'jane@example.com',
      phone: '+61412345678',
      status: 'ACTIVE',
      roles: ['CUSTOMER'],
      sessionId: 'current-session-id',
    });
  });

  it('rejects an invalid mobile number when updating the profile', async () => {
    await expect(
      service.updateCurrentUser('user-id', 'current-session-id', {
        phone: '12345',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);

    expect(userUpdateMock).not.toHaveBeenCalled();
    expect(userFindUniqueMock).not.toHaveBeenCalled();
  });

  it('fails safely when the CUSTOMER role is not configured', async () => {
    authIdentityFindUniqueMock.mockResolvedValue(null);
    roleFindUniqueMock.mockResolvedValue(null);

    await expect(service.register(dto)).rejects.toBeInstanceOf(
      InternalServerErrorException,
    );

    expect(passwordHashMock).not.toHaveBeenCalled();
    expect(transactionMock).not.toHaveBeenCalled();
  });
});
