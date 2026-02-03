import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/payment_vm.dart';
import '../../viewmodels/cart_vm.dart';
import '../../viewmodels/order_vm.dart';
import '../../viewmodels/menu_vm.dart';
import '../../data/models/order_item.dart';

class FavoritesScreen {
  static const String routeName = '/favourites';
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  static const String homeRoute = '/home';
  static const String cartRoute = '/cart';
  static const String reviewRoute = '/review';
  static const String favouritesRoute = '/favourites';
  static const String profileRoute = '/profile';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _showNewCardForm = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    // Restore status bar when leaving this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (_showNewCardForm) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    final cartViewModel = context.read<CartViewModel>();
    final menuViewModel = context.read<MenuViewModel>();
    final paymentViewModel = context.read<PaymentViewModel>();
    final orderViewModel = context.read<OrderViewModel>();

    if (cartViewModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: Color(0xFF5A3E2C),
        ),
      );
      return;
    }

    if (menuViewModel.currentShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No shop selected'),
          backgroundColor: Color(0xFF5A3E2C),
        ),
      );
      return;
    }

    final orderItems =
        cartViewModel.items.map((cartItem) {
          return OrderItem(
            item: cartItem.item,
            quantity: cartItem.quantity,
            note: cartItem.note,
            priceAtPurchase: cartItem.item.price,
          );
        }).toList();

    final order = await orderViewModel.createOrder(
      items: orderItems,
      shopId: menuViewModel.currentShop!.id,
      taxes: cartViewModel.taxes,
      serviceFees: cartViewModel.serviceFees,
    );

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderViewModel.errorMessage ?? 'Failed to create order',
          ),
          backgroundColor: const Color(0xFF5A3E2C),
        ),
      );
      return;
    }

    paymentViewModel.initializePayment(order);

    final success = await paymentViewModel.processPayment(
      paymentMethod: 'card',
      cardNumber: _showNewCardForm ? _cardNumberController.text.trim() : '4422',
      cardHolderName:
          _showNewCardForm ? _cardHolderController.text.trim() : 'Dima Sobhy',
      expiryDate: _showNewCardForm ? _expiryController.text.trim() : '12/25',
      cvv: _showNewCardForm ? _cvvController.text.trim() : '123',
    );

    if (!mounted) return;

    if (success) {
      cartViewModel.clearCart();
      Navigator.pushReplacementNamed(context, PaymentScreen.reviewRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentViewModel.errorMessage ?? 'Payment failed'),
          backgroundColor: const Color(0xFF5A3E2C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    final paymentViewModel = context.watch<PaymentViewModel>();

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
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          SizedBox(
                            width: 393,
                            height: 820,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFA78971),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -9,
                                  top: -8,
                                  child: Container(
                                    width: 402,
                                    padding: const EdgeInsets.only(
                                      top: 21,
                                      left: 16,
                                      right: 16,
                                      bottom: 19,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(
                                          height: 22,
                                          child: Text(
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
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
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
                                                        BorderRadius.circular(
                                                          4.30,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 21,
                                              height: 9,
                                              decoration: ShapeDecoration(
                                                color: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        2.50,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 18,
                                  top: 54,
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
                                        letterSpacing: -0.72,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 11,
                                  top: 72,
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
                                  left: 0,
                                  top: 123,
                                  child: Container(
                                    width: 393,
                                    height: 84,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDCCFB9),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 148,
                                  top: 129,
                                  child: const SizedBox(
                                    width: 98,
                                    height: 31,
                                    child: Text(
                                      'Payment',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontFamily: 'Abril Fatface',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.72,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 102,
                                  top: 132,
                                  child: Container(
                                    width: 34,
                                    height: 25,
                                    child: const Stack(),
                                  ),
                                ),
                                Positioned(
                                  left: 80,
                                  top: 169,
                                  child: const SizedBox(
                                    width: 233,
                                    height: 19,
                                    child: Text(
                                      'RAF Speciality Coffee: Drive thru pickup',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontFamily: 'Abril Fatface',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.39,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 27,
                                  top: 225,
                                  child: const SizedBox(
                                    width: 151,
                                    height: 24,
                                    child: Text(
                                      'Selected method:',
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
                                  left: 27,
                                  top: 261,
                                  child: Container(
                                    width: 326,
                                    height: 91,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFDCCFB9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(29),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 60,
                                  top: 281,
                                  child: SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.credit_card,
                                          size: 28,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _showNewCardForm
                                                ? 'New card'
                                                : 'Visa ending in 4422\nName: Dima Sobhy',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Abril Fatface',
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: -0.48,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 43,
                                  top: 285,
                                  child: Container(
                                    width: 34,
                                    height: 25,
                                    child: const Stack(),
                                  ),
                                ),
                                Positioned(
                                  left: 298,
                                  top: 310,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showNewCardForm = !_showNewCardForm;
                                      });
                                    },
                                    child: const SizedBox(
                                      width: 49,
                                      height: 14,
                                      child: Text(
                                        'Change',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Abril Fatface',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.39,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 27,
                                  top: 363,
                                  child: const SizedBox(
                                    width: 151,
                                    height: 24,
                                    child: Text(
                                      'Add new card',
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
                                if (_showNewCardForm) ...[
                                  Positioned(
                                    left: 27,
                                    top: 400,
                                    child: Container(
                                      width: 340,
                                      height: 197,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFDCCFB9),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            29,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 47,
                                    top: 417,
                                    child: Container(
                                      width: 294,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFA78971),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18.50,
                                          ),
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _cardNumberController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'Card number',
                                          hintStyle: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          if (value.replaceAll(' ', '').length <
                                              16) {
                                            return 'Invalid';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 47,
                                    top: 475,
                                    child: Container(
                                      width: 137,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFA78971),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18.50,
                                          ),
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _expiryController,
                                        keyboardType: TextInputType.text,
                                        decoration: const InputDecoration(
                                          hintText: 'MM/YY',
                                          hintStyle: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          if (!RegExp(
                                            r'^\d{2}/\d{2}$',
                                          ).hasMatch(value)) {
                                            return 'Invalid';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 196,
                                    top: 475,
                                    child: Container(
                                      width: 139,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFA78971),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18.50,
                                          ),
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _cvvController,
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          hintText: 'CVV',
                                          hintStyle: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          if (value.length < 3) {
                                            return 'Invalid';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 47,
                                    top: 532,
                                    child: Container(
                                      width: 294,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFA78971),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18.50,
                                          ),
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _cardHolderController,
                                        keyboardType: TextInputType.text,
                                        decoration: const InputDecoration(
                                          hintText: 'Cardholder name',
                                          hintStyle: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                                Positioned(
                                  left: 50,
                                  top: 630,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        PaymentScreen.cartRoute,
                                      );
                                    },
                                    child: Container(
                                      width: 115,
                                      padding: const EdgeInsets.all(12),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF5A3E2C),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFF2C2C2C),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Back to cart',
                                          style: TextStyle(
                                            color: Color(0xFFF5F5F5),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 208,
                                  top: 630,
                                  child: GestureDetector(
                                    onTap:
                                        paymentViewModel.isProcessing
                                            ? null
                                            : _handlePayment,
                                    child: Container(
                                      width: 115,
                                      padding: const EdgeInsets.all(12),
                                      decoration: ShapeDecoration(
                                        color:
                                            paymentViewModel.isProcessing
                                                ? const Color(
                                                  0xFF5A3E2C,
                                                ).withOpacity(0.6)
                                                : const Color(0xFF5A3E2C),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFF2C2C2C),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child:
                                            paymentViewModel.isProcessing
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
                                                : const Text(
                                                  'Pay',
                                                  style: TextStyle(
                                                    color: Color(0xFFF5F5F5),
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 132,
                                  top: 693,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        PaymentScreen.reviewRoute,
                                      );
                                    },
                                    child: Container(
                                      width: 115,
                                      padding: const EdgeInsets.all(12),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF5A3E2C),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFF2C2C2C),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Review',
                                          style: TextStyle(
                                            color: Color(0xFFF5F5F5),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 393,
                    height: 65,
                    decoration: const BoxDecoration(color: Color(0xFFDCCFB9)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PaymentScreen.homeRoute,
                            );
                          },
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PaymentScreen.favouritesRoute,
                            );
                          },
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PaymentScreen.cartRoute,
                            );
                          },
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PaymentScreen.profileRoute,
                            );
                          },
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                      ],
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
