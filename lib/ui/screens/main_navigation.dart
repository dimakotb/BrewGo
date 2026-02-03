import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'review_screen.dart';
import 'cart_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    MenuScreen(),
    CartScreen(),
    ReviewScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Positioned.fill(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          // Sticky Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                height: 89,
                decoration: ShapeDecoration(
                  color: Colors.white.withValues(alpha: 0.30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(44.50),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 6.50,
                      offset: Offset(0, 4),
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(icon: Icons.home, index: 0, label: 'Home'),
                    _buildNavItem(
                      icon: Icons.restaurant_menu,
                      index: 1,
                      label: 'Menu',
                    ),
                    _buildNavItem(
                      icon: Icons.shopping_cart,
                      index: 2,
                      label: 'Cart',
                    ),
                    _buildNavItem(
                      icon: Icons.star,
                      index: 3,
                      label: 'Reviews',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? Colors.black
                    : Colors.black.withValues(alpha: 0.60),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : Colors.black.withValues(alpha: 0.60),
                fontSize: 12,
                fontFamily: 'SF Pro',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

