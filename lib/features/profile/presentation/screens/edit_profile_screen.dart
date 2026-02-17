import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vamigo/core/l10n/l10n_extension.dart';
import 'package:vamigo/core/providers/auth_notifier.dart';
import 'package:vamigo/core/widgets/core_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).currentUser;
    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).updateProfile(
          displayName: _displayNameController.text.trim(),
          bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileUpdatedSuccess)),
      );
      Navigator.pop(context);
    } else {
      final errorMessage = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? context.l10n.failedToUpdateProfile)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
      ),
      body: PageLayout.form(
        child: FormSurface(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _displayNameController,
                    label: context.l10n.displayNameLabel,
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.displayNameRequired;
                      }
                      if (value.trim().length < 2) {
                        return context.l10n.displayNameMinLength;
                      }
                      return null;
                    },
                  ),
                  AppTextField(
                    controller: _phoneController,
                    label: context.l10n.phoneNumberLabel,
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    hint: context.l10n.phoneHint,
                  ),
                  AppTextField(
                    controller: _bioController,
                    label: context.l10n.bioLabel,
                    prefixIcon: Icons.info_outline,
                    hint: context.l10n.bioHint,
                    maxLines: 4,
                    minLines: 2,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    onPressed: _saveProfile,
                    isLoading: _isLoading,
                    width: double.infinity,
                    child: Text(context.l10n.saveChanges),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
