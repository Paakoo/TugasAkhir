import 'package:flutter/foundation.dart';

class PresenceProvider extends ChangeNotifier {
  static final PresenceProvider _instance = PresenceProvider._internal();
  factory PresenceProvider() => _instance;
  PresenceProvider._internal();

  bool _isProcessing = false;
  bool _isVerified = false;
  String? _errorMessage;

  bool get isProcessing => _isProcessing;
  bool get isVerified => _isVerified;
  String? get errorMessage => _errorMessage;

  void startProcessing() {
    _isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    _isProcessing = false;
    notifyListeners();
  }

  void setVerified(bool value) {
    _isVerified = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void reset() {
    _isProcessing = false;
    _isVerified = false;
    _errorMessage = null;
    notifyListeners();
  }
}

final presenceProvider = PresenceProvider();