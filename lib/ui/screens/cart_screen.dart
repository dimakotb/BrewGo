import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_vm.dart';
import '../../data/models/cart_item.dart';
import '../components/bottom_navigation_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const String routeName = '/cart';
  static const String homeRoute = '/home'; // Target for the Location Pin
  static const String favouritesRoute = '/favourites';
  static const String profileRoute = '/profile';
  static const String paymentRoute = '/payment';

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Center(
        child: FittedBox(
          fit:
              BoxFit
                  .contain, // Ensures the content scales to fit the available space
          child: SizedBox(
            width: 393, // Fixed width as per design
            height: 852, // Fixed height as per design
            child: Scaffold(
            backgroundColor: const Color(0xFFA78971), // Main background color
            body: Stack(
              children: [
                // 1. Main Scrollable Content
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Space for top padding
                        const SizedBox(height: 50),

                        // --- BrewGo Logo & Location ---
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
                        const SizedBox(height: 15),

                        // --- My Cart Title and Icon ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              const Text(
                                'My Cart',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontFamily: 'Abril Fatface',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.black.withOpacity(0.8),
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Item Cards (Dynamic from CartViewModel) ---
                        Consumer<CartViewModel>(
                          builder: (context, cartViewModel, child) {
                            if (cartViewModel.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 64,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Your cart is empty',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 18,
                                          fontFamily: 'SF Pro',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                ...cartViewModel.items.map((cartItem) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildCartItemCard(
                                      context: context,
                                      cartItem: cartItem,
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 18),
                              ],
                            );
                          },
                        ),

                        // --- Order Summary (Dynamic from CartViewModel) ---
                        Consumer<CartViewModel>(
                          builder: (context, cartViewModel, child) {
                            if (cartViewModel.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Center(
                              // Center the container horizontally
                              child: Container(
                                width: 393 - 32, // Match item card width
                                padding: const EdgeInsets.all(
                                  20,
                                ), // Internal padding for the summary content
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFDCCFB9,
                                  ), // Light beige background
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order Summary',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildSummaryRow(
                                      'Items subtotal',
                                      '${cartViewModel.subtotal.toStringAsFixed(0)} E£',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow(
                                      'Taxes',
                                      '${cartViewModel.taxes.toStringAsFixed(0)} E£',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow(
                                      'Service fees',
                                      '${cartViewModel.serviceFees.toStringAsFixed(0)} E£',
                                    ),
                                    const Divider(
                                      color: Colors.black,
                                      thickness: 0.5,
                                      height: 25,
                                    ),
                                    _buildSummaryRow(
                                      'Total',
                                      '${cartViewModel.total.toStringAsFixed(0)} E£',
                                      isTotal: true,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),

                        // --- Checkout Button (Only show if cart is not empty) ---
                        Consumer<CartViewModel>(
                          builder: (context, cartViewModel, child) {
                            if (cartViewModel.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    paymentRoute,
                                  ); // Navigate to payment screen
                                },
                                child: Container(
                                  width: 131,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: const Color(
                                      0xFF5A3E2C,
                                    ), // Darker brown for the button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Checkout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Provide space for the bottom navigation bar
                        const SizedBox(
                          height: 80,
                        ), // Adjusted height for the new bar size
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Navigation (CONSISTENT DESIGN)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomBottomNavigationBar(
                    currentIndex: 2, // Cart is active
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // --- Helper Widgets (Unchanged) ---
  // ------------------------------------------------------------------

  // Build a single cart item card (Functional)
  Widget _buildCartItemCard({
    required BuildContext context,
    required CartItem cartItem,
  }) {
    final cartViewModel = context.read<CartViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: 393 - 32,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDCCFB9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                cartItem.item.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 30,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Item Details (Title, Price, Quantity controls)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cartItem.item.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        '${cartItem.lineTotal.toStringAsFixed(0)} E£',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Quantity controls
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                // Decrement quantity
                                if (cartItem.quantity > 1) {
                                  cartViewModel.updateQuantity(
                                    cartItem.item.id,
                                    cartItem.quantity - 1,
                                  );
                                } else {
                                  // Remove item if quantity is 1
                                  cartViewModel.removeItem(cartItem.item.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${cartItem.item.name} removed from cart',
                                      ),
                                      backgroundColor: const Color(0xFF5A3E2C),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.remove,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cartItem.quantity.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                // Increment quantity
                                cartViewModel.updateQuantity(
                                  cartItem.item.id,
                                  cartItem.quantity + 1,
                                );
                              },
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Delete Icon
            InkWell(
              onTap: () {
                // Delete item
                cartViewModel.removeItem(cartItem.item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${cartItem.item.name} removed from cart'),
                    backgroundColor: const Color(0xFF5A3E2C),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(
                Icons.delete_outline,
                color: Colors.black,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a single row for the order summary
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: isTotal ? 18 : 16,
            fontFamily: 'SF Pro',
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: isTotal ? 18 : 16,
            fontFamily: 'SF Pro',
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
