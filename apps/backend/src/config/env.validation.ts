import * as Joi from 'joi';

export const environmentValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'staging', 'production')
    .default('development'),

  PORT: Joi.number().port().default(3000),

  API_PREFIX: Joi.string().trim().default('api/v1'),

  DATABASE_URL: Joi.string()
    .uri({ scheme: ['postgresql', 'postgres'] })
    .required(),

  JWT_ACCESS_SECRET: Joi.string().min(32).required(),

  JWT_ACCESS_TTL_SECONDS: Joi.number().integer().min(60).default(900),

  REFRESH_TOKEN_TTL_DAYS: Joi.number().integer().min(1).default(30),

  JWT_ISSUER: Joi.string().trim().default('king-auto'),

  JWT_AUDIENCE: Joi.string().trim().default('king-auto-customer-app'),
});
