import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Faster initial fade-in
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation immediately
    _animationController.forward();
    
    // Navigate to main app after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RadioHomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 2000), // Much longer, smoother transition
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final iconSize = isLandscape ? 120.0 : 200.0;
    final titleFontSize = isLandscape ? 24.0 : 32.0;
    final versionFontSize = isLandscape ? 14.0 : 18.0;
    final developerFontSize = isLandscape ? 14.0 : 18.0;
    final spacing = isLandscape ? 20.0 : 50.0;
    final bottomSpacing = isLandscape ? 40.0 : 120.0;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon - Centered and prominent
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(iconSize * 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: iconSize * 0.2,
                      spreadRadius: iconSize * 0.05,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(iconSize * 0.15),
                  child: Image.asset(
                    'assets/traxicon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(iconSize * 0.15),
                        ),
                        child: Icon(
                          Icons.music_note,
                          size: iconSize * 0.5,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              SizedBox(height: spacing),
              
              // App Title
              Text(
                'Trax Radio UK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: isLandscape ? 1 : 2,
                ),
              ),
              
              SizedBox(height: spacing * 0.3),
              
              // Version
              Text(
                'V1.0.0 Alpha',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: versionFontSize,
                  fontWeight: FontWeight.w300,
                ),
              ),
              
              SizedBox(height: bottomSpacing),
              
              // Developer Info
              Text(
                'Developed by DJXSR',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: developerFontSize,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 