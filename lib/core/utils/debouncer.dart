import 'dart:async';

class Debouncer {
  Debouncer({
    required this.duration,
    required this.callback,
  });

  final Duration duration;
  Timer? _timer;
  final Function() callback;

  void run() {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}
