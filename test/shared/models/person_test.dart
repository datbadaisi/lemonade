import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Person preserves Lemmy defaults and display name fallback', () {
    final person = Person.fromJson(const {
      'id': '7',
      'name': 'alice',
      'display_name': 'Alice',
      'instance_id': '2',
    });

    expect(person.id, 7);
    expect(person.instanceId, 2);
    expect(person.displayNameOrName, 'Alice');
    expect(person.local, isTrue);
    expect(person.botAccount, isFalse);
  });
}
