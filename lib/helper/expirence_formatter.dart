String formatExperience(String? experience) {
  if (experience == null || experience.isEmpty) return 'N/A';

  // Expecting format: "x Years & y Months"
  final regex = RegExp(r'(\d+)\s*Years?\s*&\s*(\d+)\s*Months?');
  final match = regex.firstMatch(experience);

  if (match != null) {
    final years = int.tryParse(match.group(1) ?? '0') ?? 0;
    final months = int.tryParse(match.group(2) ?? '0') ?? 0;
    String result = '';
    if (years > 0) result += '$years yrs';
    if (months > 0) {
      if (result.isNotEmpty) result += ' ';
      result += '$months mon';
    }
    return result.isEmpty ? 'N/A' : result;
  }

  // fallback to original string if format doesn't match
  return experience;
}
