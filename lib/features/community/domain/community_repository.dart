import 'package:bluerum/shared/models/post.dart';

abstract interface class CommunityRepository {
  Future<CommunityView> get({int? id, String? name});
  Future<CommunityView> follow({required int communityId, required bool follow});
  Future<bool> block({required int communityId, required bool block});
}
