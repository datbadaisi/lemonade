import 'package:bluerum/shared/models/post.dart';

import 'community_repository.dart';

/// Load entry used by community detail presentation.
Future<CommunityView> loadCommunity(
  CommunityRepository repository, {
  int? id,
  String? name,
}) => repository.get(id: id, name: name);
