import { Router } from 'express';
import { AuditController } from '../controllers/audit.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { requireRoles } from '../middleware/rbac.middleware';
import { UserRole } from '../constants/enums';

const router = Router();

router.use(authenticateJwt);
router.use(requireRoles(UserRole.SUPER_ADMIN, UserRole.PRINCIPAL));

router.get('/logs', AuditController.getAuditLogs);

export const auditRoutes = router;
