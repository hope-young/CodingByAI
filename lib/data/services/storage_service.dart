// 💩 PoopTracker - Storage Service (using SharedPreferences)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:poop_tracker/data/models/poop_record.dart';

class StorageService {
  static const String _recordsKey = 'poop_records';
  static final Uuid _uuid = const Uuid();
  
  static SharedPreferences? _prefs;
  
  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  // 保存记录
  static Future<String> saveRecord(PoopRecord record) async {
    final prefs = await _preferences;
    final records = await getAllRecords();
    
    final newRecord = PoopRecord(
      id: _uuid.v4(),
      timestamp: record.timestamp,
      bristolType: record.bristolType,
      durationSeconds: record.durationSeconds,
      symptoms: record.symptoms,
      notes: record.notes,
      dietNotes: record.dietNotes,
      createdAt: DateTime.now(),
    );
    
    records.insert(0, newRecord);
    
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_recordsKey, jsonEncode(jsonList));
    
    return newRecord.id;
  }
  
  // 获取所有记录
  static Future<List<PoopRecord>> getAllRecords() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_recordsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => PoopRecord.fromJson(json)).toList();
  }
  
  // 按日期获取记录
  static Future<List<PoopRecord>> getRecordsByDate(DateTime date) async {
    final records = await getAllRecords();
    return records.where((record) {
      return record.timestamp.year == date.year &&
             record.timestamp.month == date.month &&
             record.timestamp.day == date.day;
    }).toList();
  }
  
  // 删除记录
  static Future<bool> deleteRecord(String id) async {
    final prefs = await _preferences;
    final records = await getAllRecords();
    
    final initialLength = records.length;
    records.removeWhere((r) => r.id == id);
    
    if (records.length < initialLength) {
      final jsonList = records.map((r) => r.toJson()).toList();
      await prefs.setString(_recordsKey, jsonEncode(jsonList));
      return true;
    }
    return false;
  }
  
  // 获取记录统计
  static Future<Map<String, dynamic>> getStats() async {
    final records = await getAllRecords();
    
    if (records.isEmpty) {
      return {
        'total': 0,
        'avgDuration': 0,
        'mostCommonType': 4,
      };
    }
    
    // 计算平均时长
    int totalDuration = 0;
    int durationCount = 0;
    Map<int, int> typeCount = {};
    
    for (var record in records) {
      if (record.durationSeconds != null) {
        totalDuration += record.durationSeconds!;
        durationCount++;
      }
      typeCount[record.bristolType] = (typeCount[record.bristolType] ?? 0) + 1;
    }
    
    // 找最常见的形态
    int mostCommonType = 4;
    int maxCount = 0;
    typeCount.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonType = type;
      }
    });
    
    return {
      'total': records.length,
      'avgDuration': durationCount > 0 ? totalDuration ~/ durationCount : 0,
      'mostCommonType': mostCommonType,
    };
  }
  
  // 获取连续记录天数
  static Future<int> getStreakDays() async {
    final records = await getAllRecords();
    if (records.isEmpty) return 0;
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    while (true) {
      final dayRecords = records.where((r) =>
        r.timestamp.year == checkDate.year &&
        r.timestamp.month == checkDate.month &&
        r.timestamp.day == checkDate.day
      ).toList();
      
      if (dayRecords.isNotEmpty) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
}
