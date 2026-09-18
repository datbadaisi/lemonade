import 'dart:typed_data';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bio = TextEditingController();
  final _email = TextEditingController();
  final _oldPassword = TextEditingController();
  final _password = TextEditingController();
  final _passwordVerify = TextEditingController();
  final _picker = ImagePicker();

  final _bioFocus = FocusNode();
  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;
  String? _bannerUrl;
  XFile? _avatarFile;
  XFile? _bannerFile;
  String? _displayName;

  LemmyApiService get _api => ref.read(lemmyApiClientProvider);

  @override
  void initState() {
    super.initState();
    _bioFocus.addListener(_onBioFocusChange);
    _loadProfile();
  }

  void _onBioFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _bioFocus.removeListener(_onBioFocusChange);
    _bioFocus.dispose();
    _bio.dispose();
    _email.dispose();
    _oldPassword.dispose();
    _password.dispose();
    _passwordVerify.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final site = await _api.fetchSiteInfo();
      final user = site.myUser?.localUserView;
      if (user != null && mounted) {
        _bio.text = user.person.bio ?? '';
        _email.text = user.localUser.email ?? '';
        setState(() {
          _avatarUrl = user.person.avatar;
          _bannerUrl = user.person.banner;
          _displayName = user.person.displayName?.isNotEmpty == true
              ? user.person.displayName
              : user.person.name;
        });
      }
    } catch (error) {
      if (mounted) _showMessage('Could not load profile: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage({required bool avatar}) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: avatar ? 1024 : 2048,
    );
    if (file != null && mounted) {
      setState(() {
        if (avatar) {
          _avatarFile = file;
        } else {
          _bannerFile = file;
        }
      });
    }
  }

  Future<String> _upload(XFile file) async => _api.uploadImage(
    await file.readAsBytes(),
    file.name,
    mimeType: file.mimeType,
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final changingPassword =
        _oldPassword.text.isNotEmpty ||
        _password.text.isNotEmpty ||
        _passwordVerify.text.isNotEmpty;
    if (changingPassword &&
        (_oldPassword.text.isEmpty ||
            _password.text.isEmpty ||
            _passwordVerify.text.isEmpty)) {
      _showMessage('Enter your current password and confirm the new password.');
      return;
    }
    if (changingPassword && _password.text != _passwordVerify.text) {
      _showMessage('New passwords do not match.');
      return;
    }

    setState(() => _saving = true);
    try {
      final avatar = _avatarFile == null
          ? _avatarUrl
          : await _upload(_avatarFile!);
      final banner = _bannerFile == null
          ? _bannerUrl
          : await _upload(_bannerFile!);
      await _api.saveUserSettings(
        bio: _bio.text.trim(),
        email: _email.text.trim(),
        avatar: avatar,
        banner: banner,
      );
      if (changingPassword) {
        final login = await _api.changePassword(
          oldPassword: _oldPassword.text,
          newPassword: _password.text,
          newPasswordVerify: _passwordVerify.text,
        );
        if (login.jwt?.isNotEmpty == true) {
          await ref.read(authRepositoryProvider).setJwt(login.jwt!, api: _api);
        }
      }
      await ref.read(authRepositoryProvider).refreshIdentity(_api);
      if (mounted) {
        _showMessage('Profile saved.');
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) _showMessage('Could not save profile: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Widget _buildSkeleton() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Profile Images Header Skeleton
        Stack(
          children: [
            const SizedBox(width: double.infinity, height: 171),
            Positioned.fill(
              bottom: 36,
              child: const Skeleton(height: 135, borderRadius: 0),
            ),
            Positioned(
              left: 16,
              top: 95,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Skeleton.circle(size: 70),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bio field skeleton
              const Skeleton(height: 14, width: 32),
              const SizedBox(height: 8),
              const Skeleton(height: 78, width: double.infinity, borderRadius: 12),
              const SizedBox(height: 20),
              // Email field skeleton
              const Skeleton(height: 14, width: 45),
              const SizedBox(height: 8),
              const Skeleton(height: 44, width: double.infinity, borderRadius: 12),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Help text skeleton
              const Skeleton(height: 12, width: 280),
              const SizedBox(height: 20),
              // Current password skeleton
              const Skeleton(height: 14, width: 110),
              const SizedBox(height: 8),
              const Skeleton(height: 44, width: double.infinity, borderRadius: 12),
              const SizedBox(height: 20),
              // New password skeleton
              const Skeleton(height: 14, width: 90),
              const SizedBox(height: 8),
              const Skeleton(height: 44, width: double.infinity, borderRadius: 12),
              const SizedBox(height: 20),
              // Confirm new password skeleton
              const Skeleton(height: 14, width: 140),
              const SizedBox(height: 8),
              const Skeleton(height: 44, width: double.infinity, borderRadius: 12),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageSourceSheet({required bool avatar}) {
    final hasImage = avatar
        ? (_avatarFile != null || (_avatarUrl != null && _avatarUrl!.isNotEmpty))
        : (_bannerFile != null || (_bannerUrl != null && _bannerUrl!.isNotEmpty));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_pic_line, color: AppColors.textPrimary),
              title: Text(
                avatar ? 'Change avatar' : 'Change banner',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(avatar: avatar);
              },
            ),
            if (hasImage) ...[
              ListTile(
                leading: const Icon(MingCuteIcons.mgc_delete_2_line, color: AppColors.danger),
                title: Text(
                  avatar ? 'Delete avatar' : 'Delete banner',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    if (avatar) {
                      _avatarFile = null;
                      _avatarUrl = '';
                    } else {
                      _bannerFile = null;
                      _bannerUrl = '';
                    }
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Changes',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        icon: const Icon(
          MingCuteIcons.mgc_left_line,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving || _loading ? null : _save,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            disabledForegroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
        ),
      ],
    ),
    body: _loading
        ? _buildSkeleton()
        : Form(
            key: _formKey,
            child: ListView(
              children: [
                _ProfileImages(
                  avatarFile: _avatarFile,
                  avatarUrl: _avatarUrl,
                  bannerFile: _bannerFile,
                  bannerUrl: _bannerUrl,
                  displayName: _displayName,
                  onAvatarTap: () => _showImageSourceSheet(avatar: true),
                  onBannerTap: () => _showImageSourceSheet(avatar: false),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(
                        controller: _bio,
                        focusNode: _bioFocus,
                        label: 'Bio',
                        hint: 'Tell people about yourself',
                        maxLines: _bioFocus.hasFocus ? null : 3,
                        maxLength: 300,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: _email,
                        label: 'Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          return email.isEmpty ||
                                  RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(email)
                              ? null
                              : 'Enter a valid email address.';
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leave these fields blank to keep your current password.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _passwordField(_oldPassword, 'Current password'),
                      const SizedBox(height: 12),
                      _passwordField(_password, 'New password'),
                      const SizedBox(height: 12),
                      _passwordField(_passwordVerify, 'Confirm new password'),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    FocusNode? focusNode,
  }) => _LabeledField(
    label: label,
    child: TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
        height: 1.45,
      ),
      decoration: _decoration(hint),
    ),
  );

  Widget _passwordField(TextEditingController controller, String label) =>
      _LabeledField(
        label: label,
        child: TextFormField(
          controller: controller,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: _decoration('Password'),
        ),
      );

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0x66525252)),
      counterStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 4),
      child,
    ],
  );
}

class _ProfileImages extends StatelessWidget {
  const _ProfileImages({
    required this.avatarFile,
    required this.avatarUrl,
    required this.bannerFile,
    required this.bannerUrl,
    required this.onAvatarTap,
    required this.onBannerTap,
    this.displayName,
  });
  final XFile? avatarFile;
  final String? avatarUrl;
  final XFile? bannerFile;
  final String? bannerUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onBannerTap;
  final String? displayName;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const SizedBox(width: double.infinity, height: 171),
      Positioned.fill(
        bottom: 36,
        child: _ImageSurface(
          file: bannerFile,
          imageUrl: bannerUrl,
          isAvatar: false,
          onTap: onBannerTap,
          displayName: displayName,
        ),
      ),
      Positioned(
        left: 16,
        top: 95,
        child: _ImageSurface(
          file: avatarFile,
          imageUrl: avatarUrl,
          isAvatar: true,
          onTap: onAvatarTap,
          displayName: displayName,
        ),
      ),
    ],
  );
}

class _ImageSurface extends StatelessWidget {
  const _ImageSurface({
    required this.file,
    required this.imageUrl,
    required this.isAvatar,
    required this.onTap,
    this.displayName,
  });
  final XFile? file;
  final String? imageUrl;
  final bool isAvatar;
  final VoidCallback onTap;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(isAvatar ? 999 : 0);
    final placeholder = isAvatar
        ? _buildLetterAvatar(displayName ?? '?', 76)
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          );

    // Avatar: square slot + cover crop (same rules as [NetworkAvatar]).
    // Local picks still use Image.memory; remote avatars go through NetworkAvatar.
    final Widget surface;
    if (file != null) {
      surface = FutureBuilder<Uint8List>(
        future: file!.readAsBytes(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return placeholder;
          return Image.memory(
            snapshot.data!,
            width: isAvatar ? 76 : null,
            height: isAvatar ? 76 : null,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            gaplessPlayback: true,
          );
        },
      );
    } else if (imageUrl?.isNotEmpty == true) {
      if (isAvatar) {
        surface = NetworkAvatar(
          size: 70,
          imageUrl: imageUrl,
          name: displayName,
          fallback: placeholder,
        );
      } else {
        surface = CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          placeholder: (_, _) => const ShimmerPlaceholder(
            shape: BoxShape.rectangle,
          ),
          errorWidget: (_, _, _) => placeholder,
        );
      }
    } else {
      surface = placeholder;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isAvatar ? 76 : double.infinity,
        height: isAvatar ? 76 : 135,
        decoration: BoxDecoration(
          // Solid fill for avatar ring so the banner never bleeds through
          // while the image / skeleton is resolving.
          color: isAvatar ? Colors.white : null,
          borderRadius: radius,
          border: isAvatar ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isAvatar
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: isAvatar
              ? Center(child: surface)
              : Stack(
                  fit: StackFit.expand,
                  children: [surface],
                ),
        ),
      ),
    );
  }

  Widget _buildLetterAvatar(String name, double size) {
    final trimmed = name.trim();
    String letter;
    if (trimmed.isNotEmpty) {
      final first = trimmed.characters.first;
      letter = first.isNotEmpty ? first.toUpperCase() : '?';
    } else {
      letter = '?';
    }
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
