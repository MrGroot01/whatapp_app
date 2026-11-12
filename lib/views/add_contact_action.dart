import 'package:flutter/material.dart';

import 'add_contact_screen.dart';

Future<void> openAddContact(BuildContext context) async {
  final saved = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const AddContactScreen()),
  );

  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact saved successfully.')),
    );
  }
}