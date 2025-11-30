import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import '../models/catholic_reflection_model.dart';

/// Reflection list item with metadata
class ReflectionListItem {
  final String title;
  final String url;
  final String? imageUrl;
  final DateTime? date;

  ReflectionListItem({
    required this.title,
    required this.url,
    this.imageUrl,
    this.date,
  });
}

/// Service to scrape daily Catholic reflections from catholic-daily-reflections.com
class CatholicReflectionScraperService {
  final http.Client _client;
  static const String baseUrl = 'https://catholic-daily-reflections.com';

  CatholicReflectionScraperService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch list of available reflections from the main page
  Future<List<ReflectionListItem>> fetchReflectionList() async {
    try {
      print('Fetching reflection list from $baseUrl/daily-reflections/');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/daily-reflections/'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          'Sec-Fetch-Dest': 'document',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-Site': 'none',
          'Cache-Control': 'max-age=0',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('Failed to fetch reflection list: ${response.statusCode}');
        return [];
      }

      final document = parser.parse(response.body);
      final reflectionItems = <ReflectionListItem>[];

      // Find all reflection article cards
      final articles = document.querySelectorAll('article.elementor-post');

      for (var article in articles) {
        try {
          // Extract title and URL
          final titleElement = article.querySelector('h2.elementor-post__title a');
          if (titleElement == null) continue;

          final title = _cleanText(titleElement.text);
          final url = titleElement.attributes['href'];
          if (url == null || url.isEmpty) continue;

          // Extract image URL
          final imageElement = article.querySelector('img.attachment-full');
          final imageUrl = imageElement?.attributes['src'];

          // Try to extract date from URL or content
          DateTime? date;
          final dateMatch = RegExp(r'/(\d{4})/(\d{2})/(\d{2})/').firstMatch(url);
          if (dateMatch != null) {
            try {
              date = DateTime(
                int.parse(dateMatch.group(1)!),
                int.parse(dateMatch.group(2)!),
                int.parse(dateMatch.group(3)!),
              );
            } catch (e) {
              print('Failed to parse date from URL: $url');
            }
          }

          reflectionItems.add(ReflectionListItem(
            title: title,
            url: url,
            imageUrl: imageUrl,
            date: date,
          ));
        } catch (e) {
          print('Error parsing reflection item: $e');
        }
      }

      print('Found ${reflectionItems.length} reflections');
      return reflectionItems;
    } catch (e) {
      print('Error fetching reflection list: $e');
      return [];
    }
  }

  /// Fetch today's reflection (first one from the list)
  Future<DailyReflection?> fetchTodayReflection() async {
    try {
      final reflectionList = await fetchReflectionList();
      if (reflectionList.isEmpty) {
        print('No reflections available');
        return null;
      }

      // Get the first (most recent) reflection
      final todayItem = reflectionList.first;
      return await fetchReflectionByUrl(todayItem.url, todayItem.imageUrl);
    } catch (e) {
      print('Error fetching today\'s reflection: $e');
      return null;
    }
  }

  /// Fetch reflection for a specific date
  Future<DailyReflection?> fetchReflectionByDate(DateTime date) async {
    try {
      print('Fetching reflection for ${DateFormat('yyyy-MM-dd').format(date)}');
      
      // Get the reflection list and find one matching the date
      final reflectionList = await fetchReflectionList();
      
      // Try to find a reflection for the specific date
      final matchingReflection = reflectionList.firstWhere(
        (item) {
          if (item.date == null) return false;
          return item.date!.year == date.year &&
                 item.date!.month == date.month &&
                 item.date!.day == date.day;
        },
        orElse: () => reflectionList.isNotEmpty ? reflectionList.first : 
          ReflectionListItem(title: '', url: ''),
      );

      if (matchingReflection.url.isEmpty) {
        print('No reflection found for date: ${DateFormat('yyyy-MM-dd').format(date)}');
        return null;
      }

      return await fetchReflectionByUrl(matchingReflection.url, matchingReflection.imageUrl);
    } catch (e) {
      print('Error fetching reflection: $e');
      return null;
    }
  }

  /// Fetch recent reflections (last 7 from the list)
  Future<List<DailyReflection>> fetchRecentReflections() async {
    final reflections = <DailyReflection>[];
    
    try {
      final reflectionList = await fetchReflectionList();
      
      // Take up to 7 most recent reflections
      final recentItems = reflectionList.take(7).toList();
      
      for (var item in recentItems) {
        try {
          final reflection = await fetchReflectionByUrl(item.url, item.imageUrl);
          if (reflection != null) {
            reflections.add(reflection);
          }
        } catch (e) {
          print('Error fetching reflection from ${item.url}: $e');
        }
      }
    } catch (e) {
      print('Error fetching recent reflections: $e');
    }

    return reflections;
  }

  /// Fetch a specific reflection by its URL
  Future<DailyReflection?> fetchReflectionByUrl(String url, String? imageUrl) async {
    try {
      print('Fetching reflection from: $url');
      
      // Add a small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
      
      final response = await _client.get(
        Uri.parse(url),
       
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('Failed to fetch reflection: ${response.statusCode}');
        return null;
      }

      final document = parser.parse(response.body);

      // Extract title
      final titleElement = document.querySelector('h1.entry-title') ??
          document.querySelector('h1.elementor-heading-title') ??
          document.querySelector('h1');

      if (titleElement == null) {
        print('Could not find title element');
        return null;
      }

      final title = _cleanText(titleElement.text);
      print('Extracted title: $title');

      // Extract Bible verse and reference
      String? bibleVerse;
      String? verseReference;
      
      final verseContainer = document.querySelector('.verse-container') ??
          document.querySelector('[class*="verse"]');
      
      if (verseContainer != null) {
        // Try to find verse text
        final verseText = verseContainer.querySelector('p')?.text ?? verseContainer.text;
        
        // Try to extract reference (usually in format: Book Chapter:Verse)
        final refMatch = RegExp(r'([A-Za-z\s]+\d+:\d+[-\d]*)').firstMatch(verseText);
        if (refMatch != null) {
          verseReference = refMatch.group(1)?.trim();
          // Remove reference from verse text
          bibleVerse = verseText.replaceFirst(RegExp(r'[A-Za-z\s]+\d+:\d+[-\d]*'), '').trim();
        } else {
          bibleVerse = _cleanText(verseText);
        }
      }

      // Extract main content/reflection
      final contentElements = document.querySelectorAll('.entry-content p, article p');
      if (contentElements.isEmpty) {
        print('Could not find content elements');
        return null;
      }

      // Combine paragraphs into content, excluding verse and navigation elements
      final contentParts = <String>[];
      for (var element in contentElements) {
        final text = _cleanText(element.text);
        
        // Skip empty, very short, or navigation text
        if (text.isEmpty || 
            text.length < 20 || 
            text.contains('Previous') ||
            text.contains('Next') ||
            text.contains('Share') ||
            element.parent?.classes.contains('verse-container') == true) {
          continue;
        }

        contentParts.add(text);
      }

      if (contentParts.isEmpty) {
        print('No valid content found');
        return null;
      }

      final content = contentParts.join('\n\n');

      // Extract prayer (usually in a dedicated section or last paragraph)
      String prayer = _extractPrayer(document, contentParts);

      // Extract date from URL if possible
      DateTime date = DateTime.now();
      final dateMatch = RegExp(r'/(\d{4})/(\d{2})/(\d{2})/').firstMatch(url);
      if (dateMatch != null) {
        try {
          date = DateTime(
            int.parse(dateMatch.group(1)!),
            int.parse(dateMatch.group(2)!),
            int.parse(dateMatch.group(3)!),
          );
        } catch (e) {
          print('Failed to parse date from URL: $url');
        }
      }

      return DailyReflection(
        date: date,
        title: title,
        content: content,
        bibleVerse: bibleVerse,
        verseReference: verseReference,
        prayer: prayer,
        author: 'Catholic Daily Reflections',
        fetchedAt: DateTime.now(),
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error fetching reflection from $url: $e');
      return null;
    }
  }

  /// Extract prayer from document
  String _extractPrayer(Document document, List<String> contentParts) {
    // Try to find a prayer section
    final prayerElement = document.querySelector('.prayer') ??
        document.querySelector('[class*="prayer"]') ??
        document.querySelector('p:last-of-type');

    if (prayerElement != null) {
      final prayerText = _cleanText(prayerElement.text);
      if (prayerText.length > 20) {
        return prayerText;
      }
    }

    // If no dedicated prayer section, use the last content paragraph if it looks like a prayer
    if (contentParts.isNotEmpty) {
      final lastPart = contentParts.last;
      if (lastPart.contains('Lord') || 
          lastPart.contains('God') || 
          lastPart.contains('Jesus') ||
          lastPart.contains('Amen')) {
        return lastPart;
      }
    }

    // Generate a simple prayer
    return 'Lord Jesus, help me to reflect on Your word today and draw closer to You. Guide me in following Your will and living according to Your love. Amen.';
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
