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

  // Auth: Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
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
      // Fallback for offline or direct response
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
    required String responseType, // 'BUSY' or 'ARRIVING'
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

  // Fetch Pending Meetings / Summons
  Future<List<dynamic>> getTeacherMeetings() async {
    try {
      final response = await dio.get('/meetings/my-requests');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List;
      }
      return [];
    } catch (e) {
      return [];
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

  // Submit QR Attendance (Student)
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

  // Campus Broadcasts & SOS
  Future<List<dynamic>> getBroadcasts() async {
    try {
      final response = await dio.get('/broadcasts');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
