import { Request, Response, NextFunction } from 'express';
import { MeetingService } from '../services/meeting.service';
import { Faculty } from '../models/Faculty';
import { ResponseUtil } from '../utils/response';
import { UserRole } from '../constants/enums';

export class MeetingController {
  static async requestMeeting(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { toFacultyId, type, reason, scheduledTime } = req.body;
      if (!toFacultyId || !reason) {
        ResponseUtil.error(res, 'toFacultyId and reason are required', 400);
        return;
      }

      const meeting = await MeetingService.createMeetingRequest({
        fromUserId: req.user?._id as string,
        toFacultyId,
        type: type || 'MEETING',
        reason,
        scheduledTime: scheduledTime ? new Date(scheduledTime) : undefined
      });

      ResponseUtil.success(res, meeting, 'Meeting request sent successfully', 201);
    } catch (error: any) {
      ResponseUtil.error(res, error.message || 'Failed to request meeting', 400);
    }
  }

  static async respondMeeting(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { status, responseNote } = req.body;
      if (!status) {
        ResponseUtil.error(res, 'status is required', 400);
        return;
      }

      const meeting = await MeetingService.respondToMeeting({
        meetingId: req.params.id,
        facultyUserId: req.user?._id as string,
        status,
        responseNote
      });

      ResponseUtil.success(res, meeting, 'Response recorded successfully');
    } catch (error: any) {
      ResponseUtil.error(res, error.message || 'Failed to respond to meeting', 400);
    }
  }

  static async getMeetings(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (req.user?.role === UserRole.FACULTY) {
        const faculty = await Faculty.findOne({ userId: req.user._id });
        if (!faculty) {
          ResponseUtil.error(res, 'Faculty profile not found', 404);
          return;
        }
        const meetings = await MeetingService.getFacultyMeetings(faculty._id.toString());
        ResponseUtil.success(res, meetings, 'Faculty meetings retrieved');
        return;
      }

      // Principal / Super Admin
      const allMeetings = await MeetingService.getAllMeetings();
      ResponseUtil.success(res, allMeetings, 'All campus meetings retrieved');
    } catch (error: any) {
      next(error);
    }
  }
}
