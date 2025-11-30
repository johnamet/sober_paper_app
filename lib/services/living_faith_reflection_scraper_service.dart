import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import '../models/catholic_reflection_model.dart';

/// Service to scrape daily Catholic reflections from livingfaith.com
class LivingFaithReflectionScraperService {
  final http.Client _client;
  static const String baseUrl = 'https://www.livingfaith.com';

  LivingFaithReflectionScraperService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch reflection for today
  Future<DailyReflection?> fetchTodayReflection() async {
    return await fetchReflectionByDate(DateTime.now());
  }

  /// Fetch reflection for a specific date
  Future<DailyReflection?> fetchReflectionByDate(DateTime date) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final url = '$baseUrl/daily-devotion/$dateString';
      
      print('Fetching Living Faith reflection from: $url');
      
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Connection': 'keep-alive',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('Failed to fetch reflection: ${response.statusCode}');
        return null;
      }

      final document = parser.parse(response.body);

      // Extract date (wel_content_05)
      final dateElement = document.querySelector('.wel_content_05');
      String? dateText;
      if (dateElement != null) {
        dateText = _cleanText(dateElement.text);
        print('Extracted date: $dateText');
      }

      // Extract liturgical season (wel_content_05_new)
      String? liturgicalSeason;
      final seasonElement = document.querySelector('.wel_content_05_new');
      if (seasonElement != null) {
        liturgicalSeason = _cleanText(seasonElement.text);
        print('Extracted liturgical season: $liturgicalSeason');
      }

      // Extract title (wel_content_06)
      final titleElement = document.querySelector('.wel_content_06');
      if (titleElement == null) {
        print('Could not find title element');
        return null;
      }
      
      String title = _cleanText(titleElement.text);
      
      // Add liturgical season to title if available
      if (liturgicalSeason != null && liturgicalSeason.isNotEmpty) {
        title = '$title - $liturgicalSeason';
      }
      
      print('Extracted title: $title');

      // Extract Bible verse and reference (wel_content_08)
      // There are typically two divs with this class - both contain verse info
      String? bibleVerse;
      String? verseReference;
      
      final verseElements = document.querySelectorAll('.wel_content_08');
      if (verseElements.isNotEmpty) {
        // Combine the verse text from both elements
        final verseText = verseElements
            .map((e) => _cleanText(e.text))
            .where((text) => text.isNotEmpty)
            .join(' ');
        
        print('Raw verse text: $verseText');
        
        // Try to extract reference (usually at the end, like "Luke 21:36")
        final refMatch = RegExp(r'([A-Za-z\s]+\d+:\d+[-\d]*)$').firstMatch(verseText);
        if (refMatch != null) {
          verseReference = refMatch.group(1)?.trim();
          // Remove reference from verse text to get just the verse
          bibleVerse = verseText.substring(0, refMatch.start).trim();
        } else {
          bibleVerse = verseText;
        }
        
        print('Extracted verse: $bibleVerse');
        print('Extracted reference: $verseReference');
      }

      // Extract main content paragraphs
      // Get all <p> tags that are part of the reflection content
      final allParagraphs = document.querySelectorAll('p');
      final contentParts = <String>[];
      
      bool foundContent = false;
      for (var element in allParagraphs) {
        final text = _cleanText(element.text);
        
        // Skip empty or very short paragraphs
        if (text.isEmpty || text.length < 20) continue;
        
        // Skip navigation, sharing, and metadata paragraphs
        if (text.contains('Previous') ||
            text.contains('Next') ||
            text.contains('Share') ||
            text.contains('Follow us') ||
            text.contains('Subscribe') ||
            text.contains('Copyright') ||
            element.classes.contains('wel_content_09')) {
          continue;
        }
        
        // Check if this paragraph is part of the main content
        // (comes after the title and before the author)
        if (!foundContent && 
            (text.contains('Jesus') || text.contains('God') || text.length > 50)) {
          foundContent = true;
        }
        
        if (foundContent) {
          // Stop if we hit the author section
          if (element.classes.contains('wel_content_09')) break;
          
          contentParts.add(text);
        }
      }

      if (contentParts.isEmpty) {
        print('No valid content found');
        return null;
      }

      final content = contentParts.join('\n\n');
      print('Extracted content: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');

      // Extract prayer (wel_content_07)
      String? prayer;
      final prayerElement = document.querySelector('.wel_content_07');
      if (prayerElement != null) {
        // Prayer is usually in <i> tag within wel_content_07
        final prayerItalic = prayerElement.querySelector('i');
        prayer = _cleanText(prayerItalic?.text ?? prayerElement.text);
        print('Extracted prayer: $prayer');
      }

      // Extract author (wel_content_09)
      String? author;
      final authorElement = document.querySelector('.wel_content_09 a');
      if (authorElement != null) {
        author = _cleanText(authorElement.text);
        // Remove leading "- " if present
        if (author.startsWith('- ')) {
          author = author.substring(2);
        }
        print('Extracted author: $author');
      }

      // Extract image URL
      String? imageUrl;
      final imageElement = document.querySelector('img#myImg');
      if (imageElement != null) {
        imageUrl = imageElement.attributes['src'];
        print('Extracted image URL: $imageUrl');
      }

      // Extract mass readings
      // Look for text with the ✚ separator character
      String? massReadings;
      final readingsElements = document.querySelectorAll('i');
      for (var element in readingsElements) {
        final text = element.text;
        if (text.contains('✚')) {
          massReadings = _cleanText(text);
          print('Extracted mass readings: $massReadings');
          break;
        }
      }

      // Add mass readings to content if found
      String finalContent = content;
      if (massReadings != null && massReadings.isNotEmpty) {
        finalContent = '$content\n\nMass Readings: $massReadings';
      }

      return DailyReflection(
        date: date,
        title: title,
        content: finalContent,
        bibleVerse: bibleVerse,
        verseReference: verseReference,
        prayer: prayer ?? 'Lord, guide me in your love and help me live according to your will. Amen.',
        author: author ?? 'Living Faith',
        fetchedAt: DateTime.now(),
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error fetching Living Faith reflection: $e');
      return null;
    }
  }

  /// Fetch recent reflections (last 7 days)
  Future<List<DailyReflection>> fetchRecentReflections() async {
    final reflections = <DailyReflection>[];
    
    try {
      final now = DateTime.now();
      
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        
        try {
          // Add a small delay to avoid rate limiting
          if (i > 0) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
          
          final reflection = await fetchReflectionByDate(date);
          if (reflection != null) {
            reflections.add(reflection);
          }
        } catch (e) {
          print('Error fetching reflection for ${DateFormat('yyyy-MM-dd').format(date)}: $e');
        }
      }
    } catch (e) {
      print('Error fetching recent reflections: $e');
    }

    return reflections;
  }

  /// Clean and normalize text
  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\n\r]+'), '\n')
        .trim();
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}
