import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/phone_helper.dart';

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
    final p = context.palette;

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
      // the open list and the text follow the theme
      dropdownColor: p.card,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: p.textDark,
      ),
      iconEnabledColor: p.textSoft,
      decoration: decoration.copyWith(
        contentPadding: const EdgeInsets.fromLTRB(12, 16, 4, 16),
        fillColor: enabled ? decoration.fillColor : p.lockedFill,
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