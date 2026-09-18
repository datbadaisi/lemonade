import 'package:http/http.dart' as http;

final class TimeoutHttpClient extends http.BaseClient {
  TimeoutHttpClient(this._inner, this._timeout);

  final http.Client _inner;
  final Duration _timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _inner
      .send(request)
      .timeout(
        _timeout,
        onTimeout: () => throw http.ClientException(
          'Request timed out after ${_timeout.inSeconds}s'));

  @override
  void close() => _inner.close();
}
