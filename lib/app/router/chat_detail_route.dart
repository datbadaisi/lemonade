import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'package:bluerum/features/chat/presentation/chat_detail_screen.dart';

final class ChatDetailRoute extends ConsumerWidget {
  const ChatDetailRoute({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(_chatPersonProvider(personId));
    return person.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(_chatPersonProvider(personId)),
            child: Text('Unable to load this chat: $error')))),
      data: (otherPerson) =>
          ChatDetailScreen(otherPerson: otherPerson, initialMessages: const []));
  }
}

final _chatPersonProvider = FutureProvider.autoDispose.family((
  ref,
  int id) async {
  final response = await ref
      .watch(lemmyApiClientProvider)
      .getPersonDetails(personId: id, limit: 1);
  return response.personView.person;
});
