import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  AuthService,
  CurrentUserProfile,
  LoginResult,
  RefreshTokenResult,
  RegisteredCustomer,
} from './auth.service';
import {
  AccessTokenGuard,
  type AuthenticatedRequest,
} from './guards/access-token.guard';
import { LoginDto } from './dto/login.dto';
import { LogoutDto } from './dto/logout.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('me')
  @UseGuards(AccessTokenGuard)
  me(@Req() request: AuthenticatedRequest): Promise<CurrentUserProfile> {
    return this.authService.getCurrentUser(
      request.user!.sub,
      request.user!.sessionId,
    );
  }

  @Patch('me')
  @UseGuards(AccessTokenGuard)
  updateMe(
    @Req() request: AuthenticatedRequest,
    @Body() dto: UpdateProfileDto,
  ): Promise<CurrentUserProfile> {
    return this.authService.updateCurrentUser(
      request.user!.sub,
      request.user!.sessionId,
      dto,
    );
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  login(@Body() dto: LoginDto): Promise<LoginResult> {
    return this.authService.login(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refresh(@Body() dto: RefreshTokenDto): Promise<RefreshTokenResult> {
    return this.authService.refresh(dto.refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  async logout(@Body() dto: LogoutDto): Promise<void> {
    await this.authService.logout(dto.refreshToken);
  }

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  register(@Body() dto: RegisterDto): Promise<RegisteredCustomer> {
    return this.authService.register(dto);
  }
}
