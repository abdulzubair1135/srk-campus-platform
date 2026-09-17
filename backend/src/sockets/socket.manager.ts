import { Server as HttpServer } from 'http';
import { Server as SocketIOServer, Socket } from 'socket.io';
import { JwtUtil } from '../security/jwt.util';
import { logger } from '../utils/logger';
import { SocketEvent, UserRole } from '../constants/enums';

export class SocketManager {
  private static io: SocketIOServer | null = null;

  static initialize(httpServer: HttpServer, allowedOrigins: string[]): SocketIOServer {
    this.io = new SocketIOServer(httpServer, {
      cors: {
        origin: allowedOrigins,
        methods: ['GET', 'POST'],
        credentials: true
      },
      pingTimeout: 30000,
      pingInterval: 25000
    });

    // Authenticate socket connections with JWT
    this.io.use((socket: Socket, next) => {
      const token = socket.handshake.auth.token || socket.handshake.headers['authorization']?.replace('Bearer ', '');
      if (!token) {
        return next(new Error('Authentication token required'));
      }

      try {
        const payload = JwtUtil.verifyAccessToken(token);
        (socket as any).user = payload;
        next();
      } catch (err) {
        next(new Error('Invalid socket authentication token'));
      }
    });

    this.io.on('connection', (socket: Socket) => {
      const user = (socket as any).user;
      logger.info(`Socket client connected: ${socket.id}, User: ${user?.sub} (${user?.role})`);

      // Auto-join personal user room
      if (user?.sub) {
        socket.join(`user:${user.sub}`);
      }

      // Auto-join role room
      if (user?.role) {
        socket.join(`role:${user.role}`);
      }

      // Auto-join department room
      if (user?.departmentId) {
        socket.join(`department:${user.departmentId}`);
      }

      // Join class session room
      socket.on('join:session', (sessionId: string) => {
        socket.join(`session:${sessionId}`);
        logger.debug(`Socket ${socket.id} joined session:${sessionId}`);
      });

      // Leave class session room
      socket.on('leave:session', (sessionId: string) => {
        socket.leave(`session:${sessionId}`);
        logger.debug(`Socket ${socket.id} left session:${sessionId}`);
      });

      socket.on('disconnect', (reason) => {
        logger.info(`Socket client disconnected: ${socket.id} (${reason})`);
      });
    });

    return this.io;
  }

  static getIO(): SocketIOServer {
    if (!this.io) {
      throw new Error('SocketManager not initialized yet');
    }
    return this.io;
  }

  /**
   * Broadcasts to a specific class session room
   */
  static emitToSession(sessionId: string, event: SocketEvent, data: any): void {
    if (this.io) {
      this.io.to(`session:${sessionId}`).emit(event, data);
    }
  }

  /**
   * Broadcasts to an individual user
   */
  static emitToUser(userId: string, event: SocketEvent, data: any): void {
    if (this.io) {
      this.io.to(`user:${userId}`).emit(event, data);
    }
  }

  /**
   * Broadcasts to a role group (e.g. all Admins / Principals)
   */
  static emitToRole(role: UserRole, event: SocketEvent, data: any): void {
    if (this.io) {
      this.io.to(`role:${role}`).emit(event, data);
    }
  }
}
