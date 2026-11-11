import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import '../providers/account_provider.dart';

// The provider is created here, inside the screen, so it stops when the
// screen closes and never shows an old account's data after a new login.
class ProfileScreen extends StatelessWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountProvider(fallbackEmail: email),
      child: _ProfileView(email: email),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final String email;

  const _ProfileView({required this.email});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  static const Color _error = Color(0xFFD94B4B);
  static const Color _lockedFill = Color(0xFFEFEBE0);

  // only the form lives here (pure UI state)
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  bool _nameTouched = false; // the user typed in the name box
  String? _errorMessage; // the red box under the form

  @override
  void initState() {
    super.initState();
    final account = context.read<AccountProvider>();

    // start with the name we already know (the Firebase display name)
    nameController.text = account.savedName;

    // when the live profile brings a new name, show it unless the user
    // has already started typing
    account.onNameChanged = (name) {
      if (!_nameTouched) nameController.text = name;
    };
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  bool _canSave(AccountProvider account) =>
      !account.savingName &&
          nameController.text.trim() != account.savedName.trim();

  // ---------- SAVE THE NAME ----------
  Future<void> _saveName() async {
    final account = context.read<AccountProvider>();
    if (account.savingName) return;
    if (!formKey.currentState!.validate()) return;
    if (nameController.text.trim() == account.savedName.trim()) return;

    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    // the provider does the work and gives back null or an error text
    final error = await account.saveName(nameController.text);
    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() => _nameTouched = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name updated')),
    );
  }

  // ---------- UI ----------
  Widget _initialAvatar(String displayName) {
    return Center(
      child: Text(
        displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _fallbackAvatar(AccountProvider account, String displayName) {
    final file = account.localImage;
    if (file != null) {
      return ClipOval(
        child: Image.file(
          file,
          width: 112,
          height: 112,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialAvatar(displayName),
        ),
      );
    }
    return _initialAvatar(displayName);
  }

  Widget _buildAvatar(AccountProvider account, String displayName) {
    final bytes = account.photoBytes;
    if (bytes != null) {
      return ClipOval(
        child: Image.memory(
          bytes,
          width: 112,
          height: 112,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _fallbackAvatar(account, displayName),
        ),
      );
    }
    return _fallbackAvatar(account, displayName);
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    bool locked = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSoft, fontSize: 16),
      floatingLabelStyle: TextStyle(
        color: locked ? AppColors.textSoft : AppColors.emerald,
        fontSize: 16,
      ),
      prefixIcon: Icon(
        icon,
        color: locked ? AppColors.textSoft : AppColors.emerald,
      ),
      suffixIcon: locked
          ? const Icon(Icons.lock_outline, color: AppColors.textSoft, size: 20)
          : null,
      filled: true,
      fillColor: locked ? _lockedFill : AppColors.card,
      errorStyle: const TextStyle(color: _error, fontSize: 14),
      border: border(const Color(0xFFE3DED2)),
      enabledBorder: border(const Color(0xFFE3DED2)),
      focusedBorder: border(AppColors.emerald, 1.5),
      errorBorder: border(_error, 1.5),
      focusedErrorBorder: border(_error, 1.5),
    );
  }

  // a greyed, read-only box with a lock icon
  Widget _lockedField({
    required String label,
    required IconData icon,
    required String value,
    bool muted = false,
  }) {
    return InputDecorator(
      isEmpty: false,
      decoration: _decoration(label: label, icon: icon, locked: true),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: muted ? const Color(0xFF9AA5A3) : AppColors.textSoft,
          fontSize: 17,
          fontStyle: muted ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // rebuilds whenever the provider changes (name, picture, saving...)
    final account = context.watch<AccountProvider>();

    final fullPhone = account.fullPhone;
    final phoneText = fullPhone ?? 'Not added';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PICTURE (change it from Settings with the camera button)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.gold,
                      child: _buildAvatar(account, account.displayName),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // NAME (editable)
                TextFormField(
                  controller: nameController,
                  enabled: !account.savingName,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                  ),
                  cursorColor: AppColors.emerald,
                  onChanged: (_) => setState(() {
                    _nameTouched = true;
                    _errorMessage = null;
                  }),
                  onFieldSubmitted: (_) {
                    if (_canSave(account)) _saveName();
                  },
                  decoration: _decoration(
                    label: 'Name',
                    icon: Icons.person_outline,
                  ).copyWith(counterText: ''),
                  validator: AccountProvider.validateName,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: Text(
                    'People who saved you keep the name they chose for you.',
                    style: TextStyle(color: AppColors.textSoft, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 18),

                // PHONE (read-only)
                _lockedField(
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  value: phoneText,
                  muted: fullPhone == null,
                ),
                const SizedBox(height: 18),

                // EMAIL (read-only)
                _lockedField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  value: account.email,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCEAEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: _error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: _error,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _canSave(account) ? _saveName : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      disabledBackgroundColor: account.savingName
                          ? AppColors.emerald
                          : const Color(0xFFB8C2C0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: account.savingName
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Save name',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}