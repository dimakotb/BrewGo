import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/shop.dart';
import '../../data/models/menu_item.dart';
import '../../viewmodels/menu_vm.dart';
import '../../viewmodels/cart_vm.dart';
import '../components/bottom_navigation_bar.dart';

class FavoritesScreen {
  static const String routeName = '/favorites';
}

class MenuScreen extends StatefulWidget {
  final Shop? shop;

  const MenuScreen({super.key, this.shop});

  static const String routeName = '/menu';

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load menu when shop is provided
    if (widget.shop != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MenuViewModel>().setShop(widget.shop!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Restore status bar when leaving this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // 1. Fixed Sizing Wrapper (Matching HomeScreen)
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 393, // Fixed width
          height: 852, // Fixed height
          child: Scaffold(
            backgroundColor: const Color(0xFFA78971), // Main background color
            body: Stack(
              children: [
                // 2. Scrollable Content
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Safe area padding will be handled by the top content layout
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 10,
                        ),

                        // --- 1. BrewGo Logo & Location (Unchanged) ---
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
                                    ),
                                  ),
                                  // Coffee beans image under BrewGo
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
                              // Location Button
                              Container(
                                width: 90,
                                height: 32,
                                decoration: ShapeDecoration(
                                  color: Colors.white.withOpacity(0.30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '10 km',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- 2. Shop Image (Dynamic) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Consumer<MenuViewModel>(
                            builder: (context, menuViewModel, child) {
                              final shop =
                                  menuViewModel.currentShop ?? widget.shop;
                              // Use shop image if available, otherwise fallback
                              final imageUrl =
                                  shop?.imageUrl ??
                                  "assets/images/rafbranch.png";

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  imageUrl,
                                  width: 393 - 32,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 393 - 32,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        // --- 3. Shop Details Card (Dynamic) ---
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Consumer<MenuViewModel>(
                              builder: (context, menuViewModel, child) {
                                final shop =
                                    menuViewModel.currentShop ?? widget.shop;
                                if (shop == null) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  width: 393 - 32,
                                  height: 80,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFA78971),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          shop.imageUrl,
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.restaurant,
                                                size: 24,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              shop.name,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  '★',
                                                  style: TextStyle(
                                                    color: Colors.amber,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${shop.rating.toStringAsFixed(1)} - ${shop.distanceKm.toStringAsFixed(1)} km',
                                                  style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // --- 4. Search Bar (Functional) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 44,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFDCCFB9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search menu',
                                      hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.5),
                                        fontSize: 15,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      setState(
                                        () {},
                                      ); // Update UI to show/hide clear button
                                      context.read<MenuViewModel>().searchMenu(
                                        value,
                                      );
                                    },
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    color: Colors.black.withOpacity(0.5),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {}); // Update UI
                                      context
                                          .read<MenuViewModel>()
                                          .clearSearch();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                Icon(
                                  Icons.search,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- 5. Category Filters (Functional) ---
                        Consumer<MenuViewModel>(
                          builder: (context, menuViewModel, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildCategoryChip(
                                      'All',
                                      menuViewModel.selectedCategory == 'All',
                                      onTap:
                                          () => menuViewModel.filterByCategory(
                                            'All',
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(
                                      'Best sellers',
                                      menuViewModel.selectedCategory ==
                                          'Best sellers',
                                      onTap:
                                          () => menuViewModel.filterByCategory(
                                            'Best sellers',
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(
                                      'Espresso',
                                      menuViewModel.selectedCategory ==
                                          'Espresso',
                                      onTap:
                                          () => menuViewModel.filterByCategory(
                                            'Espresso',
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(
                                      'Cold Brew',
                                      menuViewModel.selectedCategory ==
                                          'Cold Brew',
                                      onTap:
                                          () => menuViewModel.filterByCategory(
                                            'Cold Brew',
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(
                                      'Iced coffee',
                                      menuViewModel.selectedCategory ==
                                          'Iced coffee',
                                      onTap:
                                          () => menuViewModel.filterByCategory(
                                            'Iced coffee',
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(
                                      'Pastries',
                                      menuViewModel.selectedCategory ==
                                          'Pastries',
                                      onTap:
                                          () => menuViewModel.filterByCategory(
                                            'Pastries',
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // --- 6. Menu Items Grid (Functional) ---
                        Consumer<MenuViewModel>(
                          builder: (context, menuViewModel, child) {
                            if (menuViewModel.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF5A3E2C),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (menuViewModel.errorMessage != null) {
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Error: ${menuViewModel.errorMessage}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (menuViewModel.menuItems.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(
                                  child: Text(
                                    'No menu items found',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                // Aspect ratio calculated for the fixed width 393
                                childAspectRatio: ((393 - 32 - 10) / 2) / 200,
                                children:
                                    menuViewModel.menuItems.map((item) {
                                      return _buildMenuItem(context, item);
                                    }).toList(),
                              ),
                            );
                          },
                        ),
                        // Space for the custom navigation bar
                        // Adjusted height to ensure the bottom bar does not overlap content
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // --- 7. Bottom Navigation (CONSISTENT DESIGN) ---
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomBottomNavigationBar(
                    currentIndex: 1, // Menu/Favorites is active
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets (Functional) ---

  Widget _buildCategoryChip(
    String label,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: ShapeDecoration(
          color: const Color(0xFFDCCFB9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontFamily: 'SF Pro',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFFDCCFB9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Image.asset(
            item.imageUrl,
            height: 100,
            width: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.price.toStringAsFixed(0)} E£',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<CartViewModel>().addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} added to cart!'),
                            backgroundColor: const Color(0xFF5A3E2C),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
