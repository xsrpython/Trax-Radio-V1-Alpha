import 'package:flutter/material.dart';
import 'widgets/device_panel.dart';

void main() {
  runApp(const TraxRadioBUTTApp());
}

class TraxRadioBUTTApp extends StatelessWidget {
  const TraxRadioBUTTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trax Radio BUTT App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const DevicePanel(),
      debugShowCheckedModeBanner: false,
    );
  }
}
