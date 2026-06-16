// Small postal code dataset and suggestion helper
import 'dart:async';

const List<String> _laZipCodes = [
  '90001',
  '90002',
  '90003',
  '90004',
  '90005',
  '90006',
  '90007',
  '90008',
  '90010',
  '90011',
  '90012',
  '90013',
  '90014',
  '90015',
  '90016',
  '90017',
  '90018',
  '90019',
  '90020',
  '90021',
  '90022',
  '90023',
  '90024',
  '90025',
  '90026',
  '90027',
  '90028',
  '90029',
  '90030',
  '90031',
];

const List<String> _usZipCodes = [
  '10001', // New York
  '10002',
  '10003',
  '02108', // Boston
  '30301', // Atlanta
  '33101', // Miami
  '60601', // Chicago
  '73301', // Austin
  '94102', // San Francisco
  '85001', // Phoenix
  '75201', // Dallas
  '20001', // Washington DC
  '02215', // Boston (Back-up)
  '32801', // Orlando
  '37201', // Nashville
  '80201', // Denver
  '07201',
  '30303',
  '37203',
  '98101', // Seattle
];

/// Returns up to 3 postal code suggestions for the given [query].
///
/// Behavior:
/// - If [query] contains letters and matches "la" or "los", returns LA zips.
/// - If [query] contains digits, returns zip codes that start with the query.
/// - Always returns at most 3 suggestions.
FutureOr<Iterable<String>> getPostalSuggestions(String query) {
  final q = query.trim();
  if (q.isEmpty) return const [];

  final isAlpha = RegExp(r'[A-Za-z]').hasMatch(q);
  if (isAlpha) {
    final lower = q.toLowerCase();
    if (lower.contains('la') || lower.contains('los')) {
      return _laZipCodes.take(3);
    }
    // unknown letters -> no suggestions
    return const [];
  }

  // digits: match zips starting with the input
  final all = <String>[..._laZipCodes, ..._usZipCodes];
  final matches = all.where((z) => z.startsWith(q)).toList();
  if (matches.isEmpty) {
    // fallback: contains
    final containsMatches = all.where((z) => z.contains(q)).toList();
    return containsMatches.take(3);
  }
  return matches.take(3);
}
