import 'dart:async';
import 'package:dio/dio.dart';

class TeacherApiService {
  static final TeacherApiService _instance = TeacherApiService._internal();
  factory TeacherApiService() => _instance;
  TeacherApiService._internal();

  String baseUrl = 'http://localhost:5000/api/v1';
  final Dio _dio = Dio();
  String? accessToken;
  Map<String, dynamic>? currentUser;
  String currentStatus = 'IN_CLASS (Teaching - Room 201)';
  bool isMobileDataOn = false; // Demo BLE alert trigger

  bool get isLoggedIn => accessToken != null;

  void setTokens(String access, Map<String, dynamic> user) {
    accessToken = access;
    currentUser = user;
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post('$baseUrl/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        setTokens(data['accessToken'], data['user']);
        return true;
      }
    } catch (_) {
      // Demo fallback with Real SRK Faculty profile
      currentUser = {
        'name': 'Prof. N. T. Thakkar (NT)',
        'code': 'NT',
        'email': email,
        'role': 'FACULTY',
        'department': 'Bachelor of Computer Applications',
        'designation': 'Associate Professor',
        'subjects': ['DBMS - I (BCA301)', 'Web Designing', 'Software Engineering']
      };
      accessToken = 'demo_faculty_token';
      return true;
    }
    return false;
  }

  Future<void> updateStatus(String status) async {
    currentStatus = status;
    try {
      await _dio.patch('$baseUrl/faculty/status', data: {'status': status});
    } catch (_) {}
  }

  Future<Map<String, dynamic>> unlockRoomAndStartClass(String roomQr) async {
    currentStatus = 'IN_CLASS (Teaching - Room 201)';
    return {
      'success': true,
      'data': {
        'sessionId': 'sess_dbms_301',
        'roomNumber': '201',
        'subject': 'DBMS - I (BCA301)',
      }
    };
  }

  Future<Map<String, dynamic>> getDynamicQr(String sessionId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonce = timestamp ~/ 15000;
    return {
      'qrCode': 'CAMPUS_SESSION_V1:$sessionId:$nonce:$timestamp:hmac_rolling_signature_srk_2026',
      'expiresInSeconds': 15 - ((timestamp ~/ 1000) % 15),
      'nonce': nonce,
    };
  }

  Future<bool> verifyStudentQr(String studentQr) async {
    return true;
  }

  List<Map<String, dynamic>> getTeachingSchedule(String day) {
    return [
      {'session': 'Session 1 (08:40 - 09:40 AM)', 'sub': 'DBMS - I (BCA301)', 'class': 'BCA Sem 3', 'room': 'Room 201', 'active': true},
      {'session': 'Session 2 (09:45 - 10:40 AM)', 'sub': 'Web Designing (BCA102)', 'class': 'BCA Sem 1', 'room': 'Web Lab', 'active': false},
      {'session': 'Session 3 (11:30 - 12:25 PM)', 'sub': 'Software Engineering (BCA503)', 'class': 'BCA Sem 5', 'room': 'Room 203', 'active': false},
      {'session': 'Session 4 (12:30 - 01:25 PM)', 'sub': 'DBMS Lab (BCA301L)', 'class': 'BCA Sem 3', 'room': 'DBMS Lab', 'active': false},
    ];
  }

  Future<List<dynamic>> getPrincipalRequests() async {
    return [
      {
        'id': 'meet_01',
        'from': 'Dr. Sharma (Principal)',
        'type': 'MEETING',
        'reason': 'NAAC Timetable Verification & Class Attendance Compliance',
        'status': 'PENDING',
        'time': 'Today, 01:30 PM (Post Session 4)'
      },
      {
        'id': 'call_02',
        'from': 'Dr. Sharma (Principal)',
        'type': 'CALL',
        'reason': 'Check student attendance threshold for BCA Sem 3',
        'status': 'PENDING',
        'time': '09:40 AM (During Recess)'
      },
    ];
  }

  Future<void> respondMeeting(String id, String status, String note) async {
    if (status == 'ACCEPTED') {
      currentStatus = 'WITH_PRINCIPAL (Meeting / Discussion)';
    }
  }
}
