import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Экран-заглушка для будущих вкладок оболочки (Календарь, Картотека).
/// Заполняется по мере проработки соответствующих доменов.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tk.surface3,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: tk.onFaint),
              ),
              const SizedBox(height: 18),
              Text(title, style: text.headlineSmall),
              const SizedBox(height: 6),
              Text('Скоро', style: text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
