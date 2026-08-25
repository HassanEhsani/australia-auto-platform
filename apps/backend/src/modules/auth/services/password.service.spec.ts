import * as argon2 from 'argon2';
import { PasswordService } from './password.service';

describe('PasswordService', () => {
  let service: PasswordService;

  beforeEach(() => {
    service = new PasswordService();
  });

  it('should hash a password using Argon2id', async () => {
    const password = 'StrongPassword123!';
    const hash = await service.hash(password);

    expect(hash).not.toBe(password);
    expect(hash.startsWith('$argon2id$')).toBe(true);
  });

  it('should verify a valid password', async () => {
    const password = 'StrongPassword123!';
    const hash = await service.hash(password);

    await expect(service.verify(hash, password)).resolves.toBe(true);
  });

  it('should reject an invalid password', async () => {
    const hash = await service.hash('CorrectPassword123!');

    await expect(service.verify(hash, 'WrongPassword123!')).resolves.toBe(
      false,
    );
  });

  it('should safely reject an invalid hash', async () => {
    await expect(service.verify('invalid-hash', 'Password123!')).resolves.toBe(
      false,
    );
  });

  it('should produce different hashes for the same password', async () => {
    const password = 'StrongPassword123!';

    const firstHash = await service.hash(password);
    const secondHash = await service.hash(password);

    expect(firstHash).not.toBe(secondHash);

    await expect(argon2.verify(firstHash, password)).resolves.toBe(true);
    await expect(argon2.verify(secondHash, password)).resolves.toBe(true);
  });
});
