import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { ResponseUtil } from '../utils/response';
import { User } from '../models/User';
import { Student } from '../models/Student';
import { Faculty } from '../models/Faculty';
import { UserRole } from '../constants/enums';

export class AuthController {
  static async getUids(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const uids = AuthService.getAuthorizedUids();
      ResponseUtil.success(res, uids, 'Authorized campus UIDs retrieved');
    } catch (error: any) {
      next(error);
    }
  }

  static async sendOtp(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { identifier } = req.body;
      if (!identifier) {
        ResponseUtil.error(res, 'UID or Email/Phone is required', 400);
        return;
      }
      const otp = AuthService.generateOtp(identifier);
      ResponseUtil.success(res, { otp, message: `OTP sent successfully to ${identifier}` }, 'OTP generated');
    } catch (error: any) {
      next(error);
    }
  }

  static async signupWithUid(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { uid, email, phone, password, otp } = req.body;
      if (!uid || !email || !password || !otp) {
        ResponseUtil.error(res, 'UID, email, password, and OTP are required', 400);
        return;
      }

      const result = await AuthService.signupWithUid({ uid, email, phone, password, otp });
      ResponseUtil.success(res, result, 'Registration and activation successful', 201);
    } catch (error: any) {
      ResponseUtil.error(res, error.message || 'Registration failed', 400);
    }
  }

  static async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email, uid, identifier, password, deviceId } = req.body;
      const loginId = identifier || uid || email;

      if (!loginId || !password) {
        ResponseUtil.error(res, 'UID/Email and password are required', 400);
        return;
      }

      const result = await AuthService.login(loginId, password, deviceId);
      ResponseUtil.success(res, result, 'Login successful');
    } catch (error: any) {
      ResponseUtil.error(res, error.message || 'Login failed', 401);
    }
  }

  static async refreshToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { refreshToken } = req.body;
      if (!refreshToken) {
        ResponseUtil.error(res, 'Refresh token is required', 400);
        return;
      }

      const tokens = await AuthService.refreshToken(refreshToken);
      ResponseUtil.success(res, tokens, 'Tokens refreshed successfully');
    } catch (error: any) {
      ResponseUtil.error(res, error.message || 'Refresh token failed', 401);
    }
  }

  static async logout(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (req.user?._id) {
        await AuthService.logout(req.user._id);
      }
      ResponseUtil.success(res, { success: true }, 'Logged out successfully');
    } catch (error: any) {
      next(error);
    }
  }

  static async getMe(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        ResponseUtil.error(res, 'Unauthorized', 401);
        return;
      }

      const user = await User.findById(req.user._id).populate('departmentId');
      if (!user) {
        ResponseUtil.error(res, 'User not found', 404);
        return;
      }

      let profileDetails: any = null;
      if (user.role === UserRole.STUDENT) {
        profileDetails = await Student.findOne({ userId: user._id }).populate('departmentId');
      } else if (user.role === UserRole.FACULTY) {
        profileDetails = await Faculty.findOne({ userId: user._id }).populate('departmentId subjects');
      }

      ResponseUtil.success(res, {
        user,
        profileDetails
      }, 'User profile retrieved');
    } catch (error: any) {
      next(error);
    }
  }
}
