import 'package:flutter/material.dart';

class CounterState extends ChangeNotifier {
  int _counter = 5;

  int get counter => _counter;

  void increment() {
    _counter = _counter + 10;
    notifyListeners();
  }
}
