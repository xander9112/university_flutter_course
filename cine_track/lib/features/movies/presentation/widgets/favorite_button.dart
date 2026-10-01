import 'package:flutter/material.dart';

/// Кнопка-сердце: при переключении иконка меняется с анимацией масштаба.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
  });

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isFavorite ? 'Убрать из избранного' : 'Добавить в избранное',
      // На мобильных — показывать при долгом нажатии
      // На десктопе — при наведении мыши (автоматически)
      child: IconButton(
        onPressed: onToggle,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          // Кастомный переход: иконка появляется через увеличение масштаба
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            // key обязателен: AnimatedSwitcher различает виджеты по key
            key: ValueKey<bool>(isFavorite),
            color: isFavorite ? Colors.red : null,
            size: 28,
          ),
        ),
      ),
    );
  }
}
