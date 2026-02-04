import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blablafront/core/providers/auth_notifier.dart';
import 'package:blablafront/core/widgets/core_widgets.dart';

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
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else {
      final errorMessage = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _displayNameController,
                label: 'Display Name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Display name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                hint: 'Enter your phone number (optional)',
              ),
              AppTextField(
                controller: _bioController,
                label: 'Bio',
                prefixIcon: Icons.info_outline,
                hint: 'Tell others about yourself (optional)',
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _saveProfile,
                isLoading: _isLoading,
                width: double.infinity,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
