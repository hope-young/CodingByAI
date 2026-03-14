// 💩 PoopTracker - Home Page (iOS Style + 手动记录 + 悬浮窗)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poop_tracker/core/theme/app_theme.dart';
import 'package:poop_tracker/data/models/poop_record.dart';
import 'package:poop_tracker/data/services/storage_service.dart';
import 'package:poop_tracker/widgets/floating_timer_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRecording = false;
  DateTime? _startTime;
  int _selectedType = 4;
  final List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();
  
  List<PoopRecord> _todayRecords = [];
  
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
  
  void _startTimer() {
    setState(() {
      _isRecording = true;
      _startTime = DateTime.now();
    });
    // 启动悬浮窗服务
    FloatingTimerService.instance.startTimer(_startTime!);
  }
  
  void _stopTimer() async {
    if (_startTime == null) return;
    
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    
    final record = PoopRecord(
      id: '',
      timestamp: _startTime!,
      bristolType: _selectedType,
      durationSeconds: duration,
      symptoms: _selectedSymptoms.isNotEmpty ? _selectedSymptoms : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
    );
    
    await StorageService.saveRecord(record);
    
    // 停止悬浮窗
    FloatingTimerService.instance.stopTimer();
    
    setState(() {
      _isRecording = false;
      _startTime = null;
      _selectedSymptoms.clear();
      _notesController.clear();
    });
    
    _loadTodayRecords();
    
    if (mounted) {
      _showSuccessToast();
    }
  }
  
  // 手动记录（无需计时）
  void _quickRecord() async {
    final record = PoopRecord(
      id: '',
      timestamp: DateTime.now(),
      bristolType: _selectedType,
      durationSeconds: null, // 无计时
      symptoms: _selectedSymptoms.isNotEmpty ? _selectedSymptoms : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
    );
    
    await StorageService.saveRecord(record);
    
    setState(() {
      _selectedSymptoms.clear();
      _notesController.clear();
    });
    
    _loadTodayRecords();
    
    if (mounted) {
      _showQuickRecordToast();
    }
  }
  
  void _showSuccessToast() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('💩 记录成功'),
        message: const Text('排便记录已保存'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }
  
  void _showQuickRecordToast() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('✅ 记录成功'),
        message: const Text('手动记录已保存'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.cardColor,
        border: null,
        middle: const Text(
          '💩 PoopTracker',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // 计时器卡片
              _buildTimerCard(),
              const SizedBox(height: 16),
              
              // 快速记录按钮
              _buildQuickRecordButton(),
              const SizedBox(height: 16),
              
              // Bristol 形态选择
              _buildBristolSelector(),
              const SizedBox(height: 16),
              
              // 症状选择
              _buildSymptomsSelector(),
              const SizedBox(height: 16),
              
              // 备注输入
              _buildNotesInput(),
              const SizedBox(height: 24),
              
              // 今日记录
              _buildTodayRecords(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTimerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            if (!_isRecording) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('💩', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '点击开始计时',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _startTimer,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.play_fill, size: 18),
                      SizedBox(width: 8),
                      Text('开始计时'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('⏱️', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  if (_startTime == null) return const Text('00:00');
                  final elapsed = DateTime.now().difference(_startTime!);
                  final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
                  final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
                  return Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: Colors.black87,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                '悬浮窗已开启，切屏也能看到',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: Colors.red,
                  onPressed: _stopTimer,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.stop_fill, size: 18),
                      SizedBox(width: 8),
                      Text('停止并保存'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickRecordButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: AppTheme.iosGreen,
          onPressed: _quickRecord,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.hand_point_right_fill, size: 18),
              SizedBox(width: 8),
              Text('快速手动记录（不计时）'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBristolSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('💩', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  '大便形态',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final type = index + 1;
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.bristolColors[index],
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: AppTheme.iosBlue, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppTheme.iosBlue.withOpacity(0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$type',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.bristolColors[_selectedType - 1].withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.bristolColors[_selectedType - 1],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _getBristolDescription(_selectedType),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.bristolColors[_selectedType - 1].withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getBristolDescription(int type) {
    const descriptions = [
      '硬块状（难以排出）',
      '腊肠状但硬块',
      '腊肠状但表面有裂纹',
      '腊肠状或蛇形（光滑柔软）',
      '软团块状（易于排出）',
      '糊状',
      '水样状（液体）',
    ];
    return descriptions[type - 1];
  }
  
  Widget _buildSymptomsSelector() {
    const symptoms = ['疼痛', '出血', '便秘', '腹泻', '腹胀', '恶心'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🤕', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  '症状（可选）',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSymptoms.remove(symptom);
                      } else {
                        _selectedSymptoms.add(symptom);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.withOpacity(0.1) : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      symptom,
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotesInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('📝', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  '备注（可选）',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _notesController,
              placeholder: '添加备注...',
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTodayRecords() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('📅', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      '今日记录',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_todayRecords.length} 次',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_todayRecords.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Text('💩', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text('今日还没有记录', style: TextStyle(color: Colors.grey)),
                      Text('点击上方按钮开始记录', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _todayRecords.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = _todayRecords[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.bristolColors[record.bristolType - 1],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${record.bristolType}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.bristolDescription, style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                '${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')} · ${record.durationDescription}',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (record.symptoms != null && record.symptoms!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              record.symptoms!.join(', '),
                              style: const TextStyle(fontSize: 11, color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
