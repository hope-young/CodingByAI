// 💩 PoopTracker - Constants
class AppConstants {
  // App Info
  static const String appName = 'PoopTracker';
  static const String appVersion = '1.0.0';
  
  // Bristol 大便分类
  static const List<String> bristolTypes = [
    '1', // 硬块状
    '2', // 腊肠状但硬块
    '3', // 腊肠状但有裂纹
    '4', // 腊肠状或蛇形
    '5', // 软团块状
    '6', // 糊状
    '7', // 水样状
  ];
  
  static const List<String> bristolDescriptions = [
    '硬块状（难以排出）',
    '腊肠状但硬块',
    '腊肠状但表面有裂纹',
    '腊肠状或蛇形（光滑柔软）',
    '软团块状（易于排出）',
    '糊状',
    '水样状（液体）',
  ];
  
  // 症状列表
  static const List<String> symptoms = [
    '疼痛',
    '出血',
    '便秘',
    '腹泻',
    '腹胀',
    '恶心',
  ];
  
  // 提醒时间选项
  static const List<String> reminderTimes = [
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
  ];
}
