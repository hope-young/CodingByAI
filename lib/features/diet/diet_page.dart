// 💩 PoopTracker - 饮食记录页面
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poop_tracker/core/theme/app_theme.dart';
import 'package:poop_tracker/data/models/poop_record.dart';
import 'package:poop_tracker/data/services/storage_service.dart';

class DietPage extends ConsumerStatefulWidget {
  const DietPage({super.key});

  @override
  ConsumerState<DietPage> createState() => _DietPageState();
}

class _DietPageState extends ConsumerState<DietPage> {
  final TextEditingController _dietController = TextEditingController();
  List<PoopRecord> _todayRecords = [];
  
  // 常见食物选项
  final List<String> _commonFoods = [
    '🍎 苹果',
    '🍌 香蕉',
    '🥛 牛奶',
    '☕ 咖啡',
    '🍞 面包',
    '🍚 米饭',
    '🥗 蔬菜',
    '🍗 肉类',
    '🌶️ 辛辣',
    '🍺 啤酒',
    '☕ 茶',
    '🧊 冷饮',
  ];
  
  final List<String> _selectedFoods = [];
  
  @override
  void initState() {
    super.initState();
    _loadTodayRecords();
  }
  
  Future<void> _loadTodayRecords() async {
    final records = await StorageService.getRecordsByDate(DateTime.now());
    setState(() {
      _todayRecords = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ 饮食记录'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 快速选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '快速选择',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonFoods.map((food) {
                        final isSelected = _selectedFoods.contains(food);
                        return FilterChip(
                          label: Text(food),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFoods.add(food);
                              } else {
                                _selectedFoods.remove(food);
                              }
                            });
                          },
                          selectedColor: Colors.green[100],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 自定义输入
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '自定义饮食',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dietController,
                      decoration: const InputDecoration(
                        hintText: '输入其他食物...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 保存按钮
            ElevatedButton(
              onPressed: _selectedFoods.isEmpty && _dietController.text.isEmpty
                  ? null
                  : () async {
                      final dietText = [
                        ..._selectedFoods,
                        if (_dietController.text.isNotEmpty) _dietController.text,
                      ].join(', ');
                      
                      // 为每条今日记录更新饮食
                      for (var record in _todayRecords) {
                        final updatedRecord = PoopRecord(
                          id: record.id,
                          timestamp: record.timestamp,
                          bristolType: record.bristolType,
                          durationSeconds: record.durationSeconds,
                          symptoms: record.symptoms,
                          notes: record.notes,
                          dietNotes: dietText,
                          createdAt: record.createdAt,
                        );
                        // 更新记录
                        await StorageService.deleteRecord(record.id);
                        await StorageService.saveRecord(updatedRecord);
                      }
                      
                      setState(() {
                        _selectedFoods.clear();
                        _dietController.clear();
                      });
                      
                      _loadTodayRecords();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ 饮食记录已保存！'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              child: const Text('保存饮食记录'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            
            // 今日记录与饮食关联
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📅 今日记录',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_todayRecords.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            '今日还没有排便记录\n请先在首页记录',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todayRecords.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final record = _todayRecords[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.bristolColors[record.bristolType - 1],
                              child: Text(
                                '${record.bristolType}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(record.bristolDescription),
                            subtitle: record.dietNotes != null
                                ? Text(
                                    '🍽️ ${record.dietNotes}',
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : const Text(
                                    '未记录饮食',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _dietController.dispose();
    super.dispose();
  }
}
