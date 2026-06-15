import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/rating.dart';
import 'package:kiseki/core/catalog/tag_name.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';

void main() {
  group('Rating', () {
    test('asTenScale maps 0-100 to one-decimal /10', () {
      expect(const Rating(84).asTenScale, 8.4);
      expect(const Rating(0).asTenScale, 0.0);
      expect(const Rating(100).asTenScale, 10.0);
    });

    test('clamp keeps value inside 0..100', () {
      expect(Rating.clamp(150).value, 100);
      expect(Rating.clamp(-5).value, 0);
      expect(Rating.clamp(73).value, 73);
    });

    test('value equality', () {
      expect(const Rating(50), const Rating(50));
      expect(const Rating(50), isNot(const Rating(51)));
    });
  });

  group('normalizeTagName', () {
    test('lowercases, trims and collapses whitespace', () {
      expect(normalizeTagName('  Драма  '), 'драма');
      expect(normalizeTagName('KR   Drama'), 'kr drama');
      expect(normalizeTagName('Драма'), normalizeTagName('драма'));
    });
  });

  group('enum codes are stable', () {
    test('round-trip through fromCode', () {
      for (final s in WatchStatus.values) {
        expect(WatchStatus.fromCode(s.code), s);
      }
      for (final t in MediaType.values) {
        expect(MediaType.fromCode(t.code), t);
      }
    });

    test('completed status code is "completed" (not "done")', () {
      expect(WatchStatus.completed.code, 'completed');
    });

    test('media type label depends on format (ADR-07)', () {
      expect(MediaType.movie.labelFor(MediaFormat.single), 'Фильм');
      expect(MediaType.movie.labelFor(MediaFormat.episodic), 'Сериал');
      expect(MediaType.drama.labelFor(MediaFormat.episodic), 'Дорама');
      expect(
          MediaType.anime.labelFor(MediaFormat.single), 'Полнометражное аниме');
    });
  });
}
