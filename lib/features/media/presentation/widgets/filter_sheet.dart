import 'package:flutter/material.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/catalog/tag.dart';
import '../../../../core/catalog/tag_repository.dart';
import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_format.dart';
import '../../domain/media_query.dart';
import '../../domain/media_type.dart';
import 'editor/country_field.dart';

const _sortLabels = <CatalogSortField, String>{
  CatalogSortField.updatedAt: 'Обновлено',
  CatalogSortField.createdAt: 'Добавлено',
  CatalogSortField.rating: 'Оценка',
  CatalogSortField.title: 'Название',
  CatalogSortField.year: 'Год',
  CatalogSortField.lastActivityAt: 'Активность',
  CatalogSortField.finishedAt: 'Завершено',
};

/// Боттомшит фильтров и сортировки. Возвращает новый [MediaListQuery] или
/// `null`, если закрыли без применения.
Future<MediaListQuery?> showFilterSheet(
    BuildContext context, MediaListQuery current) {
  return showModalBottomSheet<MediaListQuery>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(current: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current});

  final MediaListQuery current;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final Set<WatchStatus> _statuses = {...widget.current.statuses};
  late final Set<MediaType> _types = {...widget.current.mediaTypes};
  late final Set<MediaFormat> _formats = {...widget.current.formats};
  late final Set<String> _tagIds = {...widget.current.tagIds};
  late final Set<UnfinishedReason> _reasons = {
    ...widget.current.unfinishedReasons
  };
  late final Set<String> _countries = {...widget.current.countries};
  late RangeValues _rating = RangeValues(
    (widget.current.ratingMin ?? 0).toDouble(),
    (widget.current.ratingMax ?? 100).toDouble(),
  );
  late bool _onlyUnrated = widget.current.onlyUnrated;
  late bool _onlyFavorites = widget.current.onlyFavorites;
  late CatalogSortField _sortField = widget.current.sortField;
  late SortDirection _sortDir = widget.current.sortDirection;

  List<Tag> _tags = const [];

  @override
  void initState() {
    super.initState();
    getIt<TagRepository>().all().then((tags) {
      if (mounted) setState(() => _tags = tags);
    });
  }

  bool get _ratingIsFull => _rating.start <= 0 && _rating.end >= 100;

  MediaListQuery _build() => MediaListQuery(
        text: widget.current.text,
        statuses: _statuses,
        mediaTypes: _types,
        formats: _formats,
        tagIds: _tagIds,
        unfinishedReasons: _reasons,
        countries: _countries,
        ratingMin: (_onlyUnrated || _ratingIsFull) ? null : _rating.start.round(),
        ratingMax: (_onlyUnrated || _ratingIsFull) ? null : _rating.end.round(),
        onlyUnrated: _onlyUnrated,
        onlyFavorites: _onlyFavorites,
        sortField: _sortField,
        sortDirection: _sortDir,
      );

  void _reset() {
    // Сброс фильтров, сортировку сохраняем.
    Navigator.pop(
      context,
      MediaListQuery(
        text: widget.current.text,
        sortField: _sortField,
        sortDirection: _sortDir,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final maxH = MediaQuery.sizeOf(context).height * 0.82;
    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: tk.surface3,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Фильтры и сортировка',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: Text('Сбросить', style: TextStyle(color: tk.onMuted)),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                _SortSection(
                  field: _sortField,
                  dir: _sortDir,
                  onField: (f) => setState(() => _sortField = f),
                  onDir: (d) => setState(() => _sortDir = d),
                ),
                _Group(
                  label: 'Статус',
                  child: _Chips<WatchStatus>(
                    values: WatchStatus.values,
                    selected: _statuses,
                    label: StatusVisual.label,
                    onToggle: (v) => setState(() => _toggle(_statuses, v)),
                  ),
                ),
                _Group(
                  label: 'Тип',
                  child: _Chips<MediaType>(
                    values: MediaType.values,
                    selected: _types,
                    label: (t) => t.label,
                    onToggle: (v) => setState(() => _toggle(_types, v)),
                  ),
                ),
                _Group(
                  label: 'Формат',
                  child: _Chips<MediaFormat>(
                    values: MediaFormat.values,
                    selected: _formats,
                    label: (f) =>
                        f == MediaFormat.single ? 'Одиночный' : 'С сериями',
                    onToggle: (v) => setState(() => _toggle(_formats, v)),
                  ),
                ),
                _Group(
                  label: 'Оценка',
                  child: _RatingFilter(
                    range: _rating,
                    onlyUnrated: _onlyUnrated,
                    onRange: (r) => setState(() {
                      _rating = r;
                      if (!(_rating.start <= 0 && _rating.end >= 100)) {
                        _onlyUnrated = false;
                      }
                    }),
                    onUnrated: (v) => setState(() {
                      _onlyUnrated = v;
                      if (v) _rating = const RangeValues(0, 100);
                    }),
                  ),
                ),
                _Group(
                  label: 'Прочее',
                  child: _Chips<bool>(
                    values: const [true],
                    selected: _onlyFavorites ? const {true} : const {},
                    label: (_) => 'Избранное',
                    onToggle: (_) =>
                        setState(() => _onlyFavorites = !_onlyFavorites),
                  ),
                ),
                if (_tags.isNotEmpty)
                  _Group(
                    label: 'Теги',
                    child: _Chips<Tag>(
                      values: _tags,
                      selected: {
                        for (final t in _tags)
                          if (_tagIds.contains(t.id)) t
                      },
                      label: (t) => t.name,
                      onToggle: (t) => setState(() {
                        if (!_tagIds.remove(t.id)) _tagIds.add(t.id);
                      }),
                    ),
                  ),
                _Group(
                  label: 'Причина паузы/заброса',
                  child: _Chips<UnfinishedReason>(
                    values: UnfinishedReason.values,
                    selected: _reasons,
                    label: reasonLabel,
                    onToggle: (v) => setState(() => _toggle(_reasons, v)),
                  ),
                ),
                _Group(
                  label: 'Страна',
                  child: _Chips<String>(
                    values: kCountries.keys.toList(),
                    selected: _countries,
                    label: countryName,
                    onToggle: (v) => setState(() => _toggle(_countries, v)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 4, 20, 16 + MediaQuery.paddingOf(context).bottom),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _build()),
                child: const Text('Применить'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle<T>(Set<T> set, T value) {
    if (!set.remove(value)) set.add(value);
  }
}

class _SortSection extends StatelessWidget {
  const _SortSection({
    required this.field,
    required this.dir,
    required this.onField,
    required this.onDir,
  });

  final CatalogSortField field;
  final SortDirection dir;
  final ValueChanged<CatalogSortField> onField;
  final ValueChanged<SortDirection> onDir;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return _Group(
      label: 'Сортировка',
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<CatalogSortField>(
              initialValue: field,
              isDense: true,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: tk.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide(color: tk.outlineSoft),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide(color: tk.outlineSoft),
                ),
              ),
              items: [
                for (final e in _sortLabels.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => v == null ? null : onField(v),
            ),
          ),
          const SizedBox(width: 8),
          _DirButton(dir: dir, onTap: () => onDir(dir == SortDirection.asc
              ? SortDirection.desc
              : SortDirection.asc)),
        ],
      ),
    );
  }
}

class _DirButton extends StatelessWidget {
  const _DirButton({required this.dir, required this.onTap});

  final SortDirection dir;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final asc = dir == SortDirection.asc;
    return Material(
      color: tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Row(
            children: [
              Icon(asc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 16, color: tk.onMuted),
              const SizedBox(width: 5),
              Text(asc ? 'возр.' : 'убыв.',
                  style: TextStyle(
                      fontSize: 12.5 * uiScale,
                      fontWeight: FontWeight.w600,
                      color: tk.onMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingFilter extends StatelessWidget {
  const _RatingFilter({
    required this.range,
    required this.onlyUnrated,
    required this.onRange,
    required this.onUnrated,
  });

  final RangeValues range;
  final bool onlyUnrated;
  final ValueChanged<RangeValues> onRange;
  final ValueChanged<bool> onUnrated;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: onlyUnrated ? 0.4 : 1,
          child: Row(
            children: [
              Text('${range.start.round()}',
                  style: TextStyle(
                      fontSize: 13 * uiScale,
                      fontWeight: FontWeight.w700,
                      color: tk.onBg)),
              Expanded(
                child: RangeSlider(
                  values: range,
                  max: 100,
                  divisions: 100,
                  onChanged: onlyUnrated ? null : onRange,
                ),
              ),
              Text('${range.end.round()}',
                  style: TextStyle(
                      fontSize: 13 * uiScale,
                      fontWeight: FontWeight.w700,
                      color: tk.onBg)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _Chips<bool>(
          values: const [true],
          selected: onlyUnrated ? const {true} : const {},
          label: (_) => 'Без оценки',
          onToggle: (_) => onUnrated(!onlyUnrated),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.values,
    required this.selected,
    required this.label,
    required this.onToggle,
  });

  final List<T> values;
  final Set<T> selected;
  final String Function(T) label;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final v in values)
          _Chip(
            label: label(v),
            selected: selected.contains(v),
            onTap: () => onToggle(v),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      color: selected ? tk.tint(tk.primary, 0.18) : tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          // Паддинг (а не height) задаёт размер: пилюля по контенту и текст
          // центрируется симметрично. height+alignment растягивал на всю ширину.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? tk.primary : tk.outlineSoft,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12 * uiScale,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? tk.primary : tk.onMuted,
            ),
          ),
        ),
      ),
    );
  }
}
