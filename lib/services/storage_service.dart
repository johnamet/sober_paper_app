import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StorageService extends ChangeNotifier {
  static late StorageService instance;
  static const _soberBox = 'sober_days';
  static const _messagesBox = 'messages';

  late Box _sober;
  late Box _messages;

  StorageService._internal();

  static Future<void> init() async {
    final service = StorageService._internal();
    service._sober = await Hive.openBox(_soberBox);
    service._messages = await Hive.openBox(_messagesBox);
    instance = service;
  }

  List<String> get soberDates => _sober.keys.cast<String>().toList();

  bool isSober(DateTime date) => _sober.containsKey(_key(date));

  void toggleSober(DateTime date) {
    final key = _key(date);
    if (_sober.containsKey(key)) {
      _sober.delete(key);
    } else {
      _sober.put(key, true);
    }
    notifyListeners();
  }

  List<Map> get messages => _messages.values.cast<Map>().toList();

  void addMessage(Map m) {
    _messages.add(m);
    notifyListeners();
  }

  String _key(DateTime d) => d.toIso8601String().split('T').first;
}
