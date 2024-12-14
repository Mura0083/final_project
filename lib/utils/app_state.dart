import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? _deviceId;
  String? _sessionId;

  String? get deviceId => _deviceId;
  String? get sessionId => _sessionId;

  void setDeviceId(String deviceId) {
    _deviceId = deviceId;
    notifyListeners();
  }

  void setSessionId(String sessionId) {
    _sessionId = sessionId;
    notifyListeners();
  }
}
