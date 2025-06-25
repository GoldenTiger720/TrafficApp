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
      body: Stack(
        children: [
          // Fullscreen Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient background if image doesn't exist
                return Container(
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
                );
              },
            ),
          ),
          
          // Semi-transparent overlay for better text readability
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          
          // Content Overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // App Title Section
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // App Title
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.traffic,
                              size: 48,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Traffic Light Monitor',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Real-time Traffic Management',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                shadows: const [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Progress Bar Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
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
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.grey[800]?.withOpacity(0.8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
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
                              
                              const SizedBox(height: 12),
                              
                              // Progress Percentage
                              Text(
                                '${(_progressAnimation.value * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black,
                                    ),
                                  ],
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
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}