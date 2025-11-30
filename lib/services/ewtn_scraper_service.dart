import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import '../models/catholic_reading_model.dart';

class EWTNScraperService {
  static const String _baseUrl = 'https://www.ewtn.com/catholicism/daily-readings';

  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36',
  };

  Future<DailyCatholicReading?> fetchReadingsForDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final url = '$_baseUrl/$dateStr';

    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 30));

          // print(response.body);

      if (response.statusCode != 200) {
        if (response.statusCode == 404) return null;
        throw Exception('HTTP ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      final dateText = _extractDate(document);


      final feast = _extractFeast(document);
      final readings = _extractReadings(document);

      return DailyCatholicReading(
        date: dateText ?? DateFormat('EEEE, MMMM d, yyyy').format(date),
        feast: feast,
        readings: readings,
        fetchDate: DateTime.now(),
        massVideoUrl: null,
      );
    } catch (e) {
      print('EWTN scrape error: $e');
      rethrow;
    }
  }

  Future<DailyCatholicReading?> fetchTodayReadings() =>
      fetchReadingsForDate(DateTime.now());

  // ──────────────────────────────────────────────────
  // 1. Date
  // ──────────────────────────────────────────────────
  String? _extractDate(Document doc) {
    final el = doc.querySelector('div.readings__copy-container div.readings__title-container h2') ??
      doc.querySelector('div.readings__title-container h2') ??
      doc.querySelector('h2.readings__title');
    return el?.text.trim();
  }

  // ──────────────────────────────────────────────────
  // 2. Feast / Memorial (if any)
  // ──────────────────────────────────────────────────
  String? _extractFeast(Document doc) {
    // Usually a <p> or <div> right after the date h2
    final dateH2 = doc.querySelector('div.readings__title-container h2');
    if (dateH2 == null) return null;

    var next = dateH2.nextElementSibling;
    while (next != null) {
      if (next.localName == 'h2' || next.localName == 'h3') break; // hit first reading
      final text = next.text.trim();
      if (text.length < 300 &&
          (text.contains('Memorial') ||
              text.contains('Feast') ||
              text.contains('Solemnity') ||
              text.contains('Saint') ||
              text.contains('St.'))) {
        return text;
      }
      next = next.nextElementSibling;
    }
    return null;
  }

  // ──────────────────────────────────────────────────
  // 3. Readings
  // ──────────────────────────────────────────────────
  List<Reading> _extractReadings(Document doc) {
    final List<Reading> readings = [];

    // Find all reading groups within the readings__selection div
    final selectionDiv = doc.querySelector('div.readings__selection.current');
    if (selectionDiv == null) return readings;

    final readingGroups = selectionDiv.querySelectorAll('div.readings__group');
    
    for (var group in readingGroups) {
      // Get the title (h2) that precedes this group
      var titleEl = group.previousElementSibling;
      while (titleEl != null && !titleEl.classes.contains('readings__title-container')) {
        titleEl = titleEl.previousElementSibling;
      }
      
      final type = titleEl?.querySelector('h2.readings__title')?.text.trim() ?? '';
      if (!_isValidReadingType(type)) continue;

      // Get the reference from within the group
      final refEl = group.querySelector('div.readings__reference-container h3.readings__reference');
      final reference = refEl?.text.trim() ?? '';

      // Get the passage from within the group
      final passageDiv = group.querySelector('div.readings__passage-container div.readings__passage');
      final text = _extractPassageText(passageDiv);

      if (reference.isNotEmpty && text.isNotEmpty) {
        readings.add(Reading(
          type: type,
          reference: reference,
          text: text,
        ));
      }
    }

    return readings;
  }
   
  Element? _findAncestor(Element? element, String tagName, String className) {
    var current = element?.parent;
    while (current != null) {
      if (current.localName == tagName && current.classes.contains(className)) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  bool _isValidReadingType(String text) {
    final valid = [
      'First Reading',
      'Responsorial Psalm',
      'Second Reading',
      'Alleluia',
      'Gospel Acclamation',
      'Gospel',
    ];
    return valid.any((t) => text.contains(t)) || text == 'Reading';
  }

  String _extractPassageText(Element? passageDiv) {
    if (passageDiv == null || !passageDiv.classes.contains('readings__passage')) {
      return '';
    }

    final verses = passageDiv.querySelectorAll('.readings__verse-container');
    if (verses.isEmpty) {
      return passageDiv.text.trim();
    }

    final lines = <String>[];
    for (var v in verses) {
      final verseNum = v.querySelector('.readings__verse')?.text ?? '';
      final verseText = v.querySelector('.readings__text')?.text ?? v.text;
      if (verseText.isNotEmpty) {
        lines.add(verseNum.isNotEmpty ? '$verseNum $verseText' : verseText);
      }
    }
    return lines.join('\n');
  }

  // ──────────────────────────────────────────────────
  // Mass Video (simple reliable fallback)
  // ──────────────────────────────────────────────────
  Future<String?> fetchMassVideoUrl(DateTime date) async {
    final dateStr = DateFormat('MMMM d, yyyy').format(date);
    return 'https://www.youtube.com/results?search_query=ewtn+daily+mass+$dateStr';
  }
}