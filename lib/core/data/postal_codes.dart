// Small UK postcode dataset and suggestion helper.
import 'dart:async';

const List<String> _ukPostcodes = [
  'SW1A 1AA', // Westminster
  'EC1A 1BB', // Central London
  'W1A 0AX', // West End
  'M1 1AE', // Manchester
  'B1 1AA', // Birmingham
  'LS1 1UR', // Leeds
  'L1 8JQ', // Liverpool
  'G1 1XQ', // Glasgow
  'EH1 1YZ', // Edinburgh
  'CF10 1EP', // Cardiff
  'BT1 5GS', // Belfast
];

final RegExp _ukPostcodePattern = RegExp(
  r'^(?:GIR ?0AA|[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2})$',
  caseSensitive: false,
);

/// Whether [postcode] is a valid UK postcode in a standard outward/inward form.
bool isValidUkPostcode(String postcode) =>
    _ukPostcodePattern.hasMatch(postcode.trim());

/// Returns up to 3 UK postcode suggestions matching the start of [query].
FutureOr<Iterable<String>> getPostalSuggestions(String query) {
  final q = query.trim().toUpperCase().replaceAll(' ', '');
  if (q.isEmpty) return const [];

  return _ukPostcodes
      .where((postcode) => postcode.replaceAll(' ', '').startsWith(q))
      .take(3);
}
