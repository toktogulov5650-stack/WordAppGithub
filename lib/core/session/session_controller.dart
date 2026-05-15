import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionControllerProvider = ChangeNotifierProvider<SessionController>((
  ref,
) {
  return SessionController();
});

class SessionController extends ChangeNotifier {
  bool _isUnauthorized = false;

  bool get isUnauthorized => _isUnauthorized;

  void markUnauthorized() {
    if (_isUnauthorized) {
      return;
    }
    _isUnauthorized = true;
    notifyListeners();
  }

  void reset() {
    if (!_isUnauthorized) {
      return;
    }
    _isUnauthorized = false;
    notifyListeners();
  }
}
