import 'package:flutter/material.dart';

/// Заглушка вкладки «Избранное». Настоящее избранное появится в Задании 12.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: const Center(child: Text('Избранное пусто')),
    );
  }
}
