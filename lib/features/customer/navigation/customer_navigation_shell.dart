import 'package:flutter/material.dart';
import '../bookings/screens/bookings_screen.dart';
import '../explore/screens/explore_screen.dart';
import '../favorites/screens/favorites_screen.dart';
import '../home/screens/customer_home_screen.dart';
import '../home/widgets/customer_bottom_navigation.dart';
import '../location/services/customer_location_service.dart';
import '../profile/screens/profile_screen.dart';

class CustomerNavigationShell extends StatefulWidget {
  final int initialIndex;

  const CustomerNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<CustomerNavigationShell> createState() => _CustomerNavigationShellState();
}

class _CustomerNavigationShellState extends State<CustomerNavigationShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    CustomerHomeScreen(),
    ExploreScreen(),
    BookingsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        CustomerLocationService.instance.checkAndPromptLocation(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // IndexedStack maintains screen state across tab changes
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Floating Persistent Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: CustomerBottomNavigation(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
