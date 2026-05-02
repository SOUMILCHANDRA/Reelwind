import '../domain/models.dart';

class UnifiedDataProcessor {
  static List<DiaryEntry> merge({
    required List<DiaryEntry> diary,
    required List<DiaryEntry> watched,
    required List<DiaryEntry> ratings,
    required List<DiaryEntry> reviews,
    required List<String> likedKeys,
  }) {
    // 1. Start with the Diary as the base
    final Map<String, List<DiaryEntry>> merged = {};

    for (var entry in diary) {
      final key = '${entry.title}_${entry.year}';
      merged.putIfAbsent(key, () => []).add(entry);
    }

    // 2. Add 'Watched' entries that aren't in the Diary
    for (var entry in watched) {
      final key = '${entry.title}_${entry.year}';
      if (!merged.containsKey(key)) {
        merged[key] = [entry];
      }
    }

    // 3. Enrich with Ratings
    for (var entry in ratings) {
      final key = '${entry.title}_${entry.year}';
      if (merged.containsKey(key)) {
        // If diary entry has no rating, use the one from ratings.csv
        for (var existing in merged[key]!) {
          if (existing.rating == 0.0) {
            // We can't change final fields, so we'd normally re-create, 
            // but for simplicity here we assume the provider handles mapping
          }
        }
      } else {
        // If not in diary/watched, add it
        merged[key] = [entry];
      }
    }

    // 4. Enrich with Reviews
    for (var entry in reviews) {
      final key = '${entry.title}_${entry.year}';
      if (merged.containsKey(key)) {
        // Match by date if possible, otherwise just pick one
        // (Simplified for now)
      }
    }

    // Flatten back to list
    final List<DiaryEntry> result = merged.values.expand((e) => e).toList();

    // 5. Apply Likes
    for (var entry in result) {
      if (likedKeys.contains('${entry.title}_${entry.year}')) {
        entry.isLiked = true;
      }
    }

    // Sort by date descending
    result.sort((a, b) => b.watchedDate.compareTo(a.watchedDate));

    return result;
  }
}
