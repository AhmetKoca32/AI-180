import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
// import 'package:sizer/sizer.dart';

// TODO: Gerekli app export ve widget importlarını ekleyin
// import '../../core/app_export.dart';
import './widgets/analysis_summary_card_widget.dart';
import './widgets/daily_routine_widget.dart';
import './widgets/progress_chart_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/todays_tip_widget.dart';
import './widgets/upcoming_reminders_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentBottomNavIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Ahmet Koca",
    "skinHealthScore": 85,
    "weeklyAnalysisCount": 12,
    "improvementPercentage": 23,
    "streakCounter": 7,
    "hasAchievementBadge": true,
  };

  // Mock analysis data
  final List<Map<String, dynamic>> _recentAnalyses = [
    {
      "id": 1,
      "date": "2025-07-15",
      "type": "Cilt Analizi",
      "thumbnail":
          "https://images.pexels.com/photos/3762800/pexels-photo-3762800.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "İyi",
      "insights": "Cilt nemliliği optimal seviyede",
      "score": 85,
    },
    {
      "id": 2,
      "date": "2025-07-14",
      "type": "Saç Analizi",
      "thumbnail":
          "https://images.pexels.com/photos/3993449/pexels-photo-3993449.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Orta",
      "insights": "Saç dökülmesi hafif artış gösteriyor",
      "score": 72,
    },
  ];

  // Mock progress data for chart
  final List<Map<String, dynamic>> _progressData = [
    {"date": "2025-07-08", "score": 78},
    {"date": "2025-07-09", "score": 80},
    {"date": "2025-07-10", "score": 82},
    {"date": "2025-07-11", "score": 79},
    {"date": "2025-07-12", "score": 83},
    {"date": "2025-07-13", "score": 85},
    {"date": "2025-07-14", "score": 87},
    {"date": "2025-07-15", "score": 85},
  ];

  // Mock daily routine data
  final List<Map<String, dynamic>> _dailyRoutine = [
    {"id": 1, "task": "Sabah temizliği", "completed": true, "time": "08:00"},
    {
      "id": 2,
      "task": "Nemlendirici uygula",
      "completed": true,
      "time": "08:15",
    },
    {"id": 3, "task": "Güneş kremi sür", "completed": false, "time": "09:00"},
    {"id": 4, "task": "Akşam bakımı", "completed": false, "time": "22:00"},
  ];

  // Mock reminders data
  final List<Map<String, dynamic>> _upcomingReminders = [
    {
      "id": 1,
      "title": "Cilt analizi zamanı",
      "time": "16:00",
      "type": "analysis",
    },
    {
      "id": 2,
      "title": "Su içmeyi unutma",
      "time": "17:30",
      "type": "hydration",
    },
    {
      "id": 3,
      "title": "Akşam bakım rutini",
      "time": "22:00",
      "type": "routine",
    },
  ];

  // Mock tips data
  final List<Map<String, dynamic>> _skincareTips = [
    {
      "id": 1,
      "title": "Günlük Su Tüketimi",
      "content":
          "Günde en az 8 bardak su içerek cildinizin nemli kalmasını sağlayın.",
      "category": "Beslenme",
    },
    {
      "id": 2,
      "title": "Güneş Koruması",
      "content": "Her gün SPF 30 ve üzeri güneş kremi kullanmayı unutmayın.",
      "category": "Koruma",
    },
    {
      "id": 3,
      "title": "Uyku Düzeni",
      "content": "Kaliteli uyku cildin yenilenmesi için kritik öneme sahiptir.",
      "category": "Yaşam Tarzı",
    },
  ];

  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });
    if (index == 3) {
      Navigator.pushNamed(context, '/chat-consultation');
    }
    // Diğer sekmeler için navigation eklenebilir
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba,  ${_userData["name"]}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          'Bugün cildin nasıl?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) {
                            List<Map<String, dynamic>> tempRoutines = List.from(
                              _dailyRoutine,
                            );
                            TextEditingController taskController =
                                TextEditingController();
                            TimeOfDay? selectedTime;
                            return StatefulBuilder(
                              builder: (context, setModalState) {
                                void addRoutine() {
                                  if (taskController.text.isNotEmpty &&
                                      selectedTime != null) {
                                    tempRoutines.add({
                                      "id":
                                          DateTime.now().millisecondsSinceEpoch,
                                      "task": taskController.text,
                                      "completed": false,
                                      "time": selectedTime!.format(context),
                                    });
                                    taskController.clear();
                                    selectedTime = null;
                                    setModalState(() {});
                                  }
                                }

                                void removeRoutine(int index) {
                                  tempRoutines.removeAt(index);
                                  setModalState(() {});
                                }

                                void editRoutineTime(int index) async {
                                  TimeOfDay? picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: int.parse(
                                        tempRoutines[index]["time"].split(
                                          ":",
                                        )[0],
                                      ),
                                      minute: int.parse(
                                        tempRoutines[index]["time"].split(
                                          ":",
                                        )[1],
                                      ),
                                    ),
                                  );
                                  if (picked != null) {
                                    tempRoutines[index]["time"] = picked.format(
                                      context,
                                    );
                                    setModalState(() {});
                                  }
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .primaryContainer,
                                        Colors.white,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 16,
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom +
                                          16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .outline,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.tune,
                                              color: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .primary,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Rutini Özelleştir",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ...List.generate(tempRoutines.length, (
                                          index,
                                        ) {
                                          final routine = tempRoutines[index];
                                          return Card(
                                            elevation: 3,
                                            shadowColor: AppTheme.shadowLight,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .primaryContainer,
                                                child: Icon(
                                                  Icons.check,
                                                  color: AppTheme.successLight,
                                                ),
                                              ),
                                              title: Text(
                                                routine["task"],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                routine["time"],
                                                style: TextStyle(
                                                  color: AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.access_time,
                                                      color: AppTheme
                                                          .lightTheme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    onPressed: () =>
                                                        editRoutineTime(index),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color:
                                                          AppTheme.errorLight,
                                                    ),
                                                    onPressed: () =>
                                                        removeRoutine(index),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                        const Divider(height: 32),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: taskController,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            "Yeni rutin adı",
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.successLight,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  selectedTime =
                                                      await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                      );
                                                  setModalState(() {});
                                                },
                                                child: Text(
                                                  selectedTime == null
                                                      ? "Saat"
                                                      : selectedTime!.format(
                                                          context,
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .primary,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: addRoutine,
                                                child: const Text("Ekle"),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Kapat"),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.successLight,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _dailyRoutine
                                                    ..clear()
                                                    ..addAll(tempRoutines);
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Kaydet"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: height * 0.03),
                // Health Score Indicator
                Center(
                  child: Container(
                    width: width * 0.35,
                    height: width * 0.35,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: width * 0.35,
                          height: width * 0.35,
                          child: CircularProgressIndicator(
                            value: (_userData["skinHealthScore"] as int) / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(
                                _userData["skinHealthScore"] as int,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_userData["skinHealthScore"]}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(
                                  _userData["skinHealthScore"] as int,
                                ),
                              ),
                            ),
                            const Text(
                              'Cilt Skoru',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                // 1. Analysis Summary
                AnalysisSummaryCardWidget(
                  analyses: _recentAnalyses,
                  onTap: (analysis) {},
                ),
                SizedBox(height: height * 0.02),
                // 2. Progress Chart
                ProgressChartWidget(progressData: _progressData),
                SizedBox(height: height * 0.02),
                // 3. Quick Stats
                QuickStatsWidget(
                  weeklyCount: _userData["weeklyAnalysisCount"] as int,
                  improvementPercentage:
                      _userData["improvementPercentage"] as int,
                  streakCounter: _userData["streakCounter"] as int,
                  hasAchievement: _userData["hasAchievementBadge"] as bool,
                ),
                SizedBox(height: height * 0.02),
                // 4. Daily Routine
                DailyRoutineWidget(
                  routines: _dailyRoutine,
                  onToggle: (index, value) {
                    setState(() {
                      _dailyRoutine[index]["completed"] = value;
                    });
                  },
                ),
                SizedBox(height: height * 0.02),
                // 5. Today's Tip
                TodaysTipWidget(
                  tips: _skincareTips,
                  currentIndex: _currentTipIndex,
                  onSwipe: () {
                    setState(() {
                      _currentTipIndex =
                          (_currentTipIndex + 1) % _skincareTips.length;
                    });
                  },
                ),
                SizedBox(height: height * 0.02),
                // 6. Upcoming Reminders
                UpcomingRemindersWidget(
                  reminders: _upcomingReminders,
                  onComplete: (index) {
                    setState(() {
                      _upcomingReminders.removeAt(index);
                    });
                  },
                ),
                SizedBox(height: height * 0.04),
                // 7. ve 8. widgetlar için placeholder
                Container(
                  height: 80,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('Ekstra Widget 1')),
                ),
                Container(
                  height: 80,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('Ekstra Widget 2')),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.camera_alt, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Geçmiş'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Analiz'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Danışman'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
} 