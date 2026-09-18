import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  /// When true, the screen is used to add another account while already signed
  /// in. Credentials are left blank so the user can enter any instance/user.
  const LoginScreen({super.key, this.isAddingAccount = false});

  final bool isAddingAccount;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _instanceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final initialUrl = ref.read(authControllerProvider).instanceUrl;
    if (initialUrl.startsWith('https://')) {
      _instanceController.text = initialUrl.substring(8);
    } else if (initialUrl.startsWith('http://')) {
      _instanceController.text = initialUrl.substring(7);
    } else {
      _instanceController.text = initialUrl;
    }
    // Adding an account: leave username/password empty so any instance/user
    // can be entered. Instance is prefilled with the current one as a hint.
  }

  @override
  void dispose() {
    _instanceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _normaliseInstanceUrl() {
    final url = _instanceController.text.trim();
    final normalised = !url.startsWith('http://') && !url.startsWith('https://')
        ? 'https://$url'
        : url;
    final clean = normalised.endsWith('/')
        ? normalised.substring(0, normalised.length - 1)
        : normalised;
    return clean;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final instance = _instanceController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (instance.isEmpty) {
      _showSnack('Enter an instance URL');
      return;
    }
    if (username.isEmpty) {
      _showSnack('Enter your username or email');
      return;
    }
    if (password.isEmpty) {
      _showSnack('Enter your password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authControllerProvider.notifier);
      await auth.login(
        usernameOrEmail: username,
        password: password,
        instanceUrl: _normaliseInstanceUrl(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on LemmyApiException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Connection failed. Check your instance URL.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isAddingAccount ? 'Add account' : 'Log in',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            MingCuteIcons.mgc_left_line,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Instance URL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _instanceController,
                        decoration:
                            _inputDecoration(hint: 'lemmy.world'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.center,
                        autocorrect: false,
                        style: _fieldTextStyle,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        decoration:
                            _inputDecoration(hint: 'Username or email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.center,
                        autocorrect: false,
                        style: _fieldTextStyle,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        decoration: _inputDecoration(hint: 'Password'),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        onSubmitted: (_) => _handleLogin(),
                        style: _fieldTextStyle,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            disabledBackgroundColor:
                                AppColors.accent.withValues(alpha: 0.45),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : Text(
                                  widget.isAddingAccount
                                      ? 'Add account'
                                      : 'Log in',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static const _fieldTextStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF000000),
  );

  InputDecoration _inputDecoration({required String hint}) {
    final radius = BorderRadius.circular(24);
    final noBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Color(0x66525252),
      ),
      filled: true,
      fillColor: const Color(0xFFE8E8E8),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: noBorder,
      enabledBorder: noBorder,
      focusedBorder: noBorder,
      disabledBorder: noBorder,
    );
  }
}
