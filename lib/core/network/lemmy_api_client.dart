// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'timeout_http_client.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/models/auth.dart';
import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/search.dart';

export '../../shared/models/comment.dart'
    show
        Comment,
        CommentView,
        CommentAggregates,
        CommentSortType,
        CommentResponse,
        GetCommentsResponse,
        GetCommentsParams,
        CreateCommentBody,
        CreateCommentLike,
        SaveCommentBody,
        EditCommentBody,
        DeleteCommentBody;
export '../../shared/models/auth.dart' show LoginResponse;

class LemmyApiService {
  String baseUrl;
  final http.Client _client;
  String? _authToken;

  static const Duration _defaultTimeout = Duration(seconds: 30);

  LemmyApiService({required String baseUrl, http.Client? client})
    : baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
      _client = TimeoutHttpClient(client ?? http.Client(), _defaultTimeout);

  String get apiUrl => '$baseUrl/api/v3';

  /// Set the JWT auth token for authenticated requests.
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Update the active Lemmy instance without constructing a second client.
  /// The provider owns this lifecycle and updates both URL and credentials on
  /// authentication or instance changes.
  void setBaseUrl(String url) {
    baseUrl = url.replaceFirst(RegExp(r'/$'), '');
  }

  /// Build headers with optional auth token.
  Map<String, String> _headers({bool withAuth = false, bool isGet = false}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (!isGet) {
      headers['Content-Type'] = 'application/json';
    }
    if (withAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ── Auth ──

  /// Log into a Lemmy instance.
  Future<LoginResponse> login({
    required String usernameOrEmail,
    required String password,
    String? totpToken,
  }) async {
    final body = <String, dynamic>{
      'username_or_email': usernameOrEmail,
      'password': password,
    };
    if (totpToken != null) body['totp_2fa_token'] = totpToken;

    final response = await _client.post(
      Uri.parse('$apiUrl/user/login'),
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return LoginResponse.fromJson(json);
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ?? 'Login failed: ${response.statusCode}',
      );
    }
  }

  // ── Site ──

  /// Update the signed-in user's profile and account settings.
  ///
  /// Omitted fields are left unchanged.
  Future<void> saveUserSettings({
    String? bio,
    String? email,
    String? avatar,
    String? banner,
  }) async {
    final body = <String, dynamic>{};
    if (bio != null) body['bio'] = bio;
    if (email != null) body['email'] = email;
    if (avatar != null) body['avatar'] = avatar;
    if (banner != null) body['banner'] = banner;
    final response = await _client.put(
      Uri.parse('$apiUrl/user/save_user_settings'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Failed to save profile: ${response.statusCode}';
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        message = json['error']?.toString() ?? message;
      } catch (_) {
        // Some instances return a non-JSON error response.
      }
      throw LemmyApiException(message);
    }
  }

  /// Change the signed-in user's password.
  ///
  /// The API returns a login response because instances may rotate the JWT
  /// after a password change.
  Future<LoginResponse> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordVerify,
  }) async {
    final response = await _client.put(
      Uri.parse('$apiUrl/user/change_password'),
      headers: _headers(withAuth: true),
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_verify': newPasswordVerify,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    String message = 'Failed to change password: ${response.statusCode}';
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      message = json['error']?.toString() ?? message;
    } catch (_) {
      // Some instances return a non-JSON error response.
    }
    throw LemmyApiException(message);
  }

  Future<GetSiteResponse> getSite() async {
    final response = await _client.get(
      Uri.parse('$apiUrl/site'),
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GetSiteResponse.fromJson(
        json['site_view'] != null
            ? json
            : {'site_view': json, 'admins': [], 'version': ''},
      );
    } else {
      throw LemmyApiException('Failed to get site: ${response.statusCode}');
    }
  }

  Future<GetSiteResponse> fetchSiteInfo() async {
    final response = await _client.get(
      Uri.parse('$apiUrl/site'),
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GetSiteResponse.fromJson(json);
    } else {
      throw LemmyApiException(
        'Failed to fetch site info: ${response.statusCode}',
      );
    }
  }

  // ── Person details ──

  /// Get user's posts, comments, and profile info.
  Future<GetPersonDetailsResponse> getPersonDetails({
    int? personId,
    String? username,
    String? sort,
    int? page,
    int limit = 20,
    bool savedOnly = false,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'saved_only': savedOnly.toString(),
    };
    if (personId != null) queryParams['person_id'] = personId.toString();
    if (username != null) queryParams['username'] = username;
    if (sort != null) queryParams['sort'] = sort;
    if (page != null) queryParams['page'] = page.toString();

    final uri = Uri.parse('$apiUrl/user').replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GetPersonDetailsResponse.fromJson(json);
    } else {
      throw LemmyApiException(
        'Failed to get person details: ${response.statusCode}',
      );
    }
  }

  /// Search for users on Lemmy instance.
  Future<List<PersonView>> searchUsers({
    required String query,
    int? limit,
    int? page,
  }) async {
    final queryParams = <String, String>{'q': query, 'type_': 'Users'};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (page != null) queryParams['page'] = page.toString();

    final uri = Uri.parse(
      '$apiUrl/search',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final usersJson = json['users'] as List<dynamic>? ?? [];
      return usersJson
          .map((u) => PersonView.fromJson(u as Map<String, dynamic>))
          .toList();
    } else {
      throw LemmyApiException('Failed to search users: ${response.statusCode}');
    }
  }

  // ── Posts ──

  Future<List<PostView>> getPosts({
    String sort = 'Active',
    String type = 'All',
    int limit = 20,
    int? page,
    int? communityId,
    String? communityName,
  }) async {
    final queryParams = {
      'sort': sort,
      'type_': type,
      'limit': limit.toString(),
    };
    if (page != null) queryParams['page'] = page.toString();
    if (communityId != null) {
      queryParams['community_id'] = communityId.toString();
    }
    if (communityName != null) queryParams['community_name'] = communityName;

    final uri = Uri.parse(
      '$apiUrl/post/list',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final postsJson = json['posts'] as List<dynamic>? ?? [];
      return postsJson
          .map((p) => PostView.fromJson(p as Map<String, dynamic>))
          .toList();
    } else {
      throw LemmyApiException('Failed to get posts: ${response.statusCode}');
    }
  }

  Future<PostView> getPost(int postId) async {
    final uri = Uri.parse(
      '$apiUrl/post',
    ).replace(queryParameters: {'id': postId.toString()});
    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostView.fromJson(json['post_view'] as Map<String, dynamic>);
    } else {
      throw LemmyApiException('Failed to get post: ${response.statusCode}');
    }
  }

  // ── Vote / Save Post ──

  /// Like / unlike a post. `score`: 1 (upvote), -1 (downvote), 0 (remove vote).
  Future<PostView> likePost({required int postId, required int score}) async {
    final body = <String, dynamic>{'post_id': postId, 'score': score};

    final response = await _client.post(
      Uri.parse('$apiUrl/post/like'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostView.fromJson(json['post_view'] as Map<String, dynamic>);
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ?? 'Like failed: ${response.statusCode}',
      );
    }
  }

  /// Save / unsave a post.
  Future<PostView> savePost({required int postId, required bool save}) async {
    final body = <String, dynamic>{'post_id': postId, 'save': save};

    final response = await _client.put(
      Uri.parse('$apiUrl/post/save'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostView.fromJson(json['post_view'] as Map<String, dynamic>);
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ?? 'Save failed: ${response.statusCode}',
      );
    }
  }

  /// Mark posts as read / unread.
  ///
  /// OpenAPI: POST /post/mark_as_read — body [MarkPostAsRead]
  /// `{ post_ids: number[], read: boolean }`. Response is empty 200 OK.
  Future<void> markPostAsRead({
    required List<int> postIds,
    required bool read,
  }) async {
    final body = <String, dynamic>{'post_ids': postIds, 'read': read};

    final response = await _client.post(
      Uri.parse('$apiUrl/post/mark_as_read'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      String message = 'Mark as read failed: ${response.statusCode}';
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        message = json['error']?.toString() ?? message;
      } catch (_) {}
      throw LemmyApiException(message);
    }
  }

  // ── Comments ──────────────────────────────────────────────────────────────
  //
  // All comment endpoints are modelled directly from openapi.json v0.19.11.
  //
  //  GET  /comment/list  → GetCommentsResponse  { comments: CommentView[] }
  //  POST /comment       → CommentResponse      { comment_view, recipient_ids }
  //  PUT  /comment       → CommentResponse
  //  POST /comment/like  → CommentResponse      (CreateCommentLike body)
  //  PUT  /comment/save  → CommentResponse      (SaveComment body)

  /// Fetch comments for a post.
  ///
  /// Uses [GetCommentsParams] which maps 1-to-1 to the OpenAPI `GetComments`
  /// query-parameter schema.
  Future<List<CommentView>> getComments({
    required int postId,
    CommentSortType? sort,
    int? page,
    int? limit,
    int? maxDepth,
    int? parentId,
    String? type = 'All',
  }) async {
    final params = GetCommentsParams(
      postId: postId,
      sort: sort,
      page: page,
      limit: limit,
      maxDepth: maxDepth,
      parentId: parentId,
      type: type,
    );

    final uri = Uri.parse(
      '$apiUrl/comment/list',
    ).replace(queryParameters: params.toQueryParameters());

    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GetCommentsResponse.fromJson(json).comments;
    } else {
      throw LemmyApiException('Failed to get comments: ${response.statusCode}');
    }
  }

  /// Fetch a single comment by ID.
  ///
  /// Maps to `GET /comment` with `id` query parameter.
  /// Returns the `CommentView` extracted from the `CommentResponse` envelope.
  Future<CommentView> getComment(int commentId) async {
    final uri = Uri.parse(
      '$apiUrl/comment',
    ).replace(queryParameters: {'id': commentId.toString()});

    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommentResponse.fromJson(json).commentView;
    } else {
      throw LemmyApiException('Failed to get comment: ${response.statusCode}');
    }
  }

  /// Create a new comment.
  ///
  /// Maps to `POST /comment` with `CreateComment` body.
  /// Returns the `CommentView` extracted from the `CommentResponse` envelope.
  Future<CommentView> createComment({
    required int postId,
    required String content,
    int? parentId,
    int? languageId,
  }) async {
    final body = CreateCommentBody(
      postId: postId,
      content: content,
      parentId: parentId,
      languageId: languageId,
    );

    final response = await _client.post(
      Uri.parse('$apiUrl/comment'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommentResponse.fromJson(json).commentView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Create comment failed: ${response.statusCode}',
      );
    }
  }

  /// Vote on a comment. `score`: 1 (upvote), -1 (downvote), 0 (remove vote).
  ///
  /// Maps to `POST /comment/like` with `CreateCommentLike` body.
  /// Returns the `CommentView` extracted from the `CommentResponse` envelope.
  Future<CommentView> likeComment({
    required int commentId,
    required int score,
  }) async {
    final body = CreateCommentLike(commentId: commentId, score: score);

    final response = await _client.post(
      Uri.parse('$apiUrl/comment/like'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommentResponse.fromJson(json).commentView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Like comment failed: ${response.statusCode}',
      );
    }
  }

  /// Save / unsave a comment.
  ///
  /// Maps to `PUT /comment/save` with `SaveComment` body.
  /// Returns the `CommentView` extracted from the `CommentResponse` envelope.
  Future<CommentView> saveComment({
    required int commentId,
    required bool save,
  }) async {
    final body = SaveCommentBody(commentId: commentId, save: save);

    final response = await _client.put(
      Uri.parse('$apiUrl/comment/save'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommentResponse.fromJson(json).commentView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Save comment failed: ${response.statusCode}',
      );
    }
  }

  /// Edit a comment.
  ///
  /// Maps to `PUT /comment` with `EditComment` body.
  /// Returns the `CommentView` extracted from the `CommentResponse` envelope.
  Future<CommentView> editComment({
    required int commentId,
    String? content,
  }) async {
    final body = EditCommentBody(commentId: commentId, content: content);

    final response = await _client.put(
      Uri.parse('$apiUrl/comment'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommentResponse.fromJson(json).commentView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Edit comment failed: ${response.statusCode}',
      );
    }
  }

  /// Delete a comment.
  ///
  /// Maps to `POST /comment/delete` with `DeleteComment` body.
  /// Returns the `CommentView` extracted from the `CommentResponse` envelope.
  Future<CommentView> deleteComment({
    required int commentId,
    required bool deleted,
  }) async {
    final body = DeleteCommentBody(commentId: commentId, deleted: deleted);

    final response = await _client.post(
      Uri.parse('$apiUrl/comment/delete'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommentResponse.fromJson(json).commentView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Delete comment failed: ${response.statusCode}',
      );
    }
  }

  /// Create a new post.
  ///
  /// Maps to `POST /post` with `CreatePost` body.
  /// Returns the `PostView` extracted from the `PostResponse` envelope.
  Future<PostView> createPost({
    required String name,
    required int communityId,
    String? body,
    String? url,
    bool? nsfw,
    int? languageId,
    String? altText,
    String? customThumbnail,
  }) async {
    final requestBody = CreatePostBody(
      name: name,
      communityId: communityId,
      body: body,
      url: url,
      nsfw: nsfw,
      languageId: languageId,
      altText: altText,
      customThumbnail: customThumbnail,
    );

    final response = await _client.post(
      Uri.parse('$apiUrl/post'),
      headers: _headers(withAuth: true),
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostResponse.fromJson(json).postView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Create post failed: ${response.statusCode}',
      );
    }
  }

  /// Edit an existing post.
  ///
  /// Maps to `PUT /post` with `EditPost` body.
  /// Returns the `PostView` extracted from the `PostResponse` envelope.
  Future<PostView> editPost({
    required int postId,
    String? name,
    String? body,
    String? url,
    bool? nsfw,
    int? languageId,
    String? altText,
    String? customThumbnail,
  }) async {
    final requestBody = EditPostBody(
      postId: postId,
      name: name,
      body: body,
      url: url,
      nsfw: nsfw,
      languageId: languageId,
      altText: altText,
      customThumbnail: customThumbnail,
    );

    final response = await _client.put(
      Uri.parse('$apiUrl/post'),
      headers: _headers(withAuth: true),
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostResponse.fromJson(json).postView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ?? 'Edit post failed: ${response.statusCode}',
      );
    }
  }

  /// Soft-delete or restore a post.
  ///
  /// Maps to `POST /post/delete` with `DeletePost` body.
  /// Returns the `PostView` extracted from the `PostResponse` envelope.
  Future<PostView> deletePost({
    required int postId,
    required bool deleted,
  }) async {
    final requestBody = DeletePostBody(postId: postId, deleted: deleted);

    final response = await _client.post(
      Uri.parse('$apiUrl/post/delete'),
      headers: _headers(withAuth: true),
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostResponse.fromJson(json).postView;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Delete post failed: ${response.statusCode}',
      );
    }
  }

  /// Upload an image to the Lemmy instance's pict-rs service.
  /// Returns the full URL of the uploaded image.
  Future<String> uploadImage(
    List<int> bytes,
    String filename, {
    String? mimeType,
    void Function(void Function())? onCancelReady,
  }) async {
    final uri = Uri.parse('$baseUrl/pictrs/image');
    final request = http.MultipartRequest('POST', uri);

    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'images[]',
      bytes,
      filename: filename,
      contentType: mimeType == null ? null : MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    final uploadClient = http.Client();
    onCancelReady?.call(uploadClient.close);
    try {
      final streamedResponse = await uploadClient
          .send(request)
          .timeout(
            const Duration(minutes: 5),
            onTimeout: () =>
                throw http.ClientException('Upload timed out after 5 minutes'),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final files = json['files'] as List<dynamic>?;
        if (files != null && files.isNotEmpty) {
          final file = files[0]['file'] as String?;
          if (file != null) {
            return '$baseUrl/pictrs/image/$file';
          }
        }
        throw LemmyApiException('Invalid response from image hosting service');
      } else {
        throw LemmyApiException(
          'Failed to upload image: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } finally {
      uploadClient.close();
    }
  }

  // ── Notifications & Messaging ──────────────────────────────────────────────

  /// Get unread notification counts (replies, mentions, private messages).
  Future<GetUnreadCountResponse> getUnreadCount() async {
    final queryParams = <String, String>{};
    if (_authToken != null) {
      queryParams['auth'] = _authToken!;
    }
    final uri = Uri.parse(
      '$apiUrl/user/unread_count',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: _headers(withAuth: true, isGet: true),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GetUnreadCountResponse.fromJson(json);
    } else {
      throw LemmyApiException(
        'Failed to get unread counts: ${response.statusCode}',
      );
    }
  }

  /// Get comment replies.
  Future<List<CommentReplyView>> getReplies({
    bool? unreadOnly,
    int? page,
    int? limit,
    String? sort = 'New',
  }) async {
    final queryParams = <String, String>{};
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (sort != null) queryParams['sort'] = sort;
    if (_authToken != null) {
      queryParams['auth'] = _authToken!;
    }

    final uri = Uri.parse(
      '$apiUrl/user/replies',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: _headers(withAuth: true, isGet: true),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['replies'] as List<dynamic>? ?? [];
      return list
          .map((e) => CommentReplyView.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw LemmyApiException('Failed to get replies: ${response.statusCode}');
    }
  }

  /// Get user mentions.
  Future<List<PersonMentionView>> getMentions({
    bool? unreadOnly,
    int? page,
    int? limit,
    String? sort = 'New',
  }) async {
    final queryParams = <String, String>{};
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (sort != null) queryParams['sort'] = sort;
    if (_authToken != null) {
      queryParams['auth'] = _authToken!;
    }

    final uri = Uri.parse(
      '$apiUrl/user/mention',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: _headers(withAuth: true, isGet: true),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['mentions'] as List<dynamic>? ?? [];
      return list
          .map((e) => PersonMentionView.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw LemmyApiException('Failed to get mentions: ${response.statusCode}');
    }
  }

  /// Mark all replies and mentions as read.
  Future<void> markAllAsRead() async {
    final response = await _client.post(
      Uri.parse('$apiUrl/user/mark_all_as_read'),
      headers: _headers(withAuth: true),
    );

    if (response.statusCode != 200) {
      throw LemmyApiException(
        'Failed to mark all as read: ${response.statusCode}',
      );
    }
  }

  /// Mark comment reply as read.
  Future<CommentReplyView> markCommentReplyAsRead({
    required int commentReplyId,
    required bool read,
  }) async {
    final body = {'comment_reply_id': commentReplyId, 'read': read};

    final response = await _client.post(
      Uri.parse('$apiUrl/comment/mark_as_read'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommentReplyView.fromJson(
        json['comment_reply_view'] as Map<String, dynamic>,
      );
    } else {
      throw LemmyApiException(
        'Failed to mark reply as read: ${response.statusCode}',
      );
    }
  }

  /// Mark user mention as read.
  Future<PersonMentionView> markPersonMentionAsRead({
    required int personMentionId,
    required bool read,
  }) async {
    final body = {'person_mention_id': personMentionId, 'read': read};

    final response = await _client.post(
      Uri.parse('$apiUrl/user/mention/mark_as_read'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PersonMentionView.fromJson(
        json['person_mention_view'] as Map<String, dynamic>,
      );
    } else {
      throw LemmyApiException(
        'Failed to mark mention as read: ${response.statusCode}',
      );
    }
  }

  /// Get private messages.
  Future<List<PrivateMessageView>> getPrivateMessages({
    bool? unreadOnly,
    int? page,
    int? limit,
    int? creatorId,
  }) async {
    final queryParams = <String, String>{};
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (creatorId != null) queryParams['creator_id'] = creatorId.toString();
    if (_authToken != null) {
      queryParams['auth'] = _authToken!;
    }

    final uri = Uri.parse(
      '$apiUrl/private_message/list',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: _headers(withAuth: true, isGet: true),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['private_messages'] as List<dynamic>? ?? [];
      return list
          .map((e) => PrivateMessageView.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw LemmyApiException(
        'Failed to get private messages: ${response.statusCode}',
      );
    }
  }

  /// Create a private message.
  Future<PrivateMessageView> createPrivateMessage({
    required String content,
    required int recipientId,
  }) async {
    final body = {'content': content, 'recipient_id': recipientId};

    final response = await _client.post(
      Uri.parse('$apiUrl/private_message'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PrivateMessageView.fromJson(
        json['private_message_view'] as Map<String, dynamic>,
      );
    } else {
      throw LemmyApiException(
        'Failed to send private message: ${response.statusCode}',
      );
    }
  }

  /// Mark private message as read.
  Future<PrivateMessageView> markPrivateMessageAsRead({
    required int privateMessageId,
    required bool read,
  }) async {
    final body = {'private_message_id': privateMessageId, 'read': read};

    final response = await _client.post(
      Uri.parse('$apiUrl/private_message/mark_as_read'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PrivateMessageView.fromJson(
        json['private_message_view'] as Map<String, dynamic>,
      );
    } else {
      throw LemmyApiException(
        'Failed to mark message as read: ${response.statusCode}',
      );
    }
  }

  Future<bool> blockPerson({required int personId, required bool block}) async {
    final body = <String, dynamic>{'person_id': personId, 'block': block};

    final response = await _client.post(
      Uri.parse('$apiUrl/user/block'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['blocked'] as bool? ?? false;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Block/unblock person failed: ${response.statusCode}',
      );
    }
  }

  Future<bool> blockCommunity({
    required int communityId,
    required bool block,
  }) async {
    final body = <String, dynamic>{'community_id': communityId, 'block': block};

    final response = await _client.post(
      Uri.parse('$apiUrl/community/block'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['blocked'] as bool? ?? false;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Block/unblock community failed: ${response.statusCode}',
      );
    }
  }

  Future<bool> blockInstance({
    required int instanceId,
    required bool block,
  }) async {
    final body = <String, dynamic>{'instance_id': instanceId, 'block': block};

    final response = await _client.post(
      Uri.parse('$apiUrl/site/block'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['blocked'] as bool? ?? false;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Block/unblock instance failed: ${response.statusCode}',
      );
    }
  }

  Future<bool> createCommentReport({
    required int commentId,
    required String reason,
  }) async {
    final body = <String, dynamic>{'comment_id': commentId, 'reason': reason};

    final response = await _client.post(
      Uri.parse('$apiUrl/comment/report'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Report comment failed: ${response.statusCode}',
      );
    }
  }

  Future<CommunityView> getCommunity({int? id, String? name}) async {
    final queryParams = <String, String>{};
    if (id != null) queryParams['id'] = id.toString();
    if (name != null) queryParams['name'] = name;

    final uri = Uri.parse(
      '$apiUrl/community',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final communityView = CommunityView.fromJson(
        json['community_view'] as Map<String, dynamic>,
      );
      final modsJson = json['moderators'] as List? ?? [];
      return communityView.copyWith(
        moderators: modsJson
            .map((m) => CommunityModeratorView.fromJson(m))
            .toList(),
      );
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Failed to get community: ${response.statusCode}',
      );
    }
  }

  Future<CommunityView> followCommunity({
    required int communityId,
    required bool follow,
  }) async {
    final body = <String, dynamic>{
      'community_id': communityId,
      'follow': follow,
    };

    final response = await _client.post(
      Uri.parse('$apiUrl/community/follow'),
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CommunityView.fromJson(
        json['community_view'] as Map<String, dynamic>,
      );
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Failed to follow community: ${response.statusCode}',
      );
    }
  }

  /// General search for posts, comments, communities, and users.
  Future<SearchResult> search({
    required String query,
    String? type,
    String? sort,
    String? listingType,
    int? page,
    int? limit,
    int? communityId,
    String? communityName,
    bool? postTitleOnly,
  }) async {
    final queryParams = <String, String>{'q': query};
    if (type != null) queryParams['type_'] = type;
    if (sort != null) queryParams['sort'] = sort;
    if (listingType != null) queryParams['listing_type'] = listingType;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (communityId != null) {
      queryParams['community_id'] = communityId.toString();
    } else if (communityName != null) {
      queryParams['community_name'] = communityName;
    }
    if (postTitleOnly != null) {
      queryParams['post_title_only'] = postTitleOnly.toString();
    }

    final uri = Uri.parse(
      '$apiUrl/search',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SearchResult.fromJson(json);
    } else {
      throw LemmyApiException(
        'Failed to search: ${response.statusCode}. Body: ${response.body}',
      );
    }
  }

  Future<List<CommunityView>> listCommunities({
    String? type,
    String? sort,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type_'] = type;
    if (sort != null) queryParams['sort'] = sort;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (_authToken != null) queryParams['auth'] = _authToken!;

    final uri = Uri.parse(
      '$apiUrl/community/list',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: _headers(withAuth: _authToken != null, isGet: true),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['communities'] as List<dynamic>? ?? [];
      return list
          .map((e) => CommunityView.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw LemmyApiException(
        json['error']?.toString() ??
            'Failed to list communities: ${response.statusCode}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

// ── Supporting types ──────────────────────────────────────────────────────────

class GetPersonDetailsResponse {
  final PersonView personView;
  final List<CommentView> comments;
  final List<PostView> posts;
  final List<dynamic> moderates;

  GetPersonDetailsResponse({
    required this.personView,
    required this.comments,
    required this.posts,
    required this.moderates,
  });

  factory GetPersonDetailsResponse.fromJson(Map<String, dynamic> json) {
    return GetPersonDetailsResponse(
      personView: PersonView.fromJson(json['person_view']),
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => PostView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      moderates: json['moderates'] as List<dynamic>? ?? [],
    );
  }
}

class LemmyApiException implements Exception {
  final String message;
  LemmyApiException(this.message);

  @override
  String toString() => 'LemmyApiException: $message';
}
