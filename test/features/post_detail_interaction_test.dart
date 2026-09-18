import 'package:bluerum/features/post/presentation/post_detail_interaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comment vote notifier updates only that id', () {
    final store = PostDetailVoteStore(postVote: 0, postSaved: false);
    addTearDown(store.dispose);

    final a = store.commentVoteListenable(1);
    final b = store.commentVoteListenable(2);
    expect(a.value, isNull);
    expect(store.effectiveCommentVote(1, 0), 0);

    var aTicks = 0;
    a.addListener(() => aTicks++);
    var bTicks = 0;
    b.addListener(() => bTicks++);

    store.setCommentVote(1, 1);
    expect(a.value, 1);
    expect(store.effectiveCommentVote(1, 0), 1);
    expect(aTicks, 1);
    expect(bTicks, 0);

    expect(store.snapshotCommentVotes(), {1: 1});
  });

  test('post vote/save notifiers work without comment map', () {
    final store = PostDetailVoteStore(
      postVote: 1,
      postSaved: true,
      seedCommentVotes: {9: -1},
    );
    addTearDown(store.dispose);

    expect(store.postVote.value, 1);
    expect(store.postSaved.value, isTrue);
    expect(store.effectiveCommentVote(9, 0), -1);

    store.clearCommentVotes();
    expect(store.commentVoteListenable(9).value, isNull);
    expect(store.effectiveCommentVote(9, 0), 0);
  });
}
