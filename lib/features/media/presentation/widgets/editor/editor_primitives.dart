import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';

/// Заголовок секции формы: нумерованный/цветной бейдж + капсная подпись.
class EditorSectionHeader extends StatelessWidget {
  const EditorSectionHeader({
    super.key,
    required this.index,
    required this.label,
    this.accent = false,
  });

  final int index;
  final String label;

  /// `true` — бейдж primary (обязательная секция), иначе нейтральный.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent ? tk.primary : tk.surface3,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 11 * uiScale,
                fontWeight: FontWeight.w800,
                color: accent ? tk.onPrimary : tk.onMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * uiScale,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: tk.onMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Подпись над полем (+ опциональная красная «звёздочка» обязательности).
class EditorLabel extends StatelessWidget {
  const EditorLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text.rich(
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 12 * uiScale,
            fontWeight: FontWeight.w600,
            color: tk.onMuted,
          ),
          children: [
            if (required)
              TextSpan(text: '  *', style: TextStyle(color: tk.error)),
          ],
        ),
      ),
    );
  }
}

/// Декорация ввода в стиле формы: заливка surface, мягкая рамка, фокус —
/// 1.5 px primary. Используется всеми текстовыми полями редактора.
InputDecoration editorFieldDecoration(
  BuildContext context, {
  String? hint,
  Widget? icon,
  bool italicHint = false,
}) {
  final tk = context.tokens;
  OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: tk.surface,
    hintText: hint,
    hintStyle: TextStyle(
      color: tk.onFaint,
      fontStyle: italicHint ? FontStyle.italic : FontStyle.normal,
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: icon,
    prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 0),
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    enabledBorder: border(tk.outlineSoft, 1),
    border: border(tk.outlineSoft, 1),
    focusedBorder: border(tk.primary, 1.5),
  );
}

/// Сегментированный выбор (равные сегменты). Активный — заливка primary.
/// `value == null` — ни один сегмент не выбран (прогрессивная форма).
class EditorSegments<T> extends StatelessWidget {
  const EditorSegments({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, opt) in options.indexed) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: _Segment(
              label: opt.$2,
              selected: opt.$1 == value,
              onTap: () => onChanged(opt.$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: selected ? tk.primary : tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: selected ? null : Border.all(color: tk.outlineSoft),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5 * uiScale,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? tk.onPrimary : tk.onMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Выбираемый чип (статус, причина, тег). Опциональный акцент-цвет красит
/// рамку/тинт выбранного; иначе — primary. Может нести иконку.
class EditorChip extends StatelessWidget {
  const EditorChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = accent ?? tk.primary;
    return Material(
      color: selected ? tk.tint(color, 0.18) : tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          // Паддинг (а не height) задаёт размер: пилюля по контенту, текст
          // центрируется. height+alignment растягивал чип на всю ширину.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? color : tk.outlineSoft,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13 * uiScale,
                  color: selected
                      ? Color.alphaBlend(color.withValues(alpha: 0.8), tk.onBg)
                      : tk.onMuted,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected
                      ? Color.alphaBlend(color.withValues(alpha: 0.8), tk.onBg)
                      : tk.onMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка-контейнер поля (surface + мягкая рамка). Для блока оценки и т.п.
class EditorCard extends StatelessWidget {
  const EditorCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: child,
    );
  }
}

/// Условный блок (серии / причина): тинт-фон + цветная рамка, заголовок с
/// бейджем-подсказкой. Раскрывается реактивно (анимация высоты — снаружи).
class EditorConditionalCard extends StatelessWidget {
  const EditorConditionalCard({
    super.key,
    required this.title,
    required this.badge,
    required this.accent,
    required this.child,
  });

  final String title;
  final String badge;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: tk.tint(accent, 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: accent.withValues(alpha: 0.30),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13 * uiScale,
                    fontWeight: FontWeight.w700,
                    color: tk.onBg,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10 * uiScale,
                    fontWeight: FontWeight.w700,
                    color: Color.alphaBlend(
                        accent.withValues(alpha: 0.75), tk.onBg),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Степпер «− значение +» для сезона/серии/всего. `null` показывается как «—»;
/// «−» от 1 очищает в `null`, «+» от пустого даёт 1.
class MiniStepper extends StatelessWidget {
  const MiniStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final int min;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final v = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11 * uiScale, color: tk.onMuted),
        ),
        const SizedBox(height: 5),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: tk.surface2,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: v == null
                    ? null
                    : () => onChanged(v <= min ? null : v - 1),
              ),
              Text(
                v?.toString() ?? '—',
                style: TextStyle(
                  fontSize: 15 * uiScale,
                  fontWeight: FontWeight.w700,
                  color: v == null ? tk.onFaint : tk.onBg,
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: () => onChanged((v ?? min - 1) + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final enabled = onTap != null;
    return Material(
      color: tk.surface3,
      borderRadius: BorderRadius.circular(AppRadii.xs - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xs - 2),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: enabled ? tk.onBg : tk.onFaint,
          ),
        ),
      ),
    );
  }
}
