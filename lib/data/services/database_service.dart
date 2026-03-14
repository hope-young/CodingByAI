// 💩 PoopTracker - Database Service
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poop_tracker/data/models/poop_record.dart';

class DatabaseService {
  static Isar? _isar;
  
  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;
    _isar = await _initDb();
    return _isar!;
  }
  
  static Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [PoopRecordSchema],
      directory: dir.path,
    );
  }
  
  // 保存记录
  static Future<int> saveRecord(PoopRecord record) async {
    final isar = await instance;
    return await isar.writeTxn(() async {
      return await isar.poopRecords.put(record);
    });
  }
  
  // 获取所有记录
  static Future<List<PoopRecord>> getAllRecords() async {
    final isar = await instance;
    return await isar.poopRecords.where().sortByTimestampDesc().findAll();
  }
  
  // 按日期获取记录
  static Future<List<PoopRecord>> getRecordsByDate(DateTime date) async {
    final isar = await instance;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await isar.poopRecords
        .where()
        .timestampBetween(startOfDay, endOfDay)
        .sortByTimestampDesc()
        .findAll();
  }
  
  // 删除记录
  static Future<bool> deleteRecord(int id) async {
    final isar = await instance;
    return await isar.writeTxn(() async {
      return await isar.poopRecords.delete(id);
    });
  }
  
  // 获取记录统计
  static Future<Map<String, dynamic>> getStats() async {
    final isar = await instance;
    final records = await isar.poopRecords.where().findAll();
    
    if (records.isEmpty) {
      return {
        'total': 0,
        'avgDuration': 0,
        'mostCommonType': 0,
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
    int mostCommonType = 1;
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
}
