import 'dart:io';

class AppConstants {
  static const String appName = "SRK Campus";
  static const String institutionName = "SRK Institute of Management & Computer Education";
  
  // Base API URL
  static String get baseUrl {
    // When running via adb reverse tcp:5000 tcp:5000 or on standard Android emulator
    if (Platform.isAndroid) {
      return 'http://127.0.0.1:5000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  static String get socketUrl {
    if (Platform.isAndroid) {
      return 'http://127.0.0.1:5000';
    }
    return 'http://localhost:5000';
  }

  // Pre-configured Quick Login Accounts (Real SRK MongoDB Seeded Data)
  static const Map<String, Map<String, String>> quickAccounts = {
    'principal': {
      'role': 'PRINCIPAL',
      'name': 'Dr. Nirdesh Buch',
      'title': 'Campus Principal',
      'email': 'nirdesh.buch@srk.edu',
      'password': 'Principal@123',
      'dept': 'Administration',
    },
    'campus_head': {
      'role': 'CAMPUS_HEAD',
      'name': 'Prof. Surbhi Ahir',
      'title': 'Campus Head',
      'email': 'surbhi.ahir@srk.edu',
      'password': 'CampusHead@123',
      'dept': 'Academic Affairs',
    },
    'teacher_nirali': {
      'role': 'FACULTY',
      'name': 'Prof. Nirali Thakkar',
      'title': 'Assistant Professor',
      'email': 'nirali.thakkar@srk.edu',
      'password': 'Faculty@123',
      'dept': 'Computer Applications (BCA)',
      'cabin': 'Faculty Cabin F-04',
    },
    'teacher_arjun': {
      'role': 'FACULTY',
      'name': 'Prof. Arjunsinh Vaghela',
      'title': 'Associate Professor',
      'email': 'arjunsinh.vaghela@srk.edu',
      'password': 'Faculty@123',
      'dept': 'Computer Applications (BCA)',
      'cabin': 'Faculty Cabin F-08',
    },
    'student_rahul': {
      'role': 'STUDENT',
      'name': 'Rahul Shah',
      'title': 'Student',
      'email': 'rahul.shah@srk.edu',
      'password': 'Student@123',
      'dept': 'BCA Sem 3 (Batch A)',
      'rollNo': '24BCA001',
    },
  };
}
