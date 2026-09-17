import { MeetingRequest, IMeetingRequest } from '../models/MeetingRequest';
import { Faculty } from '../models/Faculty';
import { Notification } from '../models/Notification';
import { SocketManager } from '../sockets/socket.manager';
import { MeetingRequestStatus, SocketEvent, UserRole } from '../constants/enums';

export class MeetingService {
  /**
   * Principal creates a meeting or call request for a faculty member
   */
  static async createMeetingRequest(data: {
    fromUserId: string;
    toFacultyId: string;
    type: 'MEETING' | 'CALL';
    reason: string;
    scheduledTime?: Date;
  }): Promise<IMeetingRequest> {
    const faculty = await Faculty.findById(data.toFacultyId);
    if (!faculty) {
      throw new Error('Faculty member not found');
    }

    const meeting = await MeetingRequest.create({
      fromUserId: data.fromUserId,
      toFacultyId: data.toFacultyId,
      type: data.type,
      reason: data.reason,
      status: MeetingRequestStatus.PENDING,
      scheduledTime: data.scheduledTime
    });

    const populated = await MeetingRequest.findById(meeting._id)
      .populate('fromUserId', 'name email role')
      .populate({
        path: 'toFacultyId',
        populate: { path: 'userId', select: 'name email phone' }
      });

    // Create notification document for faculty
    const title = data.type === 'CALL' ? 'Principal Requested a Call' : 'Principal Requested a Meeting';
    const body = `Reason: ${data.reason}`;
    await Notification.create({
      recipientId: faculty.userId,
      title,
      body,
      type: 'MEETING_REQUEST',
      payload: { meetingId: meeting._id, type: data.type }
    });

    // Realtime Socket.IO dispatch
    try {
      SocketManager.emitToUser(faculty.userId.toString(), SocketEvent.MEETING_CREATED, populated);
      SocketManager.emitToUser(faculty.userId.toString(), SocketEvent.NOTIFICATION_CREATED, { title, body });
    } catch (e) {}

    return populated as IMeetingRequest;
  }

  /**
   * Faculty responds to meeting request (Accept, Decline, Available in 20 min)
   */
  static async respondToMeeting(data: {
    meetingId: string;
    facultyUserId: string;
    status: MeetingRequestStatus;
    responseNote?: string;
  }): Promise<IMeetingRequest | null> {
    const meeting = await MeetingRequest.findById(data.meetingId);
    if (!meeting) {
      throw new Error('Meeting request not found');
    }

    meeting.status = data.status;
    if (data.responseNote) meeting.responseNote = data.responseNote;
    await meeting.save();

    const populated = await MeetingRequest.findById(meeting._id)
      .populate('fromUserId', 'name email')
      .populate({
        path: 'toFacultyId',
        populate: { path: 'userId', select: 'name email phone' }
      });

    // Notify the requesting Principal
    const facultyName = (populated?.toFacultyId as any)?.userId?.name || 'Faculty';
    const title = `Faculty Responded to ${meeting.type}`;
    const body = `${facultyName} marked status as: ${data.status}. ${data.responseNote ? `Note: ${data.responseNote}` : ''}`;

    await Notification.create({
      recipientId: meeting.fromUserId,
      title,
      body,
      type: 'MEETING_RESPONSE',
      payload: { meetingId: meeting._id, status: data.status }
    });

    try {
      SocketManager.emitToUser(meeting.fromUserId.toString(), SocketEvent.MEETING_UPDATED, populated);
      SocketManager.emitToUser(meeting.fromUserId.toString(), SocketEvent.NOTIFICATION_CREATED, { title, body });
    } catch (e) {}

    return populated;
  }

  /**
   * Get meeting requests for a faculty member
   */
  static async getFacultyMeetings(facultyId: string): Promise<IMeetingRequest[]> {
    return await MeetingRequest.find({ toFacultyId: facultyId })
      .populate('fromUserId', 'name email role')
      .sort({ createdAt: -1 });
  }

  /**
   * Get all meeting requests (for Principal dashboard)
   */
  static async getAllMeetings(): Promise<IMeetingRequest[]> {
    return await MeetingRequest.find()
      .populate('fromUserId', 'name email role')
      .populate({
        path: 'toFacultyId',
        populate: { path: 'userId', select: 'name email phone' }
      })
      .sort({ createdAt: -1 });
  }
}
