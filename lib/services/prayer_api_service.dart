import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/entities/prayer.dart';

/// Service for fetching Catholic prayers from openPrayers GitHub repository
class PrayerApiService {
  static const String _baseUrl = 'https://raw.githubusercontent.com/erickouassi/openPrayers/main';
  
  /// Fetch all basic prayers from openPrayers
  Future<List<Prayer>> fetchBasicPrayers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/basic_prayers.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return _parsePrayers(jsonData);
      } else {
        throw Exception('Failed to load prayers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching prayers: $e');
    }
  }

  /// Fetch Stations of the Cross prayers
  Future<List<Prayer>> fetchStationsOfTheCross() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stations_of_the_cross.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return _parsePrayers(jsonData);
      } else {
        throw Exception('Failed to load stations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stations: $e');
    }
  }

  /// Parse JSON data into Prayer entities
  List<Prayer> _parsePrayers(List<dynamic> jsonData) {
    return jsonData.map((json) {
      // Note: The API has a typo - "tilte" instead of "title"
      final String title = json['tilte'] ?? json['title'] ?? 'Untitled Prayer';
      final String prayerText = json['prayerText'] ?? '';
      final String id = json['id']?.toString() ?? '';

      // Determine category based on prayer title
      PrayerCategory category = _determineCategory(title, prayerText);

      return Prayer(
        id: id,
        title: title,
        category: category,
        content: _cleanPrayerText(prayerText),
        latinVersion: null, // openPrayers doesn't have Latin versions
        notes: null,
        order: int.tryParse(id) ?? 0,
      );
    }).toList();
  }

  /// Determine prayer category based on title and content
  PrayerCategory _determineCategory(String title, String text) {
    final lowerTitle = title.toLowerCase();
    final lowerText = text.toLowerCase();

    if (lowerTitle.contains('morning') || lowerTitle.contains('offering')) {
      return PrayerCategory.morning;
    } else if (lowerTitle.contains('evening') || lowerTitle.contains('examen')) {
      return PrayerCategory.evening;
    } else if (lowerTitle.contains('rosary') || lowerTitle.contains('hail mary') || 
               lowerTitle.contains('salve') || lowerTitle.contains('memorare')) {
      return PrayerCategory.rosary;
    } else if (lowerTitle.contains('contrition') || lowerTitle.contains('mercy') ||
               lowerText.contains('sorry for my sins')) {
      return PrayerCategory.emergency; // Good for moments of struggle
    } else if (lowerTitle.contains('gloria') || lowerTitle.contains('creed') || 
               lowerTitle.contains('angelus') || lowerTitle.contains('tantum')) {
      return PrayerCategory.liturgy;
    }
    
    return PrayerCategory.morning; // Default for general prayers
  }

  /// Clean prayer text by removing excessive line breaks and formatting
  String _cleanPrayerText(String text) {
    return text
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n\n\n', '\n\n')
        .trim();
  }

  /// Get daily prayers suitable for morning, midday, and evening
  Future<List<Prayer>> getDailyPrayers() async {
    final allPrayers = await fetchBasicPrayers();
    
    // Select prayers appropriate for daily reflection
    final dailyPrayers = <Prayer>[];
    
    // Morning prayers
    dailyPrayers.addAll(allPrayers.where((p) => 
      p.category == PrayerCategory.morning
    ).take(2));
    
    // Add some general prayers for midday
    dailyPrayers.addAll(allPrayers.where((p) => 
      p.title.contains('Act of') || p.title.contains('Guardian Angel')
    ).take(2));
    
    // Evening prayers
    dailyPrayers.addAll(allPrayers.where((p) => 
      p.category == PrayerCategory.evening
    ).take(1));
    
    // If we don't have enough variety, add more
    if (dailyPrayers.length < 5) {
      dailyPrayers.addAll(allPrayers.where((p) => 
        !dailyPrayers.contains(p) && 
        (p.title.contains('Jesus') || p.title.contains('Mary'))
      ).take(5 - dailyPrayers.length));
    }
    
    return dailyPrayers;
  }

  /// Get a prayer suitable for emergency/panic situations
  Future<List<Prayer>> getEmergencyPrayers() async {
    final allPrayers = await fetchBasicPrayers();
    
    return allPrayers.where((p) => 
      p.category == PrayerCategory.emergency ||
      p.title.toLowerCase().contains('mercy') ||
      p.title.toLowerCase().contains('contrition') ||
      p.title.toLowerCase().contains('jesus')
    ).toList();
  }

  /// Get prayers by category
  Future<List<Prayer>> getPrayersByCategory(PrayerCategory category) async {
    final allPrayers = await fetchBasicPrayers();
    return allPrayers.where((p) => p.category == category).toList();
  }
}
