abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const search = '/search';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const createPost = '/create-post';
  static const composeComment = '/compose-comment';
  static const settings = '/settings';
  static const removeAds = '/settings/remove-ads';
  static const saved = '/saved';
  static const blocks = '/settings/blocks';
  static const chatPath = '/chat/:personId';

  static String post(int id) => '/posts/$id';
  static String community(String name) => '/c/$name';
  static String user(String username) => '/u/$username';
  static String chat(int personId) => '/chat/$personId';
}
