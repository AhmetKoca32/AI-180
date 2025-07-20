import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _healthyOpacity = 0.0;
  double _happyOpacity = 0.0;
  double _logoOpacity = 0.0;
  double _logoScale = 0.8;

  @override
  void initState() {
    super.initState();
    // Healthy Skin animasyonu
    Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _healthyOpacity = 1.0;
      });
      // Happy Life animasyonu
      Timer(const Duration(milliseconds: 900), () {
        setState(() {
          _happyOpacity = 1.0;
        });
        // Logo animasyonu
        Timer(const Duration(milliseconds: 900), () {
          setState(() {
            _logoOpacity = 1.0;
            _logoScale = 1.0;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/splash_bg.jpg',
            ), // Arka plan görseli
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Yazılar üstte
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  AnimatedOpacity(
                    opacity: _healthyOpacity,
                    duration: const Duration(milliseconds: 700),
                    child: Text(
                      'Healthy Skin',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: _happyOpacity,
                    duration: const Duration(milliseconds: 700),
                    child: Text(
                      'Happy Life',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Logo tam ortada
            Center(
              child: AnimatedOpacity(
                opacity: _logoOpacity,
                duration: const Duration(milliseconds: 900),
                child: AnimatedScale(
                  scale: _logoScale,
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  child: Image.asset(
                    'assets/images/logo.png', // Logo dosyan
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
