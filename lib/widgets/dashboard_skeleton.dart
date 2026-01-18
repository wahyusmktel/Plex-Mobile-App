import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Skeleton
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _shimmerBox(width: 150, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    _shimmerBox(width: 100, height: 12, color: Colors.white),
                  ],
                ),
              ),
              _shimmerBox(
                width: 40,
                height: 40,
                color: Colors.white,
                radius: 12,
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // Slider Skeleton
              _shimmerBox(width: double.infinity, height: 180, radius: 18),
              const SizedBox(height: 24),

              // Announcements Skeleton
              _shimmerBox(width: 120, height: 14),
              const SizedBox(height: 12),
              _shimmerBox(width: double.infinity, height: 80, radius: 16),
              const SizedBox(height: 24),

              // Menu Skeleton
              _shimmerBox(width: 120, height: 14),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _shimmerBox(width: 48, height: 48, radius: 14),
                        const SizedBox(height: 8),
                        _shimmerBox(width: 40, height: 10),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Schedule Skeleton
              _shimmerBox(width: 120, height: 14),
              const SizedBox(height: 12),
              _shimmerBox(width: double.infinity, height: 100, radius: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox({
    double width = double.infinity,
    double height = 20,
    double radius = 4,
    Color? color,
  }) {
    return Shimmer.fromColors(
      baseColor: color != null ? color.withOpacity(0.2) : Colors.grey[300]!,
      highlightColor: color != null
          ? color.withOpacity(0.1)
          : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
