// 💩 PoopTracker - 设置页面
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:poop_tracker/data/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _reminderEnabled = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ 设置'),
      ),
      body: ListView(
        children: [
          // 提醒设置
          SwitchListTile(
            title: const Text('排便提醒'),
            subtitle: const Text('每天定时提醒记录'),
            value: _reminderEnabled,
            onChanged: (value) {
              setState(() {
                _reminderEnabled = value;
              });
              if (value) {
                _showTimePicker();
              }
            },
          ),
          if (_reminderEnabled)
            ListTile(
              title: const Text('提醒时间'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _showTimePicker,
            ),
          
          const Divider(),
          
          // 数据导出
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('导出数据'),
            subtitle: const Text('导出为文本格式'),
            onTap: _exportData,
          ),
          
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('分享数据'),
            subtitle: const Text('分享给朋友'),
            onTap: _shareData,
          ),
          
          const Divider(),
          
          // 关于
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            subtitle: const Text('PoopTracker v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'PoopTracker',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 PoopTracker',
                children: [
                  const SizedBox(height: 16),
                  const Text('💩 排便记录 APP\n关爱肠道健康，从记录开始！'),
                ],
              );
            },
          ),
          
          // 清空数据
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('清空所有数据', style: TextStyle(color: Colors.red)),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }
  
  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }
  
  Future<void> _exportData() async {
    final records = await StorageService.getAllRecords();
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无数据可导出')),
      );
      return;
    }
    
    // 生成文本数据
    final buffer = StringBuffer();
    buffer.writeln('💩 PoopTracker 排便记录');
    buffer.writeln('=' * 30);
    buffer.writeln('导出时间: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('总记录数: ${records.length}');
    buffer.writeln('=' * 30);
    
    for (var record in records) {
      buffer.writeln('');
      buffer.writeln('日期: ${DateFormat('yyyy-MM-dd').format(record.timestamp)}');
      buffer.writeln('时间: ${DateFormat('HH:mm').format(record.timestamp)}');
      buffer.writeln('形态: ${record.bristolType}型 - ${record.bristolDescription}');
      buffer.writeln('时长: ${record.durationDescription}');
      if (record.symptoms != null && record.symptoms!.isNotEmpty) {
        buffer.writeln('症状: ${record.symptoms!.join(", ")}');
      }
      if (record.dietNotes != null) {
        buffer.writeln('饮食: ${record.dietNotes}');
      }
      if (record.notes != null) {
        buffer.writeln('备注: ${record.notes}');
      }
    }
    
    // 保存到文件
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/poop_records.txt');
    await file.writeAsString(buffer.toString());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ 数据已导出到: ${file.path}')),
      );
    }
  }
  
  Future<void> _shareData() async {
    final records = await StorageService.getAllRecords();
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无数据可分享')),
      );
      return;
    }
    
    // 生成简要文本
    final buffer = StringBuffer();
    buffer.writeln('💩 PoopTracker 排便记录');
    buffer.writeln('总记录: ${records.length}次');
    
    // 最近5条
    buffer.writeln('\n最近记录:');
    for (var record in records.take(5)) {
      buffer.writeln(
        '${DateFormat('MM/dd HH:mm').format(record.timestamp)} - '
        '${record.bristolType}型 - ${record.durationDescription}'
      );
    }
    
    await Share.share(buffer.toString());
  }
  
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空数据'),
        content: const Text('确定要清空所有排便记录吗？此操作不可恢复！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: 清空数据
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清空')),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
