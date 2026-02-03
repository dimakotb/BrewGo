import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/auth_vm.dart';
import 'login_screen.dart';
import '../components/bottom_navigation_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';
  static const String homeRoute = '/home';
  static const String cartRoute = '/cart';
  static const String favouritesRoute = '/favourites';

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    final user = FirebaseAuth.instance.currentUser;
    final authViewModel = context.watch<AuthViewModel>();

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 393,
          height: 852,
          child: Scaffold(
            backgroundColor: const Color(0xFFA78971),
            body: Stack(
              children: [
                // Main Content
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 50,
                        ),

                        // BrewGo Logo & Location
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BrewGo',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontFamily: 'Abril Fatface',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Container(
                                    width: 99,
                                    height: 48,
                                    decoration: ShapeDecoration(
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          "assets/images/coffeebeans.png.png",
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Profile Title
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontFamily: 'Abril Fatface',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Profile Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCCFB9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF5A3E2C),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: const Color(0xFF5A3E2C).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User Name
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Abril Fatface',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // User Email
                        Text(
                          user?.email ?? 'No email',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 16,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Profile Options
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              _buildProfileOption(
                                context,
                                icon: Icons.receipt_long,
                                title: 'Order History',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Order History - Coming soon',
                                      ),
                                      backgroundColor: Color(0xFF5A3E2C),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildProfileOption(
                                context,
                                icon: Icons.favorite,
                                title: 'Favorites',
                                onTap: () {
                                  Navigator.pushNamed(context, favouritesRoute);
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildProfileOption(
                                context,
                                icon: Icons.payment,
                                title: 'Payment Methods',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Payment Methods - Coming soon',
                                      ),
                                      backgroundColor: Color(0xFF5A3E2C),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildProfileOption(
                                context,
                                icon: Icons.settings,
                                title: 'Settings',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Settings - Coming soon'),
                                      backgroundColor: Color(0xFF5A3E2C),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildProfileOption(
                                context,
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Help & Support - Coming soon',
                                      ),
                                      backgroundColor: Color(0xFF5A3E2C),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 30),

                              // Logout Button
                              GestureDetector(
                                onTap:
                                    authViewModel.isLoading
                                    ? null
                                    : () async {
                                        await authViewModel.signOut();
                                        if (context.mounted) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            LoginScreen.routeName,
                                          );
                                        }
                                      },
                                child: Container(
                                  width: 393 - 32,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: ShapeDecoration(
                                    color:
                                        authViewModel.isLoading
                                            ? const Color(
                                              0xFF5A3E2C,
                                            ).withOpacity(0.6)
                                        : const Color(0xFF5A3E2C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child:
                                        authViewModel.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFFF5F5F5)),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.logout,
                                                color: Color(0xFFF5F5F5),
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Logout',
                                                style: TextStyle(
                                                  color: Color(0xFFF5F5F5),
                                                  fontSize: 18,
                                                  fontFamily: 'Abril Fatface',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),


                // Bottom Navigation Bar (CONSISTENT DESIGN)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomBottomNavigationBar(
                    currentIndex: 3, // Profile/Reviews is active
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 393 - 32,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFDCCFB9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF5A3E2C), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
