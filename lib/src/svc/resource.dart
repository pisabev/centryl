part of cl_base.svc.server;

class ResourceLoader {
  final dynamic _uri;

  ResourceLoader(this._uri);

  Uri get uri => (_uri is String) ? Uri.parse(_uri) : (_uri as Uri);

  /// Reads the resource content as a stream of bytes.
  Stream<List<int>> readAsStream() async* {
    final uri = await resolveUri(this.uri);
    yield* _readAsStream(uri);
  }

  /// Reads the resource content as a single list of bytes.
  Future<List<int>> readAsBytes() async {
    final uri = await resolveUri(this.uri);
    return _readAsBytes(uri);
  }

  /// Reads the resource content as a string.
  ///
  /// The content is decoded into a string using an [Encoding].
  /// If no encoding is provided, an encoding is chosen depending on the
  /// protocol and/or available metadata.
  Future<String> readAsString({Encoding encoding}) async {
    final uri = await resolveUri(this.uri);
    return _readAsString(uri, encoding: encoding);
  }

  /// Helper function for resolving to a non-relative, non-package URI.
  Future<Uri> resolveUri(Uri uri) {
    if (uri.scheme == 'package') {
      return Isolate.resolvePackageUri(uri).then((resolvedUri) {
        if (resolvedUri == null) {
          throw ArgumentError.value(uri, 'uri', 'Unknown package');
        }
        return resolvedUri;
      });
    }
    return Future<Uri>.value(Uri.base.resolveUri(uri));
  }

  /// Read the bytes of a URI as a stream of bytes.
  Stream<List<int>> _readAsStream(Uri uri) async* {
    if (uri.scheme == 'file') {
      yield* File.fromUri(uri).openRead();
      return;
    }
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      final response = await _httpGetBytes(uri);
      _throwIfFailed(response, uri);
      yield* response;
      return;
    }
    if (uri.scheme == 'data') {
      yield uri.data.contentAsBytes();
      return;
    }
    throw UnsupportedError('Unsupported scheme: $uri');
  }

  /// Read the bytes of a URI as a list of bytes.
  Future<List<int>> _readAsBytes(Uri uri) async {
    if (uri.scheme == 'file') {
      return File.fromUri(uri).readAsBytes();
    }
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      final response = await _httpGetBytes(uri);
      _throwIfFailed(response, uri);
      int length = response.contentLength;
      if (length < 0) length = 0;
      // Create empty buffer with capacity matching contentLength.
      final buffer = Uint8Buffer(length)..length = 0;
      // ignore: prefer_foreach
      await for (final bytes in response) buffer.addAll(bytes);
      return buffer.toList();
    }
    if (uri.scheme == 'data') {
      return uri.data.contentAsBytes();
    }
    throw UnsupportedError('Unsupported scheme: $uri');
  }

  /// Read the bytes of a URI as a string.
  Future<String> _readAsString(Uri uri, {Encoding? encoding}) async {
    if (uri.scheme == 'file') {
      encoding ??= utf8;
      return File.fromUri(uri).readAsString(encoding: encoding);
    }
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      final request = await HttpClient().getUrl(uri);
      // Prefer text/plain, text/* if possible, otherwise take whatever is there.
      request.headers.set(HttpHeaders.acceptHeader, 'text/plain, text/*, */*');
      if (encoding != null) {
        request.headers.set(HttpHeaders.acceptCharsetHeader, encoding.name);
      }
      final response = await request.close();
      _throwIfFailed(response, uri);
      encoding ??= Encoding.getByName(response.headers.contentType?.charset);
      if (encoding == null || encoding == latin1) {
        // Default to LATIN-1 if no encoding found.
        // Special case LATIN-1 since it is common and doesn't need decoding.
        var length = response.contentLength;
        if (length < 0) length = 0;
        // Create empty buffer with capacity matching contentLength.
        final buffer = Uint8Buffer(length)..length = 0;
        // ignore: prefer_foreach
        await for (final bytes in response) buffer.addAll(bytes);
        final byteList = buffer.buffer.asUint8List(0, buffer.length);
        return String.fromCharCodes(byteList);
      }
      return response.cast<List<int>>().transform(encoding.decoder).join();
    }
    if (uri.scheme == 'data') {
      return uri.data!.contentAsString(encoding: encoding);
    }
    throw UnsupportedError('Unsupported scheme: $uri');
  }

  final _sharedHttpClient = HttpClient()..maxConnectionsPerHost = 6;

  Future<HttpClientResponse> _httpGetBytes(Uri uri) async {
    final request = await _sharedHttpClient.getUrl(uri);
    request.headers
        .set(HttpHeaders.acceptHeader, 'application/octet-stream, */*');
    return request.close();
  }

  void _throwIfFailed(HttpClientResponse response, Uri uri) {
    final statusCode = response.statusCode;
    if (statusCode < HttpStatus.ok || statusCode > HttpStatus.noContent) {
      throw HttpException(response.reasonPhrase, uri: uri);
    }
  }
}
