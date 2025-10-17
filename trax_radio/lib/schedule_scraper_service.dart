import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dj_service.dart';

class ScheduleScraperService {
  static const String _officialWebsiteUrl = 'https://trax-radio-uk.com/';
  
  /// Scrape the DJ schedule and images from the official Trax Radio UK website
  static Future<List<DJ>> scrapeSchedule() async {
    try {
      // First, get the main schedule from homepage
      final scheduleResponse = await http.get(
        Uri.parse(_officialWebsiteUrl),
        headers: {
          'User-Agent': 'TraxRadio/1.0 (Mobile App)',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 15));

      // Then get DJ images from the DJs page
      final djImagesResponse = await http.get(
        Uri.parse('https://trax-radio-uk.com/trax-djs/'),
        headers: {
          'User-Agent': 'TraxRadio/1.0 (Mobile App)',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 15));

      if (scheduleResponse.statusCode == 200) {
        final schedule = _parseScheduleFromHTML(scheduleResponse.body);
        
        // If we got DJ images page, enhance with images
        if (djImagesResponse.statusCode == 200) {
          final djImages = _extractDJImagesFromDJsPage(djImagesResponse.body);
          return _enhanceDJsWithImages(schedule, djImages);
        }
        
        return schedule;
      } else {
        throw Exception('Failed to fetch schedule: ${scheduleResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error scraping schedule: $e');
    }
  }

  /// Parse the HTML content to extract DJ schedule (without images)
  static List<DJ> _parseScheduleFromHTML(String html) {
    final List<DJ> djs = [];
    
    // Extract schedule data using regex patterns
    final schedulePattern = RegExp(
      r'#####\s*(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY|SUNDAY)S?\s*\n(.*?)(?=#####|\Z)',
      dotAll: true,
    );
    
    final timeSlotPattern = RegExp(r'(\d{2}:\d{2})\s+([A-Z\s]+(?:\s+\([^)]+\))?)');
    
    final matches = schedulePattern.allMatches(html);
    
    for (final match in matches) {
      final day = match.group(1)!.toLowerCase();
      final dayContent = match.group(2)!;
      
      // Find all time slots for this day
      final timeSlots = timeSlotPattern.allMatches(dayContent);
      
      for (final slot in timeSlots) {
        final time = slot.group(1)!;
        final djName = slot.group(2)!.trim();
        
        // Skip TBC (To Be Confirmed) slots
        if (djName.toUpperCase().contains('TBC')) continue;
        
        // Clean up DJ name
        String cleanDJName = _cleanDJName(djName);
        
        // Find existing DJ or create new one
        DJ? existingDJ = djs.firstWhere(
          (dj) => dj.name.toLowerCase() == cleanDJName.toLowerCase(),
          orElse: () => DJ(name: cleanDJName, schedule: [], bio: '', image: ''),
        );
        
        if (!djs.contains(existingDJ)) {
          djs.add(existingDJ);
        }
        
        // Add schedule entry
        final schedule = Schedule(
          day: _capitalizeDay(day),
          start: time,
          end: _calculateEndTime(time),
        );
        
        // Update the DJ's schedule (images will be added later)
        final djIndex = djs.indexWhere((dj) => dj.name == cleanDJName);
        if (djIndex != -1) {
          djs[djIndex] = DJ(
            name: cleanDJName,
            schedule: [...djs[djIndex].schedule, schedule],
            bio: _getDefaultBio(cleanDJName),
            image: '', // Will be populated from DJs page
          );
        }
      }
    }
    
    return djs;
  }

  /// Extract DJ images from the DJs page HTML
  static Map<String, String> _extractDJImagesFromDJsPage(String html) {
    final Map<String, String> djImages = {};
    
    // Look for DJ sections with images and names
    // Pattern: ## DJ NAME followed by image
    final djSectionPattern = RegExp(
      r'##\s*([A-Z\s]+)\s*\n(.*?)(?=##|\Z)',
      dotAll: true,
    );
    
    final imagePattern = RegExp(
      r'<img[^>]*src="([^"]+)"[^>]*(?:alt="([^"]+)")?[^>]*>',
      caseSensitive: false,
    );
    
    final sections = djSectionPattern.allMatches(html);
    
    for (final section in sections) {
      final djName = section.group(1)!.trim();
      final sectionContent = section.group(2)!;
      
      // Look for image in this section
      final imageMatch = imagePattern.firstMatch(sectionContent);
      if (imageMatch != null) {
        final imageUrl = imageMatch.group(1)!;
        
        // Skip generic images
        if (_isGenericImage(imageUrl, '')) continue;
        
        final cleanDJName = _cleanDJName(djName);
        djImages[cleanDJName.toLowerCase()] = _normalizeImageUrl(imageUrl);
      }
    }
    
    // Also look for standalone images with DJ names in context
    final standaloneImagePattern = RegExp(
      r'<img[^>]*src="([^"]+)"[^>]*(?:alt="([^"]+)")?[^>]*>',
      caseSensitive: false,
    );
    final standaloneImages = standaloneImagePattern.allMatches(html);
    
    for (final match in standaloneImages) {
      final imageUrl = match.group(1)!;
      final altText = match.group(2) ?? '';
      
      // Skip generic images
      if (_isGenericImage(imageUrl, altText)) continue;
      
      // Try to extract DJ name from context
      final djName = _extractDJNameFromContext(html, imageUrl, altText);
      if (djName.isNotEmpty) {
        djImages[djName.toLowerCase()] = _normalizeImageUrl(imageUrl);
      }
    }
    
    return djImages;
  }

  /// Enhance DJs with images from the DJs page
  static List<DJ> _enhanceDJsWithImages(List<DJ> djs, Map<String, String> djImages) {
    return djs.map((dj) {
      final djImage = _getDJImage(djImages, dj.name);
      return DJ(
        name: dj.name,
        schedule: dj.schedule,
        bio: dj.bio,
        image: djImage,
      );
    }).toList();
  }

  /// Check if image is generic (logo, background, etc.)
  static bool _isGenericImage(String url, String altText) {
    final genericPatterns = [
      'logo', 'banner', 'background', 'icon', 'header', 'footer',
      'social', 'facebook', 'twitter', 'instagram', 'mixcloud'
    ];
    
    final urlLower = url.toLowerCase();
    final altLower = altText.toLowerCase();
    
    return genericPatterns.any((pattern) => 
      urlLower.contains(pattern) || altLower.contains(pattern));
  }

  /// Extract DJ name from image context
  static String _extractDJNameFromContext(String html, String imageUrl, String altText) {
    // If alt text contains a DJ name, use it
    if (altText.isNotEmpty && !_isGenericImage(imageUrl, altText)) {
      return _cleanDJName(altText);
    }
    
    // Look for text near the image that might be a DJ name
    final imageIndex = html.indexOf(imageUrl);
    if (imageIndex == -1) return '';
    
    // Look for text in a reasonable range around the image
    final start = (imageIndex - 200).clamp(0, html.length);
    final end = (imageIndex + 200).clamp(0, html.length);
    final context = html.substring(start, end);
    
    // Look for DJ name patterns near the image
    final djNamePattern = RegExp(r'DJ\s+([A-Z\s]+)', caseSensitive: false);
    final match = djNamePattern.firstMatch(context);
    
    if (match != null) {
      return _cleanDJName(match.group(1)!);
    }
    
    return '';
  }

  /// Normalize image URL to absolute URL
  static String _normalizeImageUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    } else if (url.startsWith('//')) {
      return 'https:$url';
    } else if (url.startsWith('/')) {
      return 'https://trax-radio-uk.com$url';
    } else {
      return 'https://trax-radio-uk.com/$url';
    }
  }

  /// Get DJ image from scraped images map
  static String _getDJImage(Map<String, String> djImages, String djName) {
    final normalizedName = djName.toLowerCase();
    
    // Try exact match first
    if (djImages.containsKey(normalizedName)) {
      return djImages[normalizedName]!;
    }
    
    // Try partial matches
    for (final entry in djImages.entries) {
      if (entry.key.contains(normalizedName) || normalizedName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Return empty string if no image found
    return '';
  }
  
  /// Clean up DJ name from HTML content
  static String _cleanDJName(String name) {
    // Remove common suffixes and clean up
    return name
        .replaceAll(RegExp(r'\s+\([^)]+\)'), '') // Remove (USA), (BKFST) etc
        .replaceAll(RegExp(r'\s+BKFST\s*'), '') // Remove BKFST
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }
  
  /// Capitalize day name
  static String _capitalizeDay(String day) {
    return day.substring(0, 1).toUpperCase() + day.substring(1).toLowerCase();
  }
  
  /// Calculate end time (assume 1-hour slots unless specified)
  static String _calculateEndTime(String startTime) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    // Add 1 hour for most slots
    var endHour = hour + 1;
    var endMinute = minute;
    
    // Handle overnight (24:00 becomes 00:00)
    if (endHour >= 24) {
      endHour = 0;
    }
    
    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }
  
  /// Get default bio for DJs
  static String _getDefaultBio(String djName) {
    // Return a generic bio, could be enhanced with more specific info
    return 'Trax Radio UK DJ - Playing the best in electronic and dance music';
  }
  
  /// Test the scraper (for debugging)
  static Future<void> testScraper() async {
    try {
      print('Testing schedule scraper...');
      final djs = await scrapeSchedule();
      print('Found ${djs.length} DJs:');
      
      for (final dj in djs) {
        print('\n${dj.name}:');
        for (final schedule in dj.schedule) {
          print('  ${schedule.day}: ${schedule.start}-${schedule.end}');
        }
      }
    } catch (e) {
      print('Scraper test failed: $e');
    }
  }
}
