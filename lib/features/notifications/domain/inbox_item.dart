import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/post.dart';

/// Unified notification inbox row (reply or mention).
///
/// Wire models stay as freezed Lemmy DTOs; this projection deletes dual
/// `List<dynamic>` + `is CommentReplyView` trees from presentation.
sealed class InboxItem {
  const InboxItem();

  /// Stable list key for [ValueKey] / [ListIndexMap].
  String get listKey;

  /// Notification id (reply id or mention id), not comment id.
  int get notificationId;

  DateTime get publishedAt;
  bool get isRead;
  String get typeLabel;

  Comment get comment;
  Person get creator;
  Post get post;
  Community get community;
  CommentAggregates get counts;
  bool get creatorBannedFromCommunity;
  bool get bannedFromCommunity;
  bool get creatorIsModerator;
  bool get creatorIsAdmin;
  String get subscribed;
  bool get saved;
  bool get creatorBlocked;
  int? get myVote;

  InboxItem markRead();

  CommentView toCommentView() => CommentView(
        comment: comment,
        creator: creator,
        community: community,
        post: post,
        counts: counts,
        creatorBannedFromCommunity: creatorBannedFromCommunity,
        bannedFromCommunity: bannedFromCommunity,
        creatorIsModerator: creatorIsModerator,
        creatorIsAdmin: creatorIsAdmin,
        subscribed: subscribed,
        saved: saved,
        creatorBlocked: creatorBlocked,
        myVote: myVote,
      );

  static InboxItem reply(CommentReplyView view) => InboxReply(view);
  static InboxItem mention(PersonMentionView view) => InboxMention(view);

  static DateTime parsePublished(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return parsed.isUtc ? parsed : parsed.toUtc();
  }
}

final class InboxReply extends InboxItem {
  const InboxReply(this.view);

  final CommentReplyView view;

  @override
  String get listKey => 'r_${view.commentReply.id}';

  @override
  int get notificationId => view.commentReply.id;

  @override
  DateTime get publishedAt => InboxItem.parsePublished(view.commentReply.published);

  @override
  bool get isRead => view.commentReply.read;

  @override
  String get typeLabel => view.comment.parentId == null
      ? 'replied to your post'
      : 'replied to your comment';

  @override
  Comment get comment => view.comment;

  @override
  Person get creator => view.creator;

  @override
  Post get post => view.post;

  @override
  Community get community => view.community;

  @override
  CommentAggregates get counts => view.counts;

  @override
  bool get creatorBannedFromCommunity => view.creatorBannedFromCommunity;

  @override
  bool get bannedFromCommunity => view.bannedFromCommunity;

  @override
  bool get creatorIsModerator => view.creatorIsModerator;

  @override
  bool get creatorIsAdmin => view.creatorIsAdmin;

  @override
  String get subscribed => view.subscribed;

  @override
  bool get saved => view.saved;

  @override
  bool get creatorBlocked => view.creatorBlocked;

  @override
  int? get myVote => view.myVote;

  @override
  InboxReply markRead() {
    if (view.commentReply.read) return this;
    return InboxReply(
      view.copyWith(
        commentReply: view.commentReply.copyWith(read: true),
      ),
    );
  }
}

final class InboxMention extends InboxItem {
  const InboxMention(this.view);

  final PersonMentionView view;

  @override
  String get listKey => 'm_${view.personMention.id}';

  @override
  int get notificationId => view.personMention.id;

  @override
  DateTime get publishedAt =>
      InboxItem.parsePublished(view.personMention.published);

  @override
  bool get isRead => view.personMention.read;

  @override
  String get typeLabel => 'mentioned you in a comment';

  @override
  Comment get comment => view.comment;

  @override
  Person get creator => view.creator;

  @override
  Post get post => view.post;

  @override
  Community get community => view.community;

  @override
  CommentAggregates get counts => view.counts;

  @override
  bool get creatorBannedFromCommunity => view.creatorBannedFromCommunity;

  @override
  bool get bannedFromCommunity => view.bannedFromCommunity;

  @override
  bool get creatorIsModerator => view.creatorIsModerator;

  @override
  bool get creatorIsAdmin => view.creatorIsAdmin;

  @override
  String get subscribed => view.subscribed;

  @override
  bool get saved => view.saved;

  @override
  bool get creatorBlocked => view.creatorBlocked;

  @override
  int? get myVote => view.myVote;

  @override
  InboxMention markRead() {
    if (view.personMention.read) return this;
    return InboxMention(
      view.copyWith(
        personMention: view.personMention.copyWith(read: true),
      ),
    );
  }
}
