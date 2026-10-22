import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bookings/screens/manager_bookings_screen.dart';
import '../dashboard/screens/branch_manager_dashboard_screen.dart';
import '../profile/screens/manager_profile_screen.dart';
import '../services/screens/manager_services_screen.dart';
import 'manager_bottom_navigation.dart';
import 'manager_drawer.dart';

class ManagerNavigationShell extends StatefulWidget {
  final int initialTab;

  const ManagerNavigationShell({super.key, this.initialTab = 0});

  @override
  State<ManagerNavigationShell> createState() => _ManagerNavigationShellState();
}

class _ManagerNavigationShellState extends State<ManagerNavigationShell> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      BranchManagerDashboardScreen(
        onOpenDrawer: _openDrawer,
        onNavigateTab: _onTabSelected,
      ),
      ManagerBookingsScreen(onOpenDrawer: _openDrawer),
      ManagerServicesScreen(onOpenDrawer: _openDrawer),
      ManagerProfileScreen(onOpenDrawer: _openDrawer),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.warmIvory,
      drawer: ManagerDrawer(
        currentTabIndex: _currentIndex,
        onSelectTab: _onTabSelected,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
