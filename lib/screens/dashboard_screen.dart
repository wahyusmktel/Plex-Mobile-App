import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/announcements_widget.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/app_image_slider.dart';

import '../widgets/action_menu_item.dart';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).getDashboardStats();
    });
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
          _buildPlaceholder("Halaman Notifikasi"),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildAnimatedNavBar(),
    );
  }

  Widget _buildHome() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;

        return Column(
          children: [
            DashboardHeader(
              userName: user?.name ?? "User",
              schoolName: user?.schoolName ?? user?.role ?? "Literasia",
              onProfileTap: () => setState(() => _selectedIndex = 3),
            ),
            Expanded(
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.86,
                        children: [
                          ActionMenuItem(
                            icon: user?.role == 'siswa'
                                ? Icons.how_to_reg_rounded
                                : Icons.face,
                            label: user?.role == 'siswa' ? "Absensi" : "Siswa",
                            color: Colors.blue,
                            onTap: () {
                              if (user?.role == 'siswa') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AttendanceScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.library_books_rounded,
                            label: "Mata Pelajaran",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubjectListScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.calendar_today_rounded,
                            label: "Jadwal",
                            color: Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScheduleScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.score_rounded,
                            label: "Nilai",
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GradeScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.local_library_rounded,
                            label: "Perpus",
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ELibraryScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.auto_stories_rounded,
                            label: "E-Learning",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ELearningListScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.collections_bookmark_rounded,
                            label: "Bank Soal",
                            color: Colors.indigo,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BankSoalListScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.forum_rounded,
                            label: "Forum",
                            color: Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForumListScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.quiz_rounded,
                            label: "CBT",
                            color: Colors.pink,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CbtListScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.how_to_vote_rounded,
                            label: "E-Voting",
                            color: Colors.amber,
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
                          ActionMenuItem(
                            icon: Icons.article_rounded,
                            label: "Berita",
                            color: Colors.cyan,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BeritaListScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.assignment_rounded,
                            label: "E-Raport",
                            color: Colors.deepOrange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ERaportScreen(),
                                ),
                              );
                            },
                          ),
                          ActionMenuItem(
                            icon: Icons.gavel_rounded,
                            label: "Pelanggaran",
                            color: Colors.red,
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

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Fitur ini sedang dalam pengembangan",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
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
}
