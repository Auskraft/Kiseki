import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Настройки → Документация → «Политика конфиденциальности». Статический текст
/// (RU). ЧЕРНОВИК — формулировки и контакт выверить перед публикацией в стор.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final systemBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 2, 20, 24 + systemBottom),
                children: const [
                  _Updated('Обновлено: июнь 2026'),
                  _Para(
                    'Kiseki — личная картотека. Приложение бережно относится к '
                    'вашим данным: они остаются у вас.',
                  ),
                  _Section(
                    'Какие данные обрабатываются',
                    'Все ваши записи (карточки, оценки, заметки, теги) и изображения '
                    'хранятся локально на устройстве, в приватном хранилище '
                    'приложения. Разработчик их не получает и не видит. Учётной '
                    'записи и регистрации не требуется.',
                  ),
                  _Section(
                    'Резервное копирование (по желанию)',
                    'Если вы подключаете Яндекс.Диск, копия ваших данных (база и '
                    'изображения) загружается в ВАШ личный Яндекс.Диск по токену '
                    'доступа, который вы выдаёте при авторизации в Яндекс ID. Данные '
                    'передаются напрямую между приложением и Яндекс.Диском; '
                    'разработчик доступа к ним не имеет. Отозвать доступ можно в '
                    'настройках Яндекс ID, а саму копию — удалить на Яндекс.Диске.',
                  ),
                  _Section(
                    'Доступ в сеть',
                    'Интернет используется только для авторизации в Яндекс ID и '
                    'загрузки/скачивания резервной копии. Без подключённого '
                    'Яндекс.Диска приложение в сеть не выходит.',
                  ),
                  _Section(
                    'Разрешения',
                    'Камера и галерея используются только для выбора обложек к '
                    'карточкам. Выбранные изображения остаются на устройстве.',
                  ),
                  _Section(
                    'Аналитика и трекинг',
                    'Отсутствуют. Приложение не использует рекламные идентификаторы, '
                    'аналитику и сторонние SDK слежения.',
                  ),
                  _Section(
                    'Хранение и удаление',
                    'Данные удаляются вместе с карточками (через корзину) и при '
                    'удалении приложения. Резервные копии на Яндекс.Диске удаляются '
                    'вами.',
                  ),
                  _Section(
                    'Изменения политики',
                    'Политика может обновляться; актуальная версия всегда доступна '
                    'в этом разделе приложения.',
                  ),
                  _Section(
                    'Контакты',
                    'По вопросам о данных: укажите_контакт@example.com.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tk.onBg),
            tooltip: 'Назад',
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text('Политика конфиденциальности',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _Updated extends StatelessWidget {
  const _Updated(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      child: Text(
        text,
        style: TextStyle(fontSize: 12 * uiScale, color: context.tokens.onFaint),
      ),
    );
  }
}

class _Para extends StatelessWidget {
  const _Para(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.body);
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Unbounded',
              fontVariations: const [FontVariation('wght', 600)],
              fontSize: 14.5 * uiScale,
              color: tk.onBg,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5 * uiScale,
              height: 1.5,
              color: tk.onMuted,
            ),
          ),
        ],
      ),
    );
  }
}
