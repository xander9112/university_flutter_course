import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Индикатор загрузки: вращающаяся иконка плёнки.
class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key, this.size = 48});
  final double size;

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Tween от 0 до 2π (полный оборот в радианах)
    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.repeat(); // бесконечное вращение
  }

  @override
  void dispose() {
    _controller
        .dispose(); // иначе контроллер продолжит тикать после закрытия экрана
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(angle: _animation.value, child: child);
      },
      // child строится один раз, в builder меняется только угол
      child: Icon(
        Icons.movie,
        size: widget.size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
