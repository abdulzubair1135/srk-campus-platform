class AppConstants {
  static const String appName = "SRK Campus";
  static const String institutionName = "SRK Institute of Management & Computer Education";
  
  // Public Live Cloudflare Tunnel URL (Global HTTPS & WSS)
  static const String cloudflareTunnelUrl = 'https://loves-considerations-pensions-deutsch.trycloudflare.com';

  static String get baseUrl {
    return '$cloudflareTunnelUrl/api/v1';
  }

  static String get socketUrl {
    return cloudflareTunnelUrl;
  }

  // Pre-configured Quick Login Accounts (Real SRK MongoDB Seeded Data)
  static const Map<String, Map<String, String>> quickAccounts = {
    'principal': {
      'role': 'PRINCIPAL',
      'name': 'Dr. Nirdesh Buch',
      'title': 'Campus Principal',
      'email': 'nirdesh.buch@srk.edu',
      'password': 'Principal@123',
      'dept': 'Institutional Administration',
      'uid': 'SRK-ADM-001',
    },
    'campus_head': {
      'role': 'CAMPUS_HEAD',
      'name': 'Prof. Surbhi Ahir',
      'title': 'Campus Head',
      'email': 'surbhi.ahir@srk.edu',
      'password': 'CampusHead@123',
      'dept': 'Academic Affairs',
      'uid': 'SRK-ADM-002',
    },
    'teacher_nirali': {
      'role': 'FACULTY',
      'name': 'Prof. Nirali Thakkar',
      'title': 'Assistant Professor',
      'email': 'nirali.thakkar@srk.edu',
      'password': 'Faculty@123',
      'dept': 'Computer Applications (BCA)',
      'cabin': 'Faculty Cabin F-04',
      'uid': 'SRK-FAC-101',
    },
    'teacher_arjun': {
      'role': 'FACULTY',
      'name': 'Prof. Arjunsinh Vaghela',
      'title': 'Associate Professor',
      'email': 'arjunsinh.vaghela@srk.edu',
      'password': 'Faculty@123',
      'dept': 'Computer Applications (BCA)',
      'cabin': 'Faculty Cabin F-08',
      'uid': 'SRK-FAC-102',
    },
    'student_rahul': {
      'role': 'STUDENT',
      'name': 'Rahul Shah',
      'title': 'Student',
      'email': 'rahul.shah@srk.edu',
      'password': 'Student@123',
      'dept': 'Computer Applications (BCA)',
      'rollNo': '24BCA001',
      'uid': 'SRK-STU-201',
    },
  };
}
