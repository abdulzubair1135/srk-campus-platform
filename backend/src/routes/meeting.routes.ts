import { Router } from 'express';
import { MeetingController } from '../controllers/meeting.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { requireRoles } from '../middleware/rbac.middleware';
import { logAudit } from '../middleware/audit.middleware';
import { UserRole } from '../constants/enums';

const router = Router();

router.use(authenticateJwt);

router.get('/', MeetingController.getMeetings);

// Principal creates meeting / call request
router.post(
  '/request',
  requireRoles(UserRole.PRINCIPAL, UserRole.SUPER_ADMIN),
  logAudit('REQUEST_FACULTY_MEETING', 'MeetingRequest'),
  MeetingController.requestMeeting
);

// Faculty responds
router.patch(
  '/:id/respond',
  requireRoles(UserRole.FACULTY, UserRole.SUPER_ADMIN),
  logAudit('RESPOND_FACULTY_MEETING', 'MeetingRequest'),
  MeetingController.respondMeeting
);

export const meetingRoutes = router;
