import 'package:brewgo_app/ui/screens/cart_screen.dart';
import 'package:brewgo_app/ui/screens/profile_screen.dart';
import 'package:brewgo_app/ui/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../viewmodels/home_vm.dart';
import '../../data/models/shop.dart';
import '../screens/menu_screen.dart';
import '../components/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home'; // Define home route for consistency

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current index of the selected tab, starting at 0 (Location icon)
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  PointAnnotationManager? _pointAnnotationManager;

  @override
  void dispose() {
    _searchController.dispose();
    _pointAnnotationManager = null;
    // Restore status bar when leaving this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation Logic: The Cart Icon is the 3rd item (index 2)
    if (index == 2) {
      // Use named routing for consistency and better practice
      Navigator.pushNamed(context, CartScreen.routeName);

      // OPTIONAL: If you want to use MaterialPageRoute (like for MenuScreen):
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const CartScreen()),
      // );
    }
    if (index == 3) {
      Navigator.pushNamed(context, ProfileScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 393,
          height: 852,
          child: Scaffold(
            backgroundColor: const Color(0xFFA78971),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header with logo and search bar (omitted for brevity)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BrewGo',
                                  style: TextStyle(
                                    fontFamily: 'Abril Fatface',
                                    fontSize: 25,
                                    color: Colors.black,
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/coffeebeans.png.png",
                                  height: 95,
                                  width: 95,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCCFB9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(
                                            color: Color(0xFF1E1E1E),
                                            fontSize: 12,
                                            fontFamily: 'Roboto',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Search coffee, shops',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF49454F),
                                              fontSize: 12,
                                              fontFamily: 'Roboto',
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            setState(
                                              () {},
                                            ); // Update UI to show/hide clear button
                                            context
                                                .read<HomeViewModel>()
                                                .searchShops(value);
                                          },
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (_searchController.text.isNotEmpty)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {}); // Update UI
                                                context
                                                    .read<HomeViewModel>()
                                                    .clearSearch();
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.search,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.map_outlined,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Mapbox Map
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            decoration: const BoxDecoration(
                              color: Color(0xFFA78971),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: MapWidget(
                                    key: const ValueKey("mapWidget"),
                                    cameraOptions: CameraOptions(
                                      center: Point(
                                        coordinates: Position(
                                          31.4203562, // Longitude
                                          29.9886323, // Latitude
                                        ),
                                      ),
                                      zoom: 12.0,
                                    ),
                                    styleUri: MapboxStyles.MAPBOX_STREETS,
                                    onMapCreated: (MapboxMap mapboxMap) async {
                                      // Create point annotation manager for markers
                                      _pointAnnotationManager =
                                          await mapboxMap.annotations
                                              .createPointAnnotationManager();

                                      // Add markers for shops
                                      _addShopMarkers();
                                    },
                                  ),
                                ),
                                // Expand button
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          MapScreen.routeName,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCCFB9),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.fullscreen,
                                          color: Color(0xFF5A3E2C),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Nearby Shops section (omitted for brevity)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                color: Color(0xFFA78971),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nearby shops',
                                      style: TextStyle(
                                        fontFamily: 'Abril Fatface',
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (homeViewModel.isLoading)
                                      const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF5A3E2C),
                                              ),
                                        ),
                                      )
                                    else if (homeViewModel.errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          'Error: ${homeViewModel.errorMessage}',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    else if (homeViewModel.shops.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                          'No shops found',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    else
                                      ...homeViewModel.shops.map(
                                        (shop) => _buildShopCard(
                                          context: context,
                                          shop: shop,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }

  // Shop Card widget (Navigation to MenuScreen with Shop data)
  Widget _buildShopCard({required BuildContext context, required Shop shop}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCCFB9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              shop.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuScreen(shop: shop),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontFamily: 'Abril Fatface',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.address,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        shop.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${shop.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
        ],
      ),
    );
  }

  /// Add markers for shops on the map
  Future<void> _addShopMarkers() async {
    if (_pointAnnotationManager == null) return;

    final homeViewModel = context.read<HomeViewModel>();
    final shops =
        homeViewModel.shops
            .where((shop) => shop.latitude != null && shop.longitude != null)
            .toList();

    if (shops.isEmpty) return;

    final List<PointAnnotationOptions> annotations =
        shops.map((shop) {
          return PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(shop.longitude!, shop.latitude!),
            ),
            textField: '📍',
            textColor: const Color(0xFF5A3E2C).value,
            textSize: 24.0,
            textOffset: [0.0, -1.5],
            textAnchor: TextAnchor.BOTTOM,
          );
        }).toList();

    await _pointAnnotationManager!.createMulti(annotations);
  }
}
