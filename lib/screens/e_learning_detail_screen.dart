import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../models/e_learning_model.dart';
import 'e_learning_module_screen.dart';

class ELearningDetailScreen extends StatefulWidget {
  final String courseId;

  const ELearningDetailScreen({super.key, required this.courseId});

  @override
  State<ELearningDetailScreen> createState() => _ELearningDetailScreenState();
}

class _ELearningDetailScreenState extends State<ELearningDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ).fetchELearningDetail(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final course = auth.selectedCourse;

          if (auth.isLoading ||
              course == null ||
              course.id != widget.courseId) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(course),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chapter = course.chapters![index];
                    return _buildChapterSection(chapter);
                  }, childCount: course.chapters?.length ?? 0),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ELearningModel course) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          course.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppTheme.primary),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.school_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterSection(ELearningChapterModel chapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            chapter.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...chapter.modules.map((module) => _buildModuleTile(module)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildModuleTile(ELearningModuleModel module) {
    IconData icon;
    Color color;

    switch (module.type) {
      case 'material':
        icon = Icons.description_rounded;
        color = Colors.blue;
        break;
      case 'assignment':
        icon = Icons.assignment_rounded;
        color = Colors.orange;
        break;
      case 'exercise':
        icon = Icons.fitness_center_rounded;
        color = Colors.purple;
        break;
      case 'exam':
        icon = Icons.quiz_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          module.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          module.type.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.8),
          ),
        ),
        trailing: module.isCompleted
            ? Icon(Icons.check_circle_rounded, color: Colors.green[400])
            : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ELearningModuleScreen(moduleId: module.id),
            ),
          );
        },
      ),
    );
  }
}
