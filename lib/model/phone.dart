/// Nepali mobile numbers: 10 digits starting 98 or 97 (NTC and Ncell).
bool isNepaliMobile(String number) =>
    RegExp(r'^(98|97)\d{8}$').hasMatch(number.trim());
