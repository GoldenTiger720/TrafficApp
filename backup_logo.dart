import 'package:flutter/material.dart';
import 'dart:async';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _startSplashSequence();
  }

  void _startSplashSequence() {
    // Start progress animation
    _progressController.forward();
    
    // Navigate to main screen after animation completes
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.grey[900]!,
                Colors.black,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo Section
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Splash Image
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if image doesn't exist
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey[600]!,
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.traffic,
                                    size: 80,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Traffic Light\nMonitor',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App Title
                    const Text(
                      'Traffic Light Monitor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Real-time Traffic Management',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Progress Bar Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Progress Bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Progress Bar
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.grey[800],
                              ),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.lerp(
                                    Colors.green,
                                    Colors.amber,
                                    _progressAnimation.value,
                                  )!,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Progress Percentage
                            Text(
                              '${(_progressAnimation.value * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}