import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String schoolName;
  final VoidCallback onProfileTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.schoolName,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.brandGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          Positioned(
            top: -28,
            right: -18,
            child: _buildHalo(120, Colors.white.withOpacity(0.12)),
          ),
          Positioned(
            top: 26,
            left: -14,
            child: _buildHalo(80, Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selamat Datang,",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          schoolName,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppTheme.brandGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.primaryShadow,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          "https://i.pravatar.cc/150?img=12",
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white,
                              width: 48,
                              height: 48,
                              child: const Icon(
                                Icons.person,
                                color: AppTheme.primary,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalo(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
