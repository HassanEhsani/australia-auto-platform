import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { AuthService, LoginResult, RegisteredCustomer } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  login(@Body() dto: LoginDto): Promise<LoginResult> {
    return this.authService.login(dto);
  }

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  register(@Body() dto: RegisterDto): Promise<RegisteredCustomer> {
    return this.authService.register(dto);
  }
}
