import mongoose, { Document, Schema } from 'mongoose';
import { MeetingRequestStatus } from '../constants/enums';

export interface IMeetingRequest extends Document {
  _id: mongoose.Types.ObjectId;
  fromUserId: mongoose.Types.ObjectId;
  toFacultyId: mongoose.Types.ObjectId;
  type: 'MEETING' | 'CALL';
  reason: string;
  status: MeetingRequestStatus;
  scheduledTime?: Date;
  responseNote?: string;
  createdAt: Date;
  updatedAt: Date;
}

const MeetingRequestSchema = new Schema<IMeetingRequest>(
  {
    fromUserId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    toFacultyId: { type: Schema.Types.ObjectId, ref: 'Faculty', required: true, index: true },
    type: { type: String, enum: ['MEETING', 'CALL'], default: 'MEETING' },
    reason: { type: String, required: true, trim: true },
    status: {
      type: String,
      enum: Object.values(MeetingRequestStatus),
      default: MeetingRequestStatus.PENDING,
      index: true
    },
    scheduledTime: { type: Date },
    responseNote: { type: String, trim: true }
  },
  {
    timestamps: true
  }
);

export const MeetingRequest = mongoose.model<IMeetingRequest>('MeetingRequest', MeetingRequestSchema);
