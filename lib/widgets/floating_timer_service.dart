// 💩 PoopTracker - Floating Timer Service
// 悬浮窗功能需要用户授权，使用简单实现

import 'dart:async';

class FloatingTimerService {
  static final FloatingTimerService instance = FloatingTimerService._();
  FloatingTimerService._();
  
  bool _isRunning = false;
  DateTime? _startTime;
  Timer? _updateTimer;
  int _elapsedSeconds = 0;
  
  // 计时状态
  bool get isRunning => _isRunning;
  int get elapsedSeconds => _elapsedSeconds;
  
  // 获取格式化的时间
  String get formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  // 开始计时
  Future<void> startTimer(DateTime startTime) async {
    _startTime = startTime;
    _isRunning = true;
    _elapsedSeconds = 0;
    
    // 启动定时更新
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
      }
    });
  }
  
  // 停止计时
  Future<void> stopTimer() async {
    _isRunning = false;
    _startTime = null;
    _elapsedSeconds = 0;
    
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}
