import bcrypt from 'bcryptjs';
import { User, IUser } from '../models/User';
import { Student } from '../models/Student';
import { Faculty } from '../models/Faculty';
import { JwtUtil, JwtPayload } from '../security/jwt.util';
import { UserRole } from '../constants/enums';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface LoginResult {
  user: {
    id: string;
    name: string;
    email: string;
    role: UserRole;
    departmentId?: string;
    details?: any;
  };
  tokens: AuthTokens;
}

export class AuthService {
  static async login(email: string, candidatePass: string, deviceId?: string): Promise<LoginResult> {
    const user = await User.findOne({ email: email.toLowerCase() }).select('+passwordHash +isActive');
    if (!user) {
      throw new Error('Invalid email or password');
    }

    if (!user.isActive) {
      throw new Error('Account has been deactivated. Please contact campus administrator.');
    }

    const isMatch = await user.comparePassword(candidatePass);
    if (!isMatch) {
      throw new Error('Invalid email or password');
    }

    const payload: JwtPayload = {
      sub: user._id.toString(),
      role: user.role,
      email: user.email,
      departmentId: user.departmentId?.toString(),
      deviceId
    };

    const accessToken = JwtUtil.generateAccessToken(payload);
    const refreshToken = JwtUtil.generateRefreshToken(payload);

    // Hash refresh token and persist
    const salt = await bcrypt.genSalt(10);
    user.refreshTokenHash = await bcrypt.hash(refreshToken, salt);
    await user.save();

    let details: any = null;
    if (user.role === UserRole.STUDENT) {
      details = await Student.findOne({ userId: user._id }).populate('departmentId');
    } else if (user.role === UserRole.FACULTY) {
      details = await Faculty.findOne({ userId: user._id }).populate('departmentId subjects');
    }

    return {
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        role: user.role,
        departmentId: user.departmentId?.toString(),
        details
      },
      tokens: {
        accessToken,
        refreshToken
      }
    };
  }

  static async refreshToken(oldRefreshToken: string): Promise<AuthTokens> {
    let payload: JwtPayload;
    try {
      payload = JwtUtil.verifyRefreshToken(oldRefreshToken);
    } catch (err) {
      throw new Error('Invalid or expired refresh token');
    }

    const user = await User.findById(payload.sub).select('+refreshTokenHash +isActive');
    if (!user || !user.isActive || !user.refreshTokenHash) {
      throw new Error('Invalid session or inactive user');
    }

    const isTokenMatch = await bcrypt.compare(oldRefreshToken, user.refreshTokenHash);
    if (!isTokenMatch) {
      // Possible token reuse / breach detected -> invalidate token family
      user.refreshTokenHash = undefined;
      await user.save();
      throw new Error('Token reuse detected. Session invalidated for security.');
    }

    const newPayload: JwtPayload = {
      sub: user._id.toString(),
      role: user.role,
      email: user.email,
      departmentId: user.departmentId?.toString(),
      deviceId: payload.deviceId
    };

    const newAccessToken = JwtUtil.generateAccessToken(newPayload);
    const newRefreshToken = JwtUtil.generateRefreshToken(newPayload);

    const salt = await bcrypt.genSalt(10);
    user.refreshTokenHash = await bcrypt.hash(newRefreshToken, salt);
    await user.save();

    return {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken
    };
  }

  static async logout(userId: string): Promise<void> {
    await User.findByIdAndUpdate(userId, { $unset: { refreshTokenHash: 1 } });
  }
}
