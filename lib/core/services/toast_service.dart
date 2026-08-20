import 'dart:async';
import 'package:flutter/foundation.dart';

class ToastNotification {
  final String id;
  final String message;
  final String? undoLabel;
  final VoidCallback? onUndo;
  final Duration duration;
  final DateTime createdAt;

  ToastNotification({
    required this.id,
    required this.message,
    this.undoLabel = 'Undo',
    this.onUndo,
    this.duration = const Duration(seconds: 4),
  }) : createdAt = DateTime.now();
}

class ToastService extends ChangeNotifier {
  static final ToastService _instance = ToastService._();
  static ToastService get instance => _instance;

  ToastService._();

  ToastNotification? _currentToast;
  Timer? _timer;

  ToastNotification? get currentToast => _currentToast;

  void show(
    String message, {
    String undoLabel = 'Undo',
    VoidCallback? onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    _timer?.cancel();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _currentToast = ToastNotification(
      id: id,
      message: message,
      undoLabel: undoLabel,
      onUndo: onUndo,
      duration: duration,
    );
    notifyListeners();

    _timer = Timer(duration, () {
      dismiss();
    });
  }

  void dismiss() {
    if (_currentToast != null) {
      _currentToast = null;
      _timer?.cancel();
      _timer = null;
      notifyListeners();
    }
  }

  void triggerUndo() {
    if (_currentToast?.onUndo != null) {
      final callback = _currentToast!.onUndo!;
      dismiss();
      callback();
    }
  }
}
