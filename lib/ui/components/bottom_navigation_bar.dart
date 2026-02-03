import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/map_screen.dart';

/// Reusable bottom navigation bar component with consistent design
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default navigation behavior
    switch (index) {
      case 0: // Home
        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.routeName,
          (Route<dynamic> route) => false,
        );
        break;
      case 1: // Map
        Navigator.pushNamed(context, MapScreen.routeName);
        break;
      case 2: // Cart
        Navigator.pushNamed(context, CartScreen.routeName);
        break;
      case 3: // Profile
        Navigator.pushNamed(context, ProfileScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFDCCFB9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.location_on_outlined,
            selectedIcon: Icons.location_on,
            label: 'Home',
            index: 0,
            onTap: () => _handleNavigation(context, 0),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.map_outlined,
            selectedIcon: Icons.map,
            label: 'Map',
            index: 1,
            onTap: () => _handleNavigation(context, 1),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart,
            label: 'Cart',
            index: 2,
            onTap: () => _handleNavigation(context, 2),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            index: 3,
            onTap: () => _handleNavigation(context, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: isSelected ? 28 : 26,
              color: isSelected ? Colors.black : Colors.black54,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

