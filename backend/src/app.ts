import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { envConfig } from './config/env.config';
import { apiRoutes } from './routes';
import { errorHandler } from './middleware/error.middleware';
import { standardRateLimiter } from './middleware/rateLimiter.middleware';

export const createApp = (): Express => {
  const app = express();

  // Security headers
  app.use(helmet());

  // CORS configuration
  app.use(
    cors({
      origin: (origin, callback) => {
        if (!origin || envConfig.clientUrls.includes(origin) || envConfig.nodeEnv === 'development') {
          callback(null, true);
        } else {
          callback(new Error('CORS blocked by origin policy'));
        }
      },
      credentials: true
    })
  );

  // Request logging
  if (envConfig.nodeEnv !== 'test') {
    app.use(morgan('combined'));
  }

  // Body parser
  app.use(express.json({ limit: '5mb' }));
  app.use(express.urlencoded({ extended: true, limit: '5mb' }));

  // Global Rate Limiting
  app.use(standardRateLimiter);

  // API Routes
  app.use(envConfig.apiPrefix, apiRoutes);

  // Global Error Handler
  app.use(errorHandler);

  return app;
};
