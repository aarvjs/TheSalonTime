import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bookings/screens/partner_bookings_screen.dart';
import '../dashboard/screens/partner_dashboard_screen.dart';
import '../profile/screens/partner_profile_screen.dart';
import '../services/screens/services_screen.dart';
import 'partner_bottom_navigation.dart';
import 'partner_drawer.dart';

class PartnerNavigationShell extends StatefulWidget {
  final int initialIndex;

  const PartnerNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<PartnerNavigationShell> createState() => _PartnerNavigationShellState();
}

class _PartnerNavigationShellState extends State<PartnerNavigationShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      PartnerDashboardScreen(
        onOpenDrawer: _openDrawer,
        onNavigateTab: _onTabSelected,
      ),
      PartnerBookingsScreen(
        onOpenDrawer: _openDrawer,
      ),
      ServicesScreen(
        onOpenDrawer: _openDrawer,
      ),
      PartnerProfileScreen(
        onOpenDrawer: _openDrawer,
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.warmIvory,
      drawer: PartnerDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: PartnerBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
