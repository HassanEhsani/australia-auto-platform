import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { AuthService, RegisteredCustomer } from './auth.service';
import { RegisterDto } from './dto/register.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  register(@Body() dto: RegisterDto): Promise<RegisteredCustomer> {
    return this.authService.register(dto);
  }
}
