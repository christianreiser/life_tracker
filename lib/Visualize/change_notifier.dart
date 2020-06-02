import 'package:flutter/foundation.dart';

// ChangeNotifier adds listening capabilities to mySchedule
class MySchedule with ChangeNotifier {
  String _selectedAttribute1;// = 'Productivity'; // TODO set default value here

  String get selectedAttribute1 => _selectedAttribute1;

  set selectedAttribute1(String newValue) {
    _selectedAttribute1 = newValue;
    notifyListeners();
  }

  String _selectedAttribute2; // = 'Mood'; // TODO set default value here

  String get selectedAttribute2 => _selectedAttribute2;

  set selectedAttribute2(String newValue) {
    _selectedAttribute2 = newValue;
    notifyListeners();
  }
}