import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 393,
          height: 852,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFFA78971)),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 360,
                        height: 580,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/images/coffeehand.png.png"),
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 111,
                    top: 741,
                    child: SizedBox(
                      width: 171,
                      height: 42,
                      child: Text(
                        'BrewGo',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.60),
                          fontSize: 45,
                          fontFamily: 'Abril Fatface',
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 111,
                    top: 800,
                    child: SizedBox(
                      width: 171,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5A3E2C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 94,
                    top: 623,
                    child: Container(
                      width: 206,
                      height: 99,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/coffeebeans.png.png"),
                          fit: BoxFit.fill,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -9,
                    top: 0,
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
                        spacing: 154,
                        children: [
                          Expanded(
                            child: Container(
                              height: 22,
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  Text(
                                    '9:41',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black /* Labels-Primary */,
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
                          Expanded(
                            child: Container(
                              height: 22,
                              padding: const EdgeInsets.only(top: 1),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 7,
                                children: [
                                  Opacity(
                                    opacity: 0.35,
                                    child: Container(
                                      width: 25,
                                      height: 13,
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1,
                                            color: Colors.black /* Labels-Primary */,
                                          ),
                                          borderRadius: BorderRadius.circular(4.30),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 21,
                                    height: 9,
                                    decoration: ShapeDecoration(
                                      color: Colors.black /* Labels-Primary */,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2.50),
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

