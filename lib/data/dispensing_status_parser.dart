/// Conservative interpretation of Croatian medicine dispensing metadata.
///
/// BR/BRX are non-prescription codes, while R/RS indicate prescription
/// dispensing. Unrecognized, negated, or internally inconsistent source
/// values must remain unknown rather than being treated as OTC.
abstract final class DispensingStatusParser {
  static bool? requiresPrescription(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw
        .toLowerCase()
        .replaceAll('č', 'c')
        .replaceAll('ć', 'c')
        .replaceAll('ž', 'z')
        .replaceAll('š', 's')
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // A negated or contradictory phrase cannot be safely promoted to
    // either prescription or non-prescription status.
    if (RegExp(
      r'\b(?:ne|nije|nisu|nema|zabranjeno)\b'
      r'(?:\s+\w+){0,6}\s+(?:na|bez|uz)\s+recepta?\b',
    ).hasMatch(text)) {
      return null;
    }

    final codeMatch = RegExp(
      r'^(brx|br|rs|r)(?=$|[^a-z])',
    ).firstMatch(text);
    final code = switch (codeMatch?.group(1)) {
      'brx' || 'br' => false,
      'rs' || 'r' => true,
      _ => null,
    };

    final otcMention = RegExp(r'\bbez\s+recepta\b').hasMatch(text) ||
        text == 'otc';
    final prescriptionMention =
        RegExp(r'\b(?:na|uz)\s+recept\b').hasMatch(text) ||
        RegExp(r'\b(?:na|uz)\s+recepta\b').hasMatch(text);
    if (otcMention && prescriptionMention) return null;

    final phrase = otcMention
        ? false
        : prescriptionMention
            ? true
            : null;

    if (code != null && phrase != null && code != phrase) return null;
    return code ?? phrase;
  }
}
