import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { authRateLimiter } from '../middleware/rateLimiter.middleware';
import { logAudit } from '../middleware/audit.middleware';

const router = Router();

router.post('/login', authRateLimiter, logAudit('USER_LOGIN', 'User'), AuthController.login);
router.post('/refresh', authRateLimiter, AuthController.refreshToken);
router.post('/logout', authenticateJwt, logAudit('USER_LOGOUT', 'User'), AuthController.logout);
router.get('/me', authenticateJwt, AuthController.getMe);

export const authRoutes = router;
