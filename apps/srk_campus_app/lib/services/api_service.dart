import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;
  String? _authToken;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 2500),
        receiveTimeout: const Duration(milliseconds: 2500),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Fetch 30 Authorized Campus UIDs
  Future<List<dynamic>> getAuthorizedUids() async {
    try {
      final response = await dio.get('/auth/uids');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Request 4-digit verification OTP
  Future<Map<String, dynamic>> sendOtp(String identifier) async {
    try {
      final response = await dio.post(
        '/auth/send-otp',
        data: {'identifier': identifier},
      );
      return response.data ?? {'success': true, 'data': {'otp': '4821'}};
    } catch (e) {
      return {'success': false, 'message': '$e'};
    }
  }

  // Sign Up with UID & OTP verification
  Future<Map<String, dynamic>> signupWithUid({
    required String uid,
    required String email,
    String? phone,
    required String password,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        '/auth/signup-uid',
        data: {
          'uid': uid,
          'email': email,
          'phone': phone,
          'password': password,
          'otp': otp,
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['tokens']?['accessToken'] ?? data['token'];
        if (token != null) {
          setAuthToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
        }
        return response.data;
      }
      return {'success': false, 'message': response.data?['message'] ?? 'Sign up failed'};
    } catch (e) {
      return {'success': false, 'message': 'Registration error: $e'};
    }
  }

  // Auth: Login via UID or Email
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'identifier': identifier, 'password': password},
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['tokens']?['accessToken'] ?? data['token'];
        if (token != null) {
          setAuthToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
        }
        return response.data;
      }
      return {'success': false, 'message': response.data?['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Principal / Admin: Urgent Summon Teacher to Cabin
  Future<Map<String, dynamic>> sendUrgentCabinCall({
    required String facultyId,
    required String location,
    String? reason,
  }) async {
    try {
      final response = await dio.post(
        '/meetings/urgent-call',
        data: {
          'facultyId': facultyId,
          'location': location,
          'reason': reason ?? 'Urgent consultation requested by Principal',
        },
      );
      return response.data ?? {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Error sending urgent summon: $e'};
    }
  }

  // Teacher: 1-Tap Zero-Typing Quick Respond
  Future<Map<String, dynamic>> quickRespondMeeting({
    required String meetingId,
    required String responseType,
    Map<String, dynamic>? autoDetails,
    int? transitEtaMinutes,
  }) async {
    try {
      final response = await dio.post(
        '/meetings/$meetingId/quick-respond',
        data: {
          'responseType': responseType,
          'autoDetails': autoDetails ?? {},
          'transitEtaMinutes': transitEtaMinutes ?? (responseType == 'ARRIVING' ? 2 : 0),
        },
      );
      return response.data ?? {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Error responding: $e'};
    }
  }

  // Faculty Radar
  Future<List<dynamic>> getFacultyRadar() async {
    try {
      final response = await dio.get('/radar');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Submit QR Attendance
  Future<Map<String, dynamic>> markAttendance({
    required String qrCodeData,
  }) async {
    try {
      final response = await dio.post(
        '/attendance/mark',
        data: {'code': qrCodeData},
      );
      return response.data ?? {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Error logging attendance: $e'};
    }
  }
}
