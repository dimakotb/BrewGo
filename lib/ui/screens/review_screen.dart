import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/review_vm.dart';
import '../../viewmodels/payment_vm.dart';
import '../../viewmodels/order_vm.dart';
import '../../viewmodels/menu_vm.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  static const String homeRoute = '/home';
  static const String cartRoute = '/cart';
  static const String favouritesRoute = '/favourites';
  static const String profileRoute = '/profile';

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _commentController.dispose();
    // Restore status bar when leaving this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Color(0xFF5A3E2C),
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to submit a review'),
          backgroundColor: Color(0xFF5A3E2C),
        ),
      );
      return;
    }

    final paymentViewModel = context.read<PaymentViewModel>();
    final orderViewModel = context.read<OrderViewModel>();
    final menuViewModel = context.read<MenuViewModel>();
    final reviewViewModel = context.read<ReviewViewModel>();

    final order = paymentViewModel.currentOrder ?? orderViewModel.currentOrder;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No order found'),
          backgroundColor: Color(0xFF5A3E2C),
        ),
      );
      return;
    }

    final shopId = menuViewModel.currentShop?.id ?? '';
    if (shopId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No shop found'),
          backgroundColor: Color(0xFF5A3E2C),
        ),
      );
      return;
    }

    final success = await reviewViewModel.createReview(
      shopId: shopId,
      userId: userId,
      orderId: order.id,
      rating: _rating.toDouble(),
      comment: _commentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully'),
          backgroundColor: Color(0xFF5A3E2C),
        ),
      );
      Navigator.pushReplacementNamed(context, ReviewScreen.homeRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reviewViewModel.errorMessage ?? 'Failed to submit review',
          ),
          backgroundColor: const Color(0xFF5A3E2C),
        ),
      );
    }
  }

  void _handleSaveDraft() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final paymentViewModel = context.read<PaymentViewModel>();
    final orderViewModel = context.read<OrderViewModel>();
    final menuViewModel = context.read<MenuViewModel>();
    final reviewViewModel = context.read<ReviewViewModel>();

    final order = paymentViewModel.currentOrder ?? orderViewModel.currentOrder;
    if (order == null) return;

    final shopId = menuViewModel.currentShop?.id ?? '';
    if (shopId.isEmpty) return;

    reviewViewModel.saveDraft(
      shopId: shopId,
      userId: userId,
      orderId: order.id,
      rating: _rating.toDouble(),
      comment: _commentController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved'),
        backgroundColor: Color(0xFF5A3E2C),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    final paymentViewModel = context.watch<PaymentViewModel>();
    final orderViewModel = context.watch<OrderViewModel>();
    final reviewViewModel = context.watch<ReviewViewModel>();

    final order = paymentViewModel.currentOrder ?? orderViewModel.currentOrder;
    final firstItem =
        order?.items.isNotEmpty == true ? order!.items.first : null;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 393,
          height: 852,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFFA78971)),
                  ),
                ),
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 852 + MediaQuery.of(context).padding.top,
                      width: 393,
                      child: Stack(
                        children: [
                          Positioned(
                            top: MediaQuery.of(context).padding.top - 9,
                            left: -9,
                            child: Container(
                              width: 402,
                              padding: const EdgeInsets.only(
                                top: 21,
                                left: 16,
                                right: 16,
                                bottom: 19,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 22,
                                      padding: const EdgeInsets.only(top: 2),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '9:41',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontFamily: 'SF Pro',
                                              fontWeight: FontWeight.w600,
                                              height: 1.29,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 22,
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity: 0.35,
                                          child: Container(
                                            width: 25,
                                            height: 13,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.30),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Container(
                                          width: 21,
                                          height: 9,
                                          decoration: ShapeDecoration(
                                            color: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.50),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 18,
                            top: 53 + MediaQuery.of(context).padding.top,
                            child: const SizedBox(
                              width: 92,
                              height: 36,
                              child: Text(
                                'BrewGo',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontFamily: 'Abril Fatface',
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                  letterSpacing: -0.72,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 11,
                            top: 71 + MediaQuery.of(context).padding.top,
                            child: Container(
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
                          ),
                          Positioned(
                            left: 100,
                            top: 156 + MediaQuery.of(context).padding.top,
                            child: const SizedBox(
                              width: 194,
                              height: 31,
                              child: Text(
                                'Add a Review',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontFamily: 'Abril Fatface',
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                  letterSpacing: -0.96,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 43,
                            top: 710 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: _handleSaveDraft,
                              child: Container(
                                width: 131,
                                padding: const EdgeInsets.all(12),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF5A3E2C),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Save draft',
                                      style: TextStyle(
                                        color: Color(0xFFF5F5F5),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 219,
                            top: 710 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap:
                                  reviewViewModel.isLoading
                                      ? null
                                      : _handleSubmit,
                              child: Container(
                                width: 131,
                                padding: const EdgeInsets.all(12),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color:
                                      reviewViewModel.isLoading
                                          ? const Color(
                                            0xFF5A3E2C,
                                          ).withOpacity(0.6)
                                          : const Color(0xFF5A3E2C),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    reviewViewModel.isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFF5F5F5),
                                                ),
                                          ),
                                        )
                                        : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Submit review',
                                              style: TextStyle(
                                                color: Color(0xFFF5F5F5),
                                                fontSize: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                height: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 800 + MediaQuery.of(context).padding.top,
                            child: Container(
                              width: 393,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCCFB9),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 34,
                            top: 808 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ReviewScreen.homeRoute,
                                );
                              },
                              child: Container(
                                width: 33,
                                height: 33,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 133,
                            top: 811 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ReviewScreen.favouritesRoute,
                                );
                              },
                              child: Container(
                                width: 30,
                                height: 31,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(),
                                child: const Center(
                                  child: Icon(
                                    Icons.favorite_border,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 228,
                            top: 808 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ReviewScreen.cartRoute,
                                );
                              },
                              child: Container(
                                width: 31,
                                height: 32,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(),
                                child: const Center(
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 330,
                            top: 806 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ReviewScreen.profileRoute,
                                );
                              },
                              child: Container(
                                width: 33,
                                height: 33,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            top: 206 + MediaQuery.of(context).padding.top,
                            child: Container(
                              width: 346,
                              height: 97,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFDCCFB9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                          if (firstItem != null) ...[
                            Positioned(
                              left: 36,
                              top: 225 + MediaQuery.of(context).padding.top,
                              child: Image.asset(
                                firstItem.item.imageUrl,
                                width: 39,
                                height: 59,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 39,
                                    height: 59,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              left: 95,
                              top: 221 + MediaQuery.of(context).padding.top,
                              child: SizedBox(
                                width: 132,
                                height: 23,
                                child: Text(
                                  firstItem.item.name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Abril Fatface',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.48,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 95,
                              top: 255 + MediaQuery.of(context).padding.top,
                              child: SizedBox(
                                width: 48,
                                height: 23,
                                child: Text(
                                  '${firstItem.item.price.toStringAsFixed(0)} E£',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Abril Fatface',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.48,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          Positioned(
                            left: 28,
                            top: 322 + MediaQuery.of(context).padding.top,
                            child: const SizedBox(
                              width: 80,
                              height: 22,
                              child: Text(
                                'Rating:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Abril Fatface',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.60,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 104,
                            top: 326 + MediaQuery.of(context).padding.top,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _rating = index + 1;
                                    });
                                  },
                                  child: Icon(
                                    index < _rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 20,
                                    color:
                                        index < _rating
                                            ? Colors.amber
                                            : Colors.black,
                                  ),
                                );
                              }),
                            ),
                          ),
                          Positioned(
                            left: 31,
                            top: 378 + MediaQuery.of(context).padding.top,
                            child: const SizedBox(
                              width: 220,
                              height: 22,
                              child: Text(
                                'What did you like?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Abril Fatface',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.60,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 28,
                            top: 420 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: () => _toggleTag('Taste'),
                              child: Container(
                                width: 80,
                                height: 38,
                                decoration: ShapeDecoration(
                                  color:
                                      _selectedTags.contains('Taste')
                                          ? const Color(0xFF5A3E2C)
                                          : const Color(0xFFDCCFB9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Taste',
                                    style: TextStyle(
                                      color:
                                          _selectedTags.contains('Taste')
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Abril Fatface',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 152,
                            top: 420 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: () => _toggleTag('Service'),
                              child: Container(
                                width: 90,
                                height: 38,
                                decoration: ShapeDecoration(
                                  color:
                                      _selectedTags.contains('Service')
                                          ? const Color(0xFF5A3E2C)
                                          : const Color(0xFFDCCFB9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Service',
                                    style: TextStyle(
                                      color:
                                          _selectedTags.contains('Service')
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Abril Fatface',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 282,
                            top: 420 + MediaQuery.of(context).padding.top,
                            child: GestureDetector(
                              onTap: () => _toggleTag('Quality'),
                              child: Container(
                                width: 100,
                                height: 38,
                                decoration: ShapeDecoration(
                                  color:
                                      _selectedTags.contains('Quality')
                                          ? const Color(0xFF5A3E2C)
                                          : const Color(0xFFDCCFB9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Quality',
                                    style: TextStyle(
                                      color:
                                          _selectedTags.contains('Quality')
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Abril Fatface',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 28,
                            top: 495 + MediaQuery.of(context).padding.top,
                            child: const SizedBox(
                              width: 120,
                              height: 22,
                              child: Text(
                                'Your Review:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Abril Fatface',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.60,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            top: 530 + MediaQuery.of(context).padding.top,
                            child: Container(
                              width: 351,
                              height: 147,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFDCCFB9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: TextField(
                                controller: _commentController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  hintText: 'Tell us about your experience',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF484444),
                                    fontSize: 13,
                                    fontFamily: 'Abhaya Libre',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.39,
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Abhaya Libre',
                                ),
                              ),
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
        ),
      ),
    );
  }
}
