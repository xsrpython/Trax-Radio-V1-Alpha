# Widget Styling Reference - Trax Radio

## Current Widget Styling Specifications (Portrait Mode)

### All Widgets Common Properties:
- **Border Width**: 4px thick
- **Container Width**: `double.infinity` (full width)
- **Background**: `Colors.black.withOpacity(0.7)`
- **Border Radius**: 16px (metadata), 20px (next DJ), 16px (current DJ)

### 1. Metadata Display Widget
- **Border Color**: `Colors.blueAccent.withOpacity(0.5)`
- **Label**: "Track: "
- **Text Color**: `Colors.blueAccent`
- **Features**: Scrolling animation for long track names (>15 chars)
- **Live Badge**: Blue accent with "LIVE" text
- **Box Shadow**: Blue accent glow effect

### 2. Current DJ Widget  
- **Border Color**: `Colors.greenAccent.withOpacity(0.5)`
- **Label**: "Now Playing (UK): "
- **Text Color**: `Colors.greenAccent`
- **Features**: Scrolling animation for long DJ names (>8 chars)
- **Container Width**: Fixed 120px for DJ name area

### 3. Next DJ Widget
- **Border Color**: `Colors.orange.withOpacity(0.5)`
- **Label**: "Next: "
- **Text Color**: `Colors.orange`
- **Features**: Tooltip overflow handling, ellipsis for long text
- **Time Display**: "(UK)" suffix for time information

### 4. Turntable Widget
- **Border**: None (as requested)
- **Image Fit**: `BoxFit.contain` to prevent cropping
- **Container Width**: `widget.size * 1.2` to prevent overflow

## Key Implementation Details:

### Scrolling Animation Setup:
```dart
// Required for all scrolling widgets
with TickerProviderStateMixin

// Animation controller setup
_scrollController = AnimationController(
  duration: const Duration(seconds: 8),
  vsync: this,
);

// Auto-restart animation
_scrollController.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    _scrollController.reset();
    _scrollController.forward();
  }
});
```

### Monitoring Service Integration:
- All widgets use `MonitoringService` for overflow tracking
- Records overflow events with detailed metadata
- Helps identify UI issues in production

### Layout Structure:
- All widgets use `Row` with `mainAxisSize: MainAxisSize.max`
- Proper spacing with `SizedBox(width: 8)` between elements
- `Expanded` widgets for dynamic content areas
- `Flexible` widgets for text overflow handling

## File Dependencies:
- `lib/monitoring_service.dart` - Required for all widgets
- `lib/dj_service.dart` - Required for DJ widgets
- `lib/metadata_service.dart` - Required for metadata widget

## Notes:
- Styling is optimized for portrait mode
- All widgets maintain consistent visual hierarchy
- Overflow handling prevents UI breaking with long content
- Monitoring system provides production insights 