import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/admin_login_screen.dart';
import 'screens/faculty_radar_screen.dart';
import 'screens/fuzzy_search_screen.dart';
import 'screens/timetable_manager_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/audit_trail_screen.dart';

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRK Principal & Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF283593)),
        useMaterial3: true,
      ),
      home: _isLoggedIn
          ? AdminMainNavigation(onLogout: () => setState(() => _isLoggedIn = false))
          : AdminLoginScreen(onLoginSuccess: () => setState(() => _isLoggedIn = true)),
    );
  }
}

class AdminMainNavigation extends StatefulWidget {
  final VoidCallback onLogout;
  const AdminMainNavigation({super.key, required this.onLogout});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FacultyRadarScreen(),
    FuzzySearchScreen(),
    TimetableManagerScreen(),
    AnalyticsDashboardScreen(),
    AuditTrailScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF283593)),
              accountName: Text('Dr. Nirdesh Buch (NB)', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('Principal & Director • SRK Institute'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('NB', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF283593))),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.radar),
              title: const Text('SRK Faculty Presence Radar'),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Campus Global Search'),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: const Text('SRK Master Timetable Editor'),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Campus Analytics & Metrics'),
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Audit Trail'),
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.radar), label: 'Radar'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.edit_calendar), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.security), label: 'Audit'),
        ],
      ),
    );
  }
}
