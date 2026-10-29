import 'package:flutter/material.dart';

class CountryCode {
  final String code; // for example '+91'
  final String label; // for example '+91 IN'

  const CountryCode(this.code, this.label);
}

class PhoneHelper {
  static const String defaultCode = '+91';

  static const List<CountryCode> countries = [
    CountryCode('+91', '+91 IN'),
    CountryCode('+1', '+1 US/CA'),
    CountryCode('+44', '+44 UK'),
    CountryCode('+61', '+61 AU'),
    CountryCode('+971', '+971 UAE'),
  ];

  // remove spaces, dashes and brackets
  static String clean(String value) {
    return value.replaceAll(RegExp(r'[\s()\-]'), '');
  }

  // digits only, 6 to 15 digits (after cleaning)
  static String? validate(String? value) {
    final phone = clean(value ?? '');

    if (phone.isEmpty) return 'Enter the phone number';
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'Use digits only';
    }
    if (phone.length < 6 || phone.length > 15) {
      return 'Enter a valid phone number (6–15 digits)';
    }
    return null;
  }

  // phoneIndex key = country code digits + number, for example 917483594561
  static String indexKey(String countryCode, String phone) {
    final codeDigits = countryCode.replaceAll(RegExp(r'[^0-9]'), '');
    return '$codeDigits${clean(phone)}';
  }

  static String display(String countryCode, String phone) {
    return '$countryCode $phone';
  }
}

// The one country code dropdown used by Sign up and Add contact.
// The closed box shows only the code, so it never overflows.
class CountryCodeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String>? onChanged; // null = disabled (greyed)
  final InputDecoration decoration;

  const CountryCodeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final list = List<CountryCode>.from(PhoneHelper.countries);
    if (!list.any((c) => c.code == value)) {
      list.add(CountryCode(value, value));
    }
    final enabled = onChanged != null;

    return DropdownButtonFormField<String>(
      // a new key when the value changes, so auto-fill shows immediately
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: decoration.copyWith(
        contentPadding: const EdgeInsets.fromLTRB(12, 16, 4, 16),
        fillColor: enabled ? decoration.fillColor : const Color(0xFFEFEBE0),
      ),
      selectedItemBuilder: (context) => list
          .map(
            (c) => Align(
          alignment: Alignment.centerLeft,
          child: Text(
            c.code,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
      items: list
          .map(
            (c) => DropdownMenuItem<String>(
          value: c.code,
          child: Text(c.label),
        ),
      )
          .toList(),
      onChanged: enabled
          ? (v) {
        if (v != null) onChanged!(v);
      }
          : null,
    );
  }
}