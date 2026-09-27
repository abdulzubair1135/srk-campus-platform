import { Router } from 'express';
import { MeetingController } from '../controllers/meeting.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { requireRoles } from '../middleware/rbac.middleware';
import { logAudit } from '../middleware/audit.middleware';
import { UserRole } from '../constants/enums';

const router = Router();

router.use(authenticateJwt);

router.get('/', MeetingController.getMeetings);

// Principal creates meeting / urgent call request
router.post(
  '/request',
  requireRoles(UserRole.PRINCIPAL, UserRole.SUPER_ADMIN),
  logAudit('REQUEST_FACULTY_MEETING', 'MeetingRequest'),
  MeetingController.requestMeeting
);

router.post(
  '/urgent-call',
  requireRoles(UserRole.PRINCIPAL, UserRole.SUPER_ADMIN),
  logAudit('DISPATCH_URGENT_CALL', 'MeetingRequest'),
  MeetingController.requestMeeting
);

// Faculty quick responds (1-tap BUSY or ARRIVING)
router.post(
  '/:id/quick-respond',
  requireRoles(UserRole.FACULTY, UserRole.SUPER_ADMIN),
  logAudit('QUICK_RESPOND_MEETING', 'MeetingRequest'),
  MeetingController.quickRespondMeeting
);

// Faculty standard responds
router.patch(
  '/:id/respond',
  requireRoles(UserRole.FACULTY, UserRole.SUPER_ADMIN),
  logAudit('RESPOND_FACULTY_MEETING', 'MeetingRequest'),
  MeetingController.respondMeeting
);

export const meetingRoutes = router;
