import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
import '../data/profile_api_client.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.profile.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.profile.lastName ?? '',
    );
    _phoneController = TextEditingController(
      text: _editablePhone(widget.profile.phone),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _editablePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '';
    }

    if (phone.startsWith('+61') && phone.length == 12) {
      return '0${phone.substring(3)}';
    }

    return phone;
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedProfile =
          await AppServices.profileApiClient.updateCurrentUser(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(updatedProfile);
    } on ProfileApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Unable to update your profile. Please check your connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        enabled: !_isSaving,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        enabled: !_isSaving,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: widget.profile.email,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          helperText:
                              'Email changes will be handled separately.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _save(),
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: '0412 345 678',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile number is required.';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Changes',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
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
