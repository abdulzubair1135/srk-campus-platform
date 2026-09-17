import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/student_id_qr_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/leave_request_screen.dart';
import 'screens/p2p_sync_screen.dart';

void main() {
  runApp(const ProviderScope(child: StudentApp()));
}

class StudentApp extends StatefulWidget {
  const StudentApp({super.key});

  @override
  State<StudentApp> createState() => _StudentAppState();
}

class _StudentAppState extends State<StudentApp> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Student',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: _isLoggedIn
          ? StudentMainNavigation(onLogout: () => setState(() => _isLoggedIn = false))
          : LoginScreen(onLoginSuccess: () => setState(() => _isLoggedIn = true)),
    );
  }
}

class StudentMainNavigation extends StatefulWidget {
  final VoidCallback onLogout;
  const StudentMainNavigation({super.key, required this.onLogout});

  @override
  State<StudentMainNavigation> createState() => _StudentMainNavigationState();
}

class _StudentMainNavigationState extends State<StudentMainNavigation> {
  int _selectedIndex = 0;
  bool isOnline = true;
  int pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshSyncStatus();
  }

  void _refreshSyncStatus() async {
    final count = await StudentApiService().offlineQueue.getPendingCount();
    setState(() => pendingSyncCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final user = StudentApiService().currentUser;
    final name = user?['name'] ?? 'Rahul Shah';
    final dept = user?['department'] ?? 'Computer Engineering';
    final enroll = user?['enrollmentNumber'] ?? 'STU2026001';

    final screens = [
      _buildHomeScreen(name, dept, enroll),
      const StudentTimetableScreen(),
      const AttendanceHistoryScreen(),
      const StudentIdQrScreen(),
      const P2pSyncScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Student', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          // Offline / P2P indicator button
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const P2pSyncScreen()))
                  .then((_) => _refreshSyncStatus());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: isOnline ? Colors.white24 : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.cloud_done : Icons.cloud_off,
                    size: 15,
                    color: isOnline ? Colors.white : Colors.amber.shade900,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline ($pendingSyncCount)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOnline ? Colors.white : Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1565C0)),
              accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('$enroll • $dept'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(name.isNotEmpty ? name[0] : 'S', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home Dashboard'),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('My Timetable'),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check),
              title: const Text('Attendance & Confidence'),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: const Text('Digital Student ID'),
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('P2P Mesh & Offline Queue'),
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sick),
              title: const Text('Apply for Leave'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.fact_check), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.qr_code), label: 'My ID'),
          NavigationDestination(icon: Icon(Icons.sync), label: 'Sync'),
        ],
      ),
    );
  }

  Widget _buildHomeScreen(String name, String dept, String enroll) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, $name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('$dept • Div A', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),

          // CURRENT CLASS CARD
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFF1565C0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('CURRENT CLASS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('LIVE ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('DBMS (CS401)', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Room 204 • Arjun Sir', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const Text('10:00 - 11:00 AM', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Confidence: 94% (Verified)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                          ).then((_) => _refreshSyncStatus());
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('Scan Class QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // QUICK ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: _buildQuickButton('Show My ID QR', Icons.qr_code_2, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentIdQrScreen()));
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickButton('Apply Leave', Icons.sick, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // UPCOMING CLASS
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const ListTile(
              leading: CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.schedule, color: Color(0xFF1565C0))),
              title: Text('NEXT: Operating Systems (CS402)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Room 105 • 11:00 - 12:00 PM • Priya Ma\'am', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String title, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
