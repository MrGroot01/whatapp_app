import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../models/found_profile.dart';
import '../providers/add_contact_provider.dart';
import '../services/phone_helper.dart';
import 'widgets/country_code_dropdown.dart';

class AddContactScreen extends StatelessWidget {
  const AddContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddContactProvider(),
      child: const _AddContactView(),
    );
  }
}

class _AddContactView extends StatefulWidget {
  const _AddContactView();

  @override
  State<_AddContactView> createState() => _AddContactViewState();
}

class _AddContactViewState extends State<_AddContactView> {
  // only the form lives here (the text boxes and what we filled in them)
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final FocusNode emailFocus = FocusNode();

  String countryCode = PhoneHelper.defaultCode;
  String? errorMessage; // the red box under the form

  bool _phoneAutoFilled = false; // the phone box was filled by the lookup
  String _suggestedName = ''; // the name box was filled by the lookup

  @override
  void initState() {
    super.initState();

    final provider = context.read<AddContactProvider>();
    provider.onFound = _applyFound;
    provider.onCleared = _onLookupCleared;
    provider.onSaved = () {
      if (mounted) Navigator.pop(context, true);
    };

    emailFocus.addListener(_onEmailFocusChanged);
  }

  @override
  void dispose() {
    emailFocus.removeListener(_onEmailFocusChanged);
    emailFocus.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onEmailFocusChanged() {
    if (emailFocus.hasFocus) return;
    context.read<AddContactProvider>().onEmailFocusLost(emailController.text);
  }

  void _applyFound(FoundProfile found) {
    if (!mounted) return;
    setState(() {
      if (found.hasPhone) {
        countryCode = found.countryCode.isNotEmpty
            ? found.countryCode
            : PhoneHelper.defaultCode;
        phoneController.text = found.phone;
        _phoneAutoFilled = true;
      }

      // suggest the registered name only if the user has not typed one
      final typedName = nameController.text.trim();
      if (found.name.isNotEmpty &&
          (typedName.isEmpty || nameController.text == _suggestedName)) {
        nameController.text = found.name;
        _suggestedName = found.name;
      }
    });
  }

  // the old result is gone: empty only what the lookup had filled
  void _onLookupCleared() {
    if (!mounted) return;
    setState(() {
      errorMessage = null;

      if (_phoneAutoFilled) {
        phoneController.clear();
        _phoneAutoFilled = false;
      }
      if (_suggestedName.isNotEmpty && nameController.text == _suggestedName) {
        nameController.clear();
      }
      _suggestedName = '';
    });
  }

  // ---------- SAVE ----------
  Future<void> _save() async {
    final provider = context.read<AddContactProvider>();
    if (provider.saving) return;

    final email = emailController.text.trim().toLowerCase();
    if (AddContactProvider.validateEmail(context.l10n, email) != null) {
      formKey.currentState!.validate(); // shows the red email message
      return;
    }

    setState(() => errorMessage = null);

    // The provider does the lookup and the save. It asks for the form only
    // after the lookup, because the lookup can fill the phone and the name.
    final error = await provider.save(
      email: email,
      readForm: () {
        if (!formKey.currentState!.validate()) return null;
        return ContactForm(
          name: nameController.text,
          phone: phoneController.text,
          countryCode: countryCode,
        );
      },
    );

    if (!mounted) return;
    if (error != null) setState(() => errorMessage = error);
  }

  InputDecoration decoration({
    required String label,
    IconData? icon,
    Widget? suffix,
    bool locked = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null
          ? null
          : Icon(
        icon,
        color: locked ? AppColors.textSoft : AppColors.emerald,
      ),
      suffixIcon: locked
          ? const Icon(AppIcons.locked, color: AppColors.textSoft, size: 20)
          : suffix,
      filled: true,
      fillColor: locked ? AppColors.lockedFill : AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
      ),
    );
  }

  // one line of text under the email box
  Widget _statusRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lookupStatus(AddContactProvider add) {
    final l = context.l10n;

    switch (add.state) {
      case LookupState.idle:
      case LookupState.loading:
        return const SizedBox.shrink();
      case LookupState.found:
        final found = add.found;
        if (found == null) return const SizedBox.shrink();
        if (!found.hasPhone) {
          return _statusRow(
            AppIcons.info,
            AppColors.textSoft,
            l.userFoundNoPhone,
          );
        }
        return _statusRow(
          AppIcons.found,
          AppColors.emerald,
          found.name.isEmpty ? l.userFound : l.userFoundName(found.name),
        );
      case LookupState.notFound:
        return _statusRow(AppIcons.error, AppColors.error, l.userNotFound);
      case LookupState.self:
        return _statusRow(AppIcons.error, AppColors.error, l.cannotAddSelf);
      case LookupState.error:
        return _statusRow(
          AppIcons.error,
          AppColors.error,
          add.lookupError ?? l.lookupFailed,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    // rebuilds whenever the provider changes (lookup state, saving...)
    final add = context.watch<AddContactProvider>();
    final isSaving = add.saving;
    final blocked = add.blocked;
    final phoneLocked = add.phoneLocked;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        title: Text(
          l.newContact,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: AppColors.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AppIcons.addContact,
                      color: AppColors.emerald,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  l.addContactTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  l.addContactSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 22),

                // Contact name (free text: the user can type any name)
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      AddContactProvider.validateName(context.l10n, value),
                  enabled: !isSaving,
                  decoration: decoration(
                    label: l.contactNameLabel,
                    icon: AppIcons.person,
                  ),
                ),
                const SizedBox(height: 18),

                // Registered email (the lookup starts when typing stops)
                TextFormField(
                  controller: emailController,
                  focusNode: emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  validator: (value) =>
                      AddContactProvider.validateEmail(context.l10n, value),
                  enabled: !isSaving,
                  onChanged: context.read<AddContactProvider>().onEmailChanged,
                  decoration: decoration(
                    label: l.registeredEmailLabel,
                    icon: AppIcons.email,
                    suffix: add.state == LookupState.loading
                        ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.emerald,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
                _lookupStatus(add),
                const SizedBox(height: 18),

                // Country code and phone number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 108,
                      child: CountryCodeDropdown(
                        value: countryCode,
                        decoration: decoration(label: l.code),
                        onChanged: (isSaving || phoneLocked)
                            ? null
                            : (value) => setState(() => countryCode = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        readOnly: phoneLocked,
                        enabled: !isSaving,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9\s()\-]'),
                          ),
                        ],
                        validator: (value) => phoneLocked
                            ? null
                            : PhoneHelper.validateLocalized(
                          context.l10n,
                          value,
                        ),
                        onFieldSubmitted: (_) {
                          if (!isSaving && !blocked) _save();
                        },
                        decoration: decoration(
                          label: l.phoneNumber,
                          icon: AppIcons.phone,
                          locked: phoneLocked,
                        ),
                      ),
                    ),
                  ],
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (isSaving || blocked) ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      disabledBackgroundColor: isSaving
                          ? AppColors.emerald
                          : AppColors.buttonDisabledGrey,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      l.saveContact,
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