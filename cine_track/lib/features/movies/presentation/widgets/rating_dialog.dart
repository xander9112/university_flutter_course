import 'package:flutter/material.dart';

/// Диалог личной оценки. Возвращает `double` от 1 до 10 или `null` при отмене.
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (value == null || value < 1 || value > 10) {
      // Неверный ввод — диалог не закрываем, показываем ошибку под полем.
      setState(() => _error = 'Введите число от 1 до 10');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ваша оценка'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(hintText: 'от 1 до 10', errorText: _error),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }
}
