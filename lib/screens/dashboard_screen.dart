import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/announcements_widget.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/app_image_slider.dart';
import '../widgets/dashboard_skeleton.dart';

import '../widgets/today_schedule_widget.dart';
import 'profile_screen.dart';
import 'attendance_screen.dart';
import 'subject_list_screen.dart';
import 'schedule_screen.dart';
import 'grade_screen.dart';
import 'e_learning_list_screen.dart';
import 'bank_soal_list_screen.dart';
import 'forum_list_screen.dart';
import 'cbt_list_screen.dart';
import 'evoting_list_screen.dart';
import 'berita_list_screen.dart';
import 'eraport_screen.dart';
import 'pelanggaran_screen.dart';
import 'elibrary_screen.dart';
import 'calendar_screen.dart';
import 'notification_screen.dart';
import 'school_management_screen.dart';
import 'student_statistics_screen.dart';
import 'school_data_screen.dart';
import 'teacher_certificates_screen.dart';
import 'violation_monitoring_screen.dart';
import 'sambutan_dinas_screen.dart';
import 'cbt_global_screen.dart';
import 'berita_dinas_screen.dart';
import 'agenda_dinas_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _unreadCount = 0;
  Timer? _unreadTimer;
  Future<void> _loadUnreadCount() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token == null) return;

      final response = await auth.authService.dio.get(
        '/student/notifications/unread-count',
        options: auth.authService.authOptions(auth.token!),
      );

      if (mounted &&
          response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        setState(() {
          _unreadCount = response.data['data']['unread_count'] ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error loading unread count: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _unreadTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadUnreadCount();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).getDashboardStats();
    });
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHome(),
          const CalendarScreen(),
          const ELibraryScreen(),
          const NotificationScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildAnimatedNavBar(),
    );
  }

  Widget _buildHome() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading && auth.sliders.isEmpty) {
          return const DashboardSkeleton();
        }
        final user = auth.user;

        return Column(
          children: [
            DashboardHeader(
              avatarUrl: user?.avatar,
              userName: user?.name ?? "User",
              schoolName: user?.schoolName ?? user?.role ?? "Literasia",
              unreadCount: _unreadCount,
              onNotificationTap: () => setState(() => _selectedIndex = 3),
              onProfileTap: () => setState(() => _selectedIndex = 4),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadUnreadCount();
                  await auth.getDashboardStats();
                },
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AppImageSlider(sliders: auth.sliders),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionHeader(
                        "Pengumuman",
                        "Informasi terbaru",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnnouncementsWidget(),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionHeader(
                        "Menu Utama",
                        "Akses cepat fitur",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.9,
                          children: [
                            _buildQuickMenuGridItem(
                              icon: user?.role == 'siswa'
                                  ? Icons.how_to_reg_rounded
                                  : user?.role == 'dinas'
                                  ? Icons.business_center_rounded
                                  : Icons.face,
                              label: user?.role == 'siswa'
                                  ? "Absensi"
                                  : user?.role == 'dinas'
                                  ? "Manajemen Sekolah"
                                  : "Siswa",

                              colors: const [
                                Color(0xFF4F8DF7),
                                Color(0xFF6FB1FC),
                              ],
                              onTap: () {
                                if (user?.role == 'siswa') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AttendanceScreen(),
                                    ),
                                  );
                                } else if (user?.role == 'dinas') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SchoolManagementScreen(),
                                    ),
                                  );
                                }
                              },
                            ),
                            _buildQuickMenuGridItem(
                              icon: user?.role == 'dinas'
                                  ? Icons.bar_chart_rounded
                                  : Icons.library_books_rounded,
                              label: user?.role == 'dinas'
                                  ? "Statistik Siswa"
                                  : "Mata Pelajaran",
                              colors: const [
                                Color(0xFFFFB347),
                                Color(0xFFFFCC80),
                              ],
                              onTap: () {
                                if (user?.role == 'dinas') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const StudentStatisticsScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SubjectListScreen(),
                                    ),
                                  );
                                }
                              },
                            ),

                            _buildQuickMenuGridItem(
                              icon: user?.role == 'dinas'
                                  ? Icons.format_list_bulleted_rounded
                                  : Icons.calendar_today_rounded,
                              label: user?.role == 'dinas'
                                  ? "Data Sekolah"
                                  : "Jadwal",
                              colors: const [
                                Color(0xFFF45D48),
                                Color(0xFFFF8A65),
                              ],
                              onTap: () {
                                if (user?.role == 'dinas') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SchoolDataScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ScheduleScreen(),
                                    ),
                                  );
                                }
                              },
                            ),

                            _buildQuickMenuGridItem(
                              icon: user?.role == 'dinas'
                                  ? Icons.workspace_premium_rounded
                                  : Icons.score_rounded,
                              label: user?.role == 'dinas'
                                  ? "Sertifikat Guru"
                                  : "Nilai",
                              colors: const [
                                Color(0xFF26A69A),
                                Color(0xFF4DB6AC),
                              ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => user?.role == 'dinas'
                                        ? const TeacherCertificatesScreen()
                                        : const GradeScreen(),
                                  ),
                                );
                              },
                            ),

                            _buildQuickMenuGridItem(
                              icon: user?.role == 'dinas'
                                  ? Icons.report_problem_rounded
                                  : Icons.auto_stories_rounded,
                              label: user?.role == 'dinas'
                                  ? "Mon. Pelanggaran"
                                  : "E-Learning",
                              colors: const [
                                Color(0xFF7E57C2),
                                Color(0xFFB39DDB),
                              ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => user?.role == 'dinas'
                                        ? const ViolationMonitoringScreen()
                                        : const ELearningListScreen(),
                                  ),
                                );
                              },
                            ),

                            _buildQuickMenuGridItem(
                              icon: user?.role == 'dinas'
                                  ? Icons.forum_rounded
                                  : Icons.collections_bookmark_rounded,
                              label: user?.role == 'dinas'
                                  ? "Forum Diskusi"
                                  : "Bank Soal",
                              colors: const [
                                Color(0xFF3F51B5),
                                Color(0xFF7986CB),
                              ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => user?.role == 'dinas'
                                        ? const ForumListScreen()
                                        : const BankSoalListScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickMenuGridItem(
                              icon: user?.role == 'dinas'
                                  ? Icons.record_voice_over_rounded
                                  : Icons.forum_rounded,
                              label: user?.role == 'dinas'
                                  ? "Sambutan Dinas"
                                  : "Forum",
                              colors: const [
                                Color(0xFF009688),
                                Color(0xFF4DB6AC),
                              ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => user?.role == 'dinas'
                                        ? const SambutanDinasScreen()
                                        : const ForumListScreen(),
                                  ),
                                );
                              },
                            ),

                            _buildQuickMenuGridItem(
                              icon: Icons.quiz_rounded,
                              label: user?.role == 'dinas'
                                  ? "CBT Global"
                                  : "CBT",
                              colors: user?.role == 'dinas'
                                  ? const [Color(0xFF673AB7), Color(0xFF9575CD)]
                                  : const [
                                      Color(0xFFE91E63),
                                      Color(0xFFF06292),
                                    ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => user?.role == 'dinas'
                                        ? const CbtGlobalScreen()
                                        : const CbtListScreen(),
                                  ),
                                );
                              },
                            ),
                            if (user?.role != 'dinas')
                              _buildQuickMenuGridItem(
                                icon: Icons.how_to_vote_rounded,
                                label: "E-Voting",
                                colors: const [
                                  Color(0xFFFFB300),
                                  Color(0xFFFFD54F),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EVotingListScreen(),
                                    ),
                                  );
                                },
                              ),
                            _buildQuickMenuGridItem(
                              icon: Icons.article_rounded,
                              label: user?.role == 'dinas'
                                  ? "Berita & Artikel"
                                  : "Berita",
                              colors: const [
                                Color(0xFF26C6DA),
                                Color(0xFF80DEEA),
                              ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => user?.role == 'dinas'
                                        ? const BeritaDinasScreen()
                                        : const BeritaListScreen(),
                                  ),
                                );
                              },
                            ),
                            if (user?.role == 'dinas')
                              _buildQuickMenuGridItem(
                                icon: Icons.calendar_month_rounded,
                                label: "Agenda Global",
                                colors: const [
                                  Color(0xFF42A5F5),
                                  Color(0xFF90CAF9),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AgendaDinasScreen(),
                                    ),
                                  );
                                },
                              ),
                            if (user?.role != 'dinas')
                              _buildQuickMenuGridItem(
                                icon: Icons.assignment_rounded,
                                label: "E-Raport",
                                colors: const [
                                  Color(0xFFFF7043),
                                  Color(0xFFFFAB91),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ERaportScreen(),
                                    ),
                                  );
                                },
                              ),
                            if (user?.role != 'dinas')
                              _buildQuickMenuGridItem(
                                icon: Icons.gavel_rounded,
                                label: "Pelanggaran",
                                colors: const [
                                  Color(0xFFEF5350),
                                  Color(0xFFE57373),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PelanggaranScreen(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (user?.role == 'siswa') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TodayScheduleWidget(
                          schedules: auth.todaySchedule,
                          serverTime: auth.serverTime,
                          onAttendanceTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AttendanceScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedNavBar() {
    return FloatingNavbar(
      selectedIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMenuGridItem({
    required IconData icon,
    required String label,
    List<Color>? colors,
    required VoidCallback onTap,
  }) {
    final baseColor = colors?.isNotEmpty == true
        ? colors!.first
        : AppTheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  colors ??
                  [baseColor.withOpacity(0.9), baseColor.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
