import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import 'admin/faculty_radar_view.dart';
import 'teacher/principal_summon_view.dart';
import 'teacher/attendance_generator_view.dart';
import 'student/student_home_view.dart';
import 'student/qr_scanner_view.dart';
import 'student/faculty_locator_view.dart';
import 'control_panel_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  void _showRoleSwitcherDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '⚡ Switch Active Campus Role',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              _buildRoleSwitchTile(ctx, 'principal', 'Principal (Dr. Nirdesh Buch)', Icons.shield_rounded, Colors.purple),
              _buildRoleSwitchTile(ctx, 'campus_head', 'Campus Head (Prof. Surbhi Ahir)', Icons.business_rounded, AppTheme.secondaryNavy),
              _buildRoleSwitchTile(ctx, 'teacher_nirali', 'Teacher (Prof. Nirali Thakkar)', Icons.person_pin_circle_rounded, AppTheme.accentGold),
              _buildRoleSwitchTile(ctx, 'student_rahul', 'Student (Rahul Shah - BCA 3)', Icons.school_rounded, AppTheme.statusGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSwitchTile(BuildContext ctx, String key, String title, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        Navigator.pop(ctx);
        setState(() => _currentIndex = 0);
        ref.read(authProvider.notifier).quickLogin(key);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    List<Widget> screens = [];
    List<BottomNavigationBarItem> navItems = [];

    if (user?.isPrincipal == true) {
      screens = [
        const FacultyRadarView(),
        const FacultyLocatorView(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.radar_rounded),
          label: 'Faculty Radar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_city_rounded),
          label: 'Campus Cabins',
        ),
      ];
    } else if (user?.isTeacher == true) {
      screens = [
        const PrincipalSummonView(),
        const AttendanceGeneratorView(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active_rounded),
          label: '🚨 Principal Summon',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_rounded),
          label: 'QR Attendance',
        ),
      ];
    } else {
      screens = [
        const StudentHomeView(),
        const QrScannerView(),
        const FacultyLocatorView(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Classes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner_rounded),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_rounded),
          label: 'Faculty',
        ),
      ];
    }

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    String roleBadge = 'STUDENT';
    Color badgeColor = AppTheme.statusGreen;
    if (user?.role == 'PRINCIPAL') {
      roleBadge = '👑 PRINCIPAL';
      badgeColor = Colors.purple.shade400;
    } else if (user?.role == 'CAMPUS_HEAD') {
      roleBadge = '🏛️ CAMPUS HEAD';
      badgeColor = AppTheme.accentGold;
    } else if (user?.role == 'FACULTY') {
      roleBadge = '👨‍🏫 FACULTY';
      badgeColor = AppTheme.accentGoldLight;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              user?.name ?? 'SRK Campus',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                roleBadge,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '🛠️ Control Panel',
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ControlPanelScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Switch Role',
            icon: const Icon(Icons.swap_horiz_rounded, color: AppTheme.accentGold),
            onPressed: _showRoleSwitcherDialog,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryNavy,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}
