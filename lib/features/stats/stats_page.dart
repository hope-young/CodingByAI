// 💩 PoopTracker - Stats Page (iOS Style)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:poop_tracker/core/theme/app_theme.dart';
import 'package:poop_tracker/data/models/poop_record.dart';
import 'package:poop_tracker/data/services/storage_service.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  List<PoopRecord> _allRecords = [];
  Map<String, dynamic> _stats = {};
  int _streakDays = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final records = await StorageService.getAllRecords();
    final stats = await StorageService.getStats();
    final streak = await StorageService.getStreakDays();
    
    setState(() {
      _allRecords = records;
      _stats = stats;
      _streakDays = streak;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppTheme.cardColor,
        border: null,
        middle: Text('📊 统计'),
      ),
      child: SafeArea(
        child: _allRecords.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      '暂无数据',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '开始记录后即可查看统计',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 概览卡片
                    _buildOverviewCards(),
                    const SizedBox(height: 16),
                    
                    // 形态分布
                    _buildTypeDistribution(),
                    const SizedBox(height: 16),
                    
                    // 最近记录
                    _buildRecentRecords(),
                  ],
                ),
              ),
      ),
    );
  }
  
  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('📝', '总记录', '${_stats['total'] ?? 0}', '次', AppTheme.iosBlue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('🔥', '连续', '$_streakDays', '天', AppTheme.iosOrange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('⏱️', '平均', _formatDuration(_stats['avgDuration'] ?? 0), '', AppTheme.iosGreen)),
      ],
    );
  }
  
  Widget _buildStatCard(String emoji, String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$title $unit',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeDistribution() {
    Map<int, int> typeCount = {};
    for (var record in _allRecords) {
      typeCount[record.bristolType] = (typeCount[record.bristolType] ?? 0) + 1;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💩', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '形态分布',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (typeCount.values.fold(0, (a, b) => a > b ? a : b) + 2).toDouble(),
                barGroups: List.generate(7, (index) {
                  final type = index + 1;
                  final count = typeCount[type] ?? 0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: AppTheme.bristolColors[index],
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${value.toInt() + 1}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '最常见：${_stats['mostCommonType']}型',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentRecords() {
    final recentRecords = _allRecords.take(10).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📝', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '最近记录',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentRecords.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = recentRecords[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.bristolColors[record.bristolType - 1],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${record.bristolType}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.bristolDescription,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${record.timestamp.month}/${record.timestamp.day} ${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      record.durationDescription,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    if (seconds == 0) return '0秒';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}分';
    }
    return '${secs}秒';
  }
}
