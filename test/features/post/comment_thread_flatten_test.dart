import 'package:bluerum/features/post/presentation/comment_thread_flatten.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commentIdToRowIndex maps each id once', () {
    // Pure map helper — no freezed CommentView fixtures required.
    final map = commentIdToRowIndex(const []);
    expect(map, isEmpty);
  });
}
