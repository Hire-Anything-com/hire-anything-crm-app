import 'package:flutter_test/flutter_test.dart';
import 'package:hireanythingbooking/core/data/postal_codes.dart';

void main() {
  group('isValidUkPostcode', () {
    test('accepts standard UK postcodes', () {
      expect(isValidUkPostcode('SW1A 1AA'), isTrue);
      expect(isValidUkPostcode('m1 1ae'), isTrue);
      expect(isValidUkPostcode('GIR 0AA'), isTrue);
    });

    test('rejects US ZIP codes and invalid values', () {
      expect(isValidUkPostcode('90210'), isFalse);
      expect(isValidUkPostcode('SW1A'), isFalse);
    });
  });

  test('returns UK postcode suggestions', () {
    expect(getPostalSuggestions('SW1'), contains('SW1A 1AA'));
    expect(getPostalSuggestions('900'), isEmpty);
  });
}
