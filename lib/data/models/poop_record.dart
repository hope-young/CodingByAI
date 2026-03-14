// 💩 PoopRecord - Data Model (JSON)
import 'dart:convert';

class PoopRecord {
  final String id;
  final DateTime timestamp;
  final int bristolType;
  final int? durationSeconds;
  final List<String>? symptoms;
  final String? notes;
  final String? dietNotes;
  final DateTime createdAt;
  
  PoopRecord({
    required this.id,
    required this.timestamp,
    required this.bristolType,
    this.durationSeconds,
    this.symptoms,
    this.notes,
    this.dietNotes,
    required this.createdAt,
  });
  
  // 获取形态描述
  String get bristolDescription {
    const descriptions = [
      '硬块状（难以排出）',
      '腊肠状但硬块',
      '腊肠状但表面有裂纹',
      '腊肠状或蛇形（光滑柔软）',
      '软团块状（易于排出）',
      '糊状',
      '水样状（液体）',
    ];
    return descriptions[bristolType - 1];
  }
  
  // 获取时长描述
  String get durationDescription {
    if (durationSeconds == null) return '未计时';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    if (minutes > 0) {
      return '$minutes分$seconds秒';
    }
    return '$seconds秒';
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'bristolType': bristolType,
    'durationSeconds': durationSeconds,
    'symptoms': symptoms,
    'notes': notes,
    'dietNotes': dietNotes,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory PoopRecord.fromJson(Map<String, dynamic> json) => PoopRecord(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    bristolType: json['bristolType'],
    durationSeconds: json['durationSeconds'],
    symptoms: json['symptoms'] != null ? List<String>.from(json['symptoms']) : null,
    notes: json['notes'],
    dietNotes: json['dietNotes'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
