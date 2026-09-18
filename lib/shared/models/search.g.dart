// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchResult _$SearchResultFromJson(Map<String, dynamic> json) =>
    _SearchResult(
      type: json['type_'] as String? ?? 'All',
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => PostView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PostView>[],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CommentView>[],
      communities:
          (json['communities'] as List<dynamic>?)
              ?.map((e) => CommunityView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CommunityView>[],
      users:
          (json['users'] as List<dynamic>?)
              ?.map((e) => PersonView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PersonView>[],
    );
