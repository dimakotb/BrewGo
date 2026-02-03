import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Position;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    as mapbox
    show Position;
import 'package:geolocator/geolocator.dart'
    show Geolocator, Position, LocationAccuracy;
import 'package:permission_handler/permission_handler.dart';
import '../../viewmodels/home_vm.dart';
import '../../data/models/shop.dart';
import 'menu_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const String routeName = '/map';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapboxMap;
  Position? _userPosition;
  bool _isLocationLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Shop> _filteredShops = [];
  List<Shop> _allShops = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadShops() {
    final homeViewModel = context.read<HomeViewModel>();
    // Refresh shops from Firebase if not already loading
    if (!homeViewModel.isLoading) {
      homeViewModel.refresh();
    }
    setState(() {
      _allShops = homeViewModel.shops;
      _filteredShops = _allShops;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredShops = _allShops;
      } else {
        _filteredShops =
            _allShops.where((shop) {
              return shop.name.toLowerCase().contains(query) ||
                  shop.address.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = position;
        _isLocationLoading = false;
      });

      if (_mapboxMap != null && _userPosition != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: mapbox.Position(
                _userPosition!.longitude,
                _userPosition!.latitude,
              ),
            ),
            zoom: 14.0,
          ),
          MapAnimationOptions(duration: 1500),
        );
      }
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    try {
      final locationComponent = mapboxMap.location;
      await locationComponent.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          pulsingColor: const Color(0xFF5A3E2C).value,
          pulsingMaxRadius: 200.0,
          showAccuracyRing: true,
          accuracyRingColor: const Color(0xFF5A3E2C).value,
          accuracyRingBorderColor: const Color(0xFFDCCFB9).value,
        ),
      );
    } catch (e) {
      debugPrint('Error enabling location component: $e');
    }

    if (_userPosition != null) {
      await mapboxMap.setCamera(
        CameraOptions(
          center: Point(
            coordinates: mapbox.Position(
              _userPosition!.longitude,
              _userPosition!.latitude,
            ),
          ),
          zoom: 14.0,
        ),
      );
    }
  }

  double _calculateDistance(Shop shop) {
    if (_userPosition == null ||
        shop.latitude == null ||
        shop.longitude == null) {
      return shop.distanceKm;
    }
    return Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          shop.latitude!,
          shop.longitude!,
        ) /
        1000;
  }

  void _showShopModal(Shop shop) {
    final distance = _calculateDistance(shop);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => _ShopDetailsModal(
            shop: shop,
            distance: distance,
            onVisitShop: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen(shop: shop)),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    // Update shops list when HomeViewModel changes
    if (_allShops.length != homeViewModel.shops.length ||
        (_allShops.isEmpty && homeViewModel.shops.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _allShops = homeViewModel.shops;
          // Re-apply search filter if there's a search query
          if (_searchController.text.isNotEmpty) {
            _onSearchChanged();
          } else {
            _filteredShops = _allShops;
          }
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFA78971),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA78971),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Map',
          style: TextStyle(
            fontFamily: 'Abril Fatface',
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("fullMapWidget"),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: mapbox.Position(
                  _userPosition?.longitude ?? 31.4203562,
                  _userPosition?.latitude ?? 29.9886323,
                ),
              ),
              zoom: _userPosition != null ? 14.0 : 12.0,
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
          ),
          if (_isLocationLoading || homeViewModel.isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF5A3E2C)),
              ),
            ),
          // Error message if shops fail to load
          if (homeViewModel.errorMessage != null && !homeViewModel.isLoading)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error loading shops: ${homeViewModel.errorMessage}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: () => homeViewModel.refresh(),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCCFB9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search shops...',
                        hintStyle: TextStyle(
                          color: Color(0xFF49454F),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          // Search results list
          if (_searchController.text.isNotEmpty && _filteredShops.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCCFB9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredShops.length,
                  itemBuilder: (context, index) {
                    final shop = _filteredShops[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          shop.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant, size: 24),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        shop.name,
                        style: const TextStyle(
                          fontFamily: 'Abril Fatface',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        shop.address,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _searchController.clear();
                        _showShopModal(shop);
                      },
                    );
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                await _getCurrentLocation();
                if (_mapboxMap != null && _userPosition != null) {
                  await _mapboxMap!.flyTo(
                    CameraOptions(
                      center: Point(
                        coordinates: mapbox.Position(
                          _userPosition!.longitude,
                          _userPosition!.latitude,
                        ),
                      ),
                      zoom: 15.0,
                    ),
                    MapAnimationOptions(duration: 1000),
                  );
                }
              },
              backgroundColor: const Color(0xFFDCCFB9),
              child: const Icon(Icons.my_location, color: Color(0xFF5A3E2C)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopDetailsModal extends StatelessWidget {
  final Shop shop;
  final double distance;
  final VoidCallback onVisitShop;

  const _ShopDetailsModal({
    required this.shop,
    required this.distance,
    required this.onVisitShop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDCCFB9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  shop.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontFamily: 'Abril Fatface',
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          shop.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Color(0xFF5A3E2C)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shop.address,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.straighten, size: 20, color: Color(0xFF5A3E2C)),
              const SizedBox(width: 8),
              Text(
                '${distance.toStringAsFixed(1)} km away',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onVisitShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A3E2C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Visit Shop Menu',
                style: TextStyle(
                  fontFamily: 'Abril Fatface',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
