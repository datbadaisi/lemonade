import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ming_cute_icons/ming_cute_icons.dart';

/// Public Google Form used to collect app feedback.
const _formActionUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSekUFLVvpq0b3SIebLzut8__AtCQKaPon3iNW7WsosbMZAwtw/formResponse';

/// Entry id for the single "Feedback" question on the form.
const _feedbackEntryId = 'entry.2047256793';

/// Same ballpark as Reddit comment length (characters, not words).
const int kFeedbackMaxLength = 10000;

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSend {
    final text = _controller.text.trim();
    return !_sending &&
        text.isNotEmpty &&
        text.length <= kFeedbackMaxLength;
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _sending) return;
    if (message.length > kFeedbackMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Feedback must be at most $kFeedbackMaxLength characters',
          ),
        ),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final auth = ref.read(authRepositoryProvider);
      final username = auth.username;
      final instanceUrl = auth.instanceUrl;
      final buffer = StringBuffer();
      if (username != null && username.isNotEmpty) {
        final host = instanceUrl == null
            ? null
            : Uri.tryParse(instanceUrl)?.host;
        buffer.writeln(
          host != null && host.isNotEmpty
              ? 'From: $username@$host'
              : 'From: $username',
        );
        buffer.writeln();
      }
      buffer.write(message);

      final response = await http.post(
        Uri.parse(_formActionUrl),
        headers: const {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {_feedbackEntryId: buffer.toString()},
      );

      // Google Forms returns 200 on success; some clients also see 302.
      if (response.statusCode != 200 &&
          response.statusCode != 302 &&
          response.statusCode != 0) {
        throw Exception('HTTP ${response.statusCode}');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks — your feedback was sent.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send feedback. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            MingCuteIcons.mgc_left_line,
            color: AppColors.textPrimary,
          ),
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _canSend ? _submit : null,
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Send',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _canSend
                            ? AppColors.action
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Share a bug, idea, or anything that would make Lemonade better.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                maxLength: kFeedbackMaxLength,
                textAlignVertical: TextAlignVertical.top,
                enabled: !_sending,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write your feedback…',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
