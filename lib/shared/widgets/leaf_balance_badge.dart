import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/garden/leaf_points_controller.dart';

class LeafBalanceBadge extends StatefulWidget {
  const LeafBalanceBadge({super.key});

  @override
  State<LeafBalanceBadge> createState() => _LeafBalanceBadgeState();
}

class _LeafBalanceBadgeState extends State<LeafBalanceBadge> {
  final LeafPointsController _controller = LeafPointsController.instance;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 25, color: AppColors.sagePrimary),

            const SizedBox(width: 6),

            Text(
              _controller.isLoaded ? '${_controller.balance}' : '...',
              style: const TextStyle(
                color: AppColors.sageDark,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}
