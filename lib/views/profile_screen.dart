import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../providers/account_provider.dart';

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
      SnackBar(content: Text(context.l10n.profileNameUpdated)),
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
    final p = context.palette;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: p.textSoft, fontSize: 16),
      floatingLabelStyle: TextStyle(
        color: locked ? p.textSoft : p.accent,
        fontSize: 16,
      ),
      prefixIcon: Icon(
        icon,
        color: locked ? p.textSoft : p.accent,
      ),
      suffixIcon: locked
          ? Icon(AppIcons.locked, color: p.textSoft, size: 20)
          : null,
      filled: true,
      fillColor: locked ? p.lockedFill : p.card,
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 14),
      border: border(p.border),
      enabledBorder: border(p.border),
      focusedBorder: border(p.accent, 1.5),
      errorBorder: border(AppColors.error, 1.5),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  // a greyed, read-only box with a lock icon
  Widget _lockedField({
    required String label,
    required IconData icon,
    required String value,
    bool muted = false,
  }) {
    final p = context.palette;

    return InputDecorator(
      isEmpty: false,
      decoration: _decoration(label: label, icon: icon, locked: true),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: muted ? p.mutedText : p.textSoft,
          fontSize: 17,
          fontStyle: muted ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;

    // rebuilds whenever the provider changes (name, picture, saving...)
    final account = context.watch<AccountProvider>();

    final fullPhone = account.fullPhone;
    final phoneText = fullPhone ?? l.notAdded;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l.profileTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
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
                    decoration: BoxDecoration(
                      color: p.card,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: p.shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                  style: TextStyle(
                    color: p.textDark,
                    fontSize: 17,
                  ),
                  cursorColor: p.accent,
                  onChanged: (_) => setState(() {
                    _nameTouched = true;
                    _errorMessage = null;
                  }),
                  onFieldSubmitted: (_) {
                    if (_canSave(account)) _saveName();
                  },
                  decoration: _decoration(
                    label: l.nameLabel,
                    icon: AppIcons.person,
                  ).copyWith(counterText: ''),
                  validator: (value) =>
                      AccountProvider.validateName(context.l10n, value),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: Text(
                    l.nameSavedNote,
                    style: TextStyle(
                      color: p.textSoft,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // PHONE (read-only)
                _lockedField(
                  label: l.phoneLabel,
                  icon: AppIcons.phone,
                  value: phoneText,
                  muted: fullPhone == null,
                ),
                const SizedBox(height: 18),

                // EMAIL (read-only)
                _lockedField(
                  label: l.email,
                  icon: AppIcons.email,
                  value: account.email,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.errorBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(AppIcons.error,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
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
                          : AppColors.buttonDisabledGrey,
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
                        : Text(
                      l.saveName,
                      style: const TextStyle(
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