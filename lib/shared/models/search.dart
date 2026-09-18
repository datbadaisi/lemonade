import 'package:freezed_annotation/freezed_annotation.dart';

import 'comment.dart';
import 'post.dart';
import 'site.dart';

part 'search.freezed.dart';
part 'search.g.dart';

@Freezed(toJson: false)
abstract class SearchResult with _$SearchResult {
  const factory SearchResult({
    @JsonKey(name: 'type_', defaultValue: 'All') @Default('All') String type,
    @Default(<PostView>[]) List<PostView> posts,
    @Default(<CommentView>[]) List<CommentView> comments,
    @Default(<CommunityView>[]) List<CommunityView> communities,
    @Default(<PersonView>[]) List<PersonView> users,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
