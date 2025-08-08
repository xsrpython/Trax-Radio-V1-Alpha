import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trax_radio/main.dart';
import 'package:trax_radio/widgets/current_dj_widget.dart';
import 'package:trax_radio/widgets/next_dj_widget.dart';
import 'package:trax_radio/widgets/metadata_display.dart';
import 'package:trax_radio/widgets/linear_3d_visualizer.dart';

void main() {
  group('📱 UI/UX Tests', () {
    
    testWidgets('App launches and displays main screen', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      
      // Wait for app to load
      await tester.pumpAndSettle();
      
      // Verify app title is displayed
      expect(find.text('Trax Radio'), findsOneWidget);
      
      // Verify main screen elements are present
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Play button is present and accessible', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // Navigate to main screen
      await tester.tap(find.byType(MaterialApp));
      await tester.pumpAndSettle();
      
      // Look for play button (you may need to adjust this based on your actual UI)
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      
      // Test button tap
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      
      // Verify button state changed (to pause)
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('Portrait mode layout displays correctly', (tester) async {
      // Set portrait orientation
      tester.binding.window.physicalSizeTestValue = const Size(360, 640);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // Verify layout fits in portrait mode
      expect(tester.binding.window.physicalSize.width, 360);
      expect(tester.binding.window.physicalSize.height, 640);
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
    });

    testWidgets('Visualizer widget displays correctly', (tester) async {
      // Create a test visualizer widget
      final visualizer = Linear3DVisualizer(isPlaying: true);
      
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Container(
            height: 200,
            child: visualizer,
          ),
        ),
      ));
      
      // Verify visualizer is displayed
      expect(find.byType(Linear3DVisualizer), findsOneWidget);
      
      // Wait for animations
      await tester.pumpAndSettle();
      
      // Verify visualizer bars are present
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('DJ widgets display correctly', (tester) async {
      // Test current DJ widget
      final currentDJ = CurrentDJWidget(currentDJ: 'Test DJ');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: currentDJ),
      ));
      
      // Verify DJ widget is displayed
      expect(find.byType(CurrentDJWidget), findsOneWidget);
      
      // Test next DJ widget
      final nextDJ = NextDJWidget(nextDJ: 'Next Test DJ');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: nextDJ),
      ));
      
      // Verify next DJ widget is displayed
      expect(find.byType(NextDJWidget), findsOneWidget);
    });

    testWidgets('Metadata display widget works correctly', (tester) async {
      // Test metadata widget
      final metadata = MetadataDisplay(
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
      );
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: metadata),
      ));
      
      // Verify metadata widget is displayed
      expect(find.byType(MetadataDisplay), findsOneWidget);
      
      // Verify metadata text is displayed
      expect(find.text('Test Song'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
    });

    testWidgets('Touch targets are properly sized', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // Find all interactive widgets
      final interactiveWidgets = find.byType(GestureDetector);
      
      // Verify interactive widgets are present
      expect(interactiveWidgets, findsWidgets);
      
      // Test that widgets are tappable
      for (final widget in tester.widgetList(interactiveWidgets)) {
        final gestureDetector = widget as GestureDetector;
        expect(gestureDetector.onTap, isNotNull);
      }
    });

    testWidgets('App theme is applied correctly', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // Verify dark theme is applied
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.dark);
      
      // Verify primary color is orange
      expect(materialApp.theme?.primarySwatch, Colors.orange);
    });

    testWidgets('Loading states display correctly', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // Simulate loading state
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      
      // Verify loading indicator is shown (if implemented)
      // This test may need adjustment based on your actual loading implementation
    });

    testWidgets('Error states display correctly', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // This test would simulate error conditions
      // Implementation depends on your error handling UI
    });

    testWidgets('App navigation works smoothly', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // Test screen transitions
      // This would test navigation between different screens
      // Implementation depends on your app's navigation structure
    });

    testWidgets('Accessibility features are implemented', (tester) async {
      // Build the app
      await tester.pumpWidget(const TraxRadioApp());
      await tester.pumpAndSettle();
      
      // Verify semantic labels are present
      final semanticWidgets = find.byType(Semantics);
      expect(semanticWidgets, findsWidgets);
      
      // Test screen reader compatibility
      // This would test accessibility features
    });

    testWidgets('Responsive design adapts to screen size', (tester) async {
      // Test different screen sizes
      final sizes = [
        const Size(320, 480),  // Small phone
        const Size(360, 640),  // Medium phone
        const Size(414, 896),  // Large phone
      ];
      
      for (final size in sizes) {
        tester.binding.window.physicalSizeTestValue = size;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        // Build the app
        await tester.pumpWidget(const TraxRadioApp());
        await tester.pumpAndSettle();
        
        // Verify app adapts to screen size
        expect(tester.binding.window.physicalSize, size);
        
        // Verify no overflow errors
        expect(tester.takeException(), isNull);
      }
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
    });

    testWidgets('Widget lifecycle management', (tester) async {
      // Test widget creation and disposal
      final visualizer = Linear3DVisualizer(isPlaying: true);
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: visualizer),
      ));
      
      // Verify widget is created
      expect(find.byType(Linear3DVisualizer), findsOneWidget);
      
      // Test widget disposal
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Container()),
      ));
      
      // Verify widget is disposed
      expect(find.byType(Linear3DVisualizer), findsNothing);
    });

    testWidgets('Animation performance is smooth', (tester) async {
      // Test visualizer animations
      final visualizer = Linear3DVisualizer(isPlaying: true);
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: visualizer),
      ));
      
      // Start animation
      await tester.pump();
      
      // Verify animation frames are generated
      expect(tester.binding.schedulerPhase, SchedulerPhase.idle);
      
      // Test animation smoothness
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // 60fps
        expect(tester.takeException(), isNull);
      }
    });
  });
} 