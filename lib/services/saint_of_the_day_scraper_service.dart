import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import '../models/saint_of_the_day_model.dart';

/// Scraper for Franciscan Media - Saint of the Day
class SaintOfTheDayScraperService {
  static const String _baseUrl = 'https://www.franciscanmedia.org';
  static const String _listUrl = '$_baseUrl/saint-of-the-day/';
  
  final http.Client _client;

  SaintOfTheDayScraperService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch today's saint + next few days
  Future<List<SaintOfTheDay>> fetchUpcomingSaints({int daysAhead = 7}) async {
    try {
      final response = await _client.get(
        Uri.parse(_listUrl),
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        print('Failed to load saint list: ${response.statusCode}');
        return [];
      }

      final document = parser.parse(response.body);
      final saints = <SaintOfTheDay>[];

      // 1. Today's Featured Saint (big card at top)
      final featured = _extractFeaturedSaint(document);
      if (featured != null) saints.add(featured);

      // 2. Upcoming saints in the grid
      final upcoming = _extractUpcomingSaints(document, limit: daysAhead);
      saints.addAll(upcoming);

      // 3. Fetch full reflection for today only (optional, fast)
      if (saints.isNotEmpty) {
        final today = saints.firstWhere(
          (s) => _isSameDay(s.date, DateTime.now()),
          orElse: () => saints.first,
        );
        await _fetchFullReflection(today);
      }

      return saints;
    } catch (e) {
      print('Error scraping saints: $e');
      return [];
    }
  }

  /// Fetch today's saint specifically
  Future<SaintOfTheDay?> fetchTodaySaint() async {
    final saints = await fetchUpcomingSaints(daysAhead: 1);
    if (saints.isEmpty) return null;
    
    final today = saints.firstWhere(
      (s) => _isSameDay(s.date, DateTime.now()),
      orElse: () => saints.first,
    );
    
    return today;
  }

  /// Fetch saint for a specific date
  Future<SaintOfTheDay?> fetchSaintByDate(DateTime date) async {
    // For simplicity, fetch upcoming and filter
    // In production, you might want to construct a URL for specific dates
    final saints = await fetchUpcomingSaints(daysAhead: 30);
    
    try {
      return saints.firstWhere(
        (s) => _isSameDay(s.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract the main featured saint (today)
  SaintOfTheDay? _extractFeaturedSaint(Document doc) {
    final card = doc.querySelector('article.elementor-post');
    if (card == null) return null;

    final link = card.querySelector('h2 a, h3 a, .elementor-post__title a');
    final title = link?.text.trim() ?? 'Saint of the Day';
    final url = link?.attributes['href'];
    if (url == null) return null;

    final img = card.querySelector('img');
    final imageUrl = img?.attributes['src'] ?? img?.attributes['data-lazy-src'] ?? '';

    // Extract date from text like "November 30"
    final dateText = card.querySelector('.elementor-post-info__item--type-date')?.text.trim();
    final date = _parseSaintDate(dateText ?? '');

    // Extract feast type if available
    final feastTypeEl = card.querySelector('.elementor-post-info__item--type-terms');
    String? feastType;
    if (feastTypeEl != null && feastTypeEl.text.trim() != 'Saint of the Day') {
      feastType = feastTypeEl.text.trim();
    }

    return SaintOfTheDay(
      date: date ?? DateTime.now(),
      name: title,
      feastType: feastType,
      imageUrl: imageUrl.startsWith('http') ? imageUrl : '$_baseUrl$imageUrl',
      reflectionUrl: url.startsWith('http') ? url : '$_baseUrl$url',
      summary: card.querySelector('.elementor-post__excerpt')?.text.trim(),
    );
  }

  /// Extract upcoming saints from the grid
  List<SaintOfTheDay> _extractUpcomingSaints(Document doc, {int limit = 7}) {
    final saints = <SaintOfTheDay>[];
    final items = doc.querySelectorAll('.elementor-posts-container article');

    for (var item in items) {
      if (saints.length >= limit) break;

      final link = item.querySelector('a');
      final title = link?.text.trim();
      final url = link?.attributes['href'];
      if (title == null || url == null) continue;

      final img = item.querySelector('img');
      final imgSrc = img?.attributes['src'] ?? img?.attributes['data-lazy-src'] ?? '';

      final dateEl = item.querySelector('.elementor-post-info__item--type-date');
      final dateText = dateEl?.text.trim() ?? '';
      final date = _parseSaintDate(dateText);

      if (date != null && !_isSameDay(date, DateTime.now())) {
        saints.add(SaintOfTheDay(
          date: date,
          name: title,
          imageUrl: imgSrc.startsWith('http') ? imgSrc : '$_baseUrl$imgSrc',
          reflectionUrl: url.startsWith('http') ? url : '$_baseUrl$url',
        ));
      }
    }

    return saints;
  }

  /// Fetch full reflection content from saint's page
  Future<void> _fetchFullReflection(SaintOfTheDay saint) async {
    try {
      final response = await _client.get(
        Uri.parse(saint.reflectionUrl),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return;

      final doc = parser.parse(response.body);

      // Extract the main content area
      final contentWidget = doc.querySelector('.elementor-widget-theme-post-content');
      
      // Extract Saint's Story section
      String? storyContent;
      final storyHeading = contentWidget?.querySelectorAll('h4')
          .firstWhere(
            (h) => h.text.toLowerCase().contains('story'),
            orElse: () => Element.tag('div'),
          );
      
      if (storyHeading?.localName == 'h4') {
        final storyParas = <String>[];
        var currentElement = storyHeading!.nextElementSibling;
        
        while (currentElement != null && currentElement.localName == 'p') {
          final text = currentElement.text.trim();
          if (text.isNotEmpty) {
            storyParas.add(text);
          }
          currentElement = currentElement.nextElementSibling;
          
          // Stop if we hit another heading
          if (currentElement?.localName == 'h4' || currentElement?.localName == 'hr') {
            break;
          }
        }
        
        if (storyParas.isNotEmpty) {
          storyContent = storyParas.join('\n\n');
        }
      }

      // Extract Reflection section
      String? reflectionContent;
      final reflectionHeading = contentWidget?.querySelectorAll('h4')
          .firstWhere(
            (h) => h.text.toLowerCase().contains('reflection'),
            orElse: () => Element.tag('div'),
          );
      
      if (reflectionHeading?.localName == 'h4') {
        final reflectionParas = <String>[];
        var currentElement = reflectionHeading!.nextElementSibling;
        
        while (currentElement != null && currentElement.localName == 'p') {
          final text = currentElement.text.trim();
          if (text.isNotEmpty) {
            reflectionParas.add(text);
          }
          currentElement = currentElement.nextElementSibling;
          
          // Stop if we hit another heading
          if (currentElement?.localName == 'h4' || currentElement?.localName == 'hr') {
            break;
          }
        }
        
        if (reflectionParas.isNotEmpty) {
          reflectionContent = reflectionParas.join('\n\n');
        }
      }

      // Combine story and reflection for fullReflection field
      final fullContent = <String>[];
      if (storyContent != null) {
        fullContent.add('SAINT\'S STORY\n\n$storyContent');
      }
      if (reflectionContent != null) {
        fullContent.add('REFLECTION\n\n$reflectionContent');
      }

      // Extract Patron Saint information
      String? patronSaintOf;
      final patronHeading = contentWidget?.querySelectorAll('h4')
          .firstWhere(
            (h) => h.text.toLowerCase().contains('patron saint'),
            orElse: () => Element.tag('div'),
          );
      
      if (patronHeading?.localName == 'h4') {
        var currentElement = patronHeading!.nextElementSibling;
        
        if (currentElement?.localName == 'p') {
          var text = currentElement!.text.trim();
          if (text.isNotEmpty) {
            // Clean up the text - split into individual patron items
            // The text often comes as one long string like "FishermenGreeceRussiaScotland"
            // Try to split by capital letters for better readability
            
            // First, remove everything after "---" (ads/extra content)
            if (text.contains('---')) {
              text = text.split('---').first.trim();
            }
            
            // Remove "Read more" links and similar artifacts
            text = text.replaceAll(RegExp(r'Read more.*$', multiLine: true), '');
            text = text.replaceAll(RegExp(r'Advent with.*$', multiLine: true), '');
            text = text.replaceAll(RegExp(r'\n\n.*$', multiLine: true), ''); // Remove extra lines
            text = text.trim();
            
            // Try to add spaces between capitalized words for better readability
            if (text.isNotEmpty && !text.contains(' ')) {
              // If no spaces, it's likely concatenated words
              text = text.replaceAllMapped(
                RegExp(r'([a-z])([A-Z])'),
                (match) => '${match.group(1)}, ${match.group(2)}',
              );
            }
            
            if (text.isNotEmpty) {
              patronSaintOf = text;
            }
          }
        }
      }

      // Extract Bible verse if present
      String? bibleVerse;
      String? verseRef;
      
      // Look for quoted text patterns in the story
      if (storyContent != null) {
        final verseMatch = RegExp(r'"([^"]+)"\s*\(([^)]+)\)').firstMatch(storyContent);
        if (verseMatch != null) {
          bibleVerse = verseMatch.group(1);
          verseRef = verseMatch.group(2);
        }
      }

      // Generate a prayer
      final saintFirstName = saint.name.replaceAll('Saint ', '').split(' ').first;
      String prayer = 'Lord Jesus, through the prayers of $saintFirstName, help me to follow You more closely today. Amen.';
      
      // Look for an actual prayer in the content (some saint pages have them)
      final prayerEl = doc.querySelector('.prayer, [class*="prayer"]');
      if (prayerEl != null) {
        var prayerText = prayerEl.text.trim();
        // Filter out ads and promotional content
        if (prayerText.isNotEmpty && 
            !prayerText.toLowerCase().contains('advent with') &&
            !prayerText.toLowerCase().contains('read more') &&
            prayerText.length > 20) {
          prayer = prayerText;
        }
      }

      // Update the saint object
      saint.fullReflection = fullContent.isNotEmpty ? fullContent.join('\n\n---\n\n') : null;
      saint.bibleVerse = bibleVerse;
      saint.verseReference = verseRef;
      saint.prayer = patronSaintOf != null 
          ? 'PATRON SAINT OF\n\n$patronSaintOf\n\n---\n\n$prayer'
          : prayer;

    } catch (e) {
      print('Failed to load full reflection: $e');
    }
  }

  /// Parse date from text like "November 30" → DateTime(this year)
  DateTime? _parseSaintDate(String text) {
    if (text.isEmpty) return null;
    try {
      final now = DateTime.now();
      final parsed = DateFormat('MMMM d').parseLoose(text);
      return DateTime(now.year, parsed.month, parsed.day);
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void dispose() => _client.close();
}
