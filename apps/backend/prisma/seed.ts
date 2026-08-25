import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL is required');
}

const adapter = new PrismaPg({
  connectionString,
});

const prisma = new PrismaClient({
  adapter,
});

const permissions = [
  ['vehicle.read', 'Read vehicles'],
  ['vehicle.create', 'Create vehicles'],
  ['vehicle.update', 'Update vehicles'],
  ['vehicle.publish', 'Publish vehicles'],

  ['offer.create', 'Create private offers'],
  ['offer.read', 'Read private offers'],
  ['offer.manage', 'Manage private offers'],

  ['favorite.manage', 'Manage favourite vehicles'],
  ['saved_list.manage', 'Manage saved vehicle list'],

  ['reservation.create', 'Create reservation requests'],
  ['reservation.manage', 'Manage reservations'],

  ['sale.create', 'Record completed sales'],

  ['analytics.read', 'Read sales analytics'],
  ['user.manage', 'Manage users'],
  ['branch.manage', 'Manage branches'],
] as const;

const roles = [
  ['CUSTOMER', 'Customer'],
  ['ADMIN', 'Administrator'],
  ['SUPER_ADMIN', 'Super Administrator'],
  ['SALES_MANAGER', 'Sales Manager'],
  ['INVENTORY_MANAGER', 'Inventory Manager'],
] as const;

async function seedPermissions(): Promise<Map<string, string>> {
  const result = new Map<string, string>();

  for (const [code, name] of permissions) {
    const permission = await prisma.permission.upsert({
      where: { code },
      update: {
        name,
      },
      create: {
        code,
        name,
      },
    });

    result.set(code, permission.id);
  }

  return result;
}

async function seedRoles(): Promise<Map<string, string>> {
  const result = new Map<string, string>();

  for (const [code, name] of roles) {
    const role = await prisma.role.upsert({
      where: { code },
      update: {
        name,
        isSystem: true,
      },
      create: {
        code,
        name,
        isSystem: true,
      },
    });

    result.set(code, role.id);
  }

  return result;
}

async function assignPermissions(
  roleIds: Map<string, string>,
  permissionIds: Map<string, string>,
): Promise<void> {
  const rolePermissions: Record<string, readonly string[]> = {
    CUSTOMER: [
      'vehicle.read',
      'offer.create',
      'favorite.manage',
      'saved_list.manage',
      'reservation.create',
    ],

    INVENTORY_MANAGER: [
      'vehicle.read',
      'vehicle.create',
      'vehicle.update',
      'vehicle.publish',
    ],

    SALES_MANAGER: [
      'vehicle.read',
      'offer.read',
      'offer.manage',
      'reservation.manage',
      'sale.create',
      'analytics.read',
    ],

    ADMIN: permissions.map(([code]) => code),

    SUPER_ADMIN: permissions.map(([code]) => code),
  };

  for (const [roleCode, permissionCodes] of Object.entries(rolePermissions)) {
    const roleId = roleIds.get(roleCode);

    if (!roleId) {
      throw new Error(`Missing role: ${roleCode}`);
    }

    for (const permissionCode of permissionCodes) {
      const permissionId = permissionIds.get(permissionCode);

      if (!permissionId) {
        throw new Error(`Missing permission: ${permissionCode}`);
      }

      await prisma.rolePermission.upsert({
        where: {
          roleId_permissionId: {
            roleId,
            permissionId,
          },
        },
        update: {},
        create: {
          roleId,
          permissionId,
        },
      });
    }
  }
}

async function seedInitialBranch(): Promise<void> {
  await prisma.branch.upsert({
    where: {
      code: 'ROCKLEA',
    },
    update: {
      name: 'King Auto - Rocklea',
      addressLine1: '50A Macbarry Pl',
      suburb: 'Rocklea',
      stateCode: 'QLD',
      postcode: '4106',
      countryCode: 'AU',
      timezone: 'Australia/Brisbane',
      phone: '07 3274 3428',
      email: 'info@kingauto.com.au',
      isActive: true,
    },
    create: {
      code: 'ROCKLEA',
      name: 'King Auto - Rocklea',
      addressLine1: '50A Macbarry Pl',
      suburb: 'Rocklea',
      stateCode: 'QLD',
      postcode: '4106',
      countryCode: 'AU',
      timezone: 'Australia/Brisbane',
      phone: '07 3274 3428',
      email: 'info@kingauto.com.au',
      isActive: true,
    },
  });
}

async function main(): Promise<void> {
  const permissionIds = await seedPermissions();
  const roleIds = await seedRoles();

  await assignPermissions(roleIds, permissionIds);
  await seedInitialBranch();

  console.log('King Auto seed completed successfully.');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error: unknown) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
