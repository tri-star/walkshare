import 'package:flutter/material.dart';

/// アプリケーションが開くページの情報を表すオブジェクト。
/// ルーターはこのオブジェクトの履歴を積み上げてページ遷移履歴を管理する。
class AppLocation {
  List<String> pathSegments = [];

  Map<String, String> parameters = {};

  Map<String, String> query = {};

  String get signature => toPath();

  AppLocation();

  AppLocation.fromPathString(String path) {
    var uri = Uri.parse(path);
    var result = UriPathParser.parse(signature, uri);
    if (!result.success) {
      throw ArgumentError('無効なパスが指定されました: $path');
    }

    AppLocation.fromPathParseResult(result);
  }

  AppLocation.fromPathParseResult(ParseResult parseResult) {
    pathSegments = parseResult.segments;
    parameters = parseResult.parameters;
  }

  String toPath() {
    return '/' + pathSegments.join('/');
  }

  RouteInformation toRouteInformation() {
    return RouteInformation(location: toPath());
  }
}

class ParseResult {
  bool success;
  List<String> segments;
  Map<String, String> parameters;
  Map<String, String> queries;

  ParseResult(this.success, List<String>? segments,
      Map<String, String>? parameters, Map<String, String>? queries)
      : segments = segments ?? [],
        parameters = parameters ?? {},
        queries = queries ?? {};
}

/// URIを/a/b/:id のようなプレースホルダを考慮してパースし、解析できたか、
/// 解析したパラメータは何だったかを返す。
class UriPathParser {
  static ParseResult parse(String pathDefinition, Uri uri) {
    var result = ParseResult(false, [], {}, {});
    result.queries = uri.queryParameters;
    var normalizedPathDefinition = _normalizePath(pathDefinition);
    var definitionSegments = normalizedPathDefinition
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (definitionSegments.length != uri.pathSegments.length) {
      return result;
    }

    for (var i = 0; i < definitionSegments.length; i++) {
      var uriSegment = uri.pathSegments[i];
      if (_isParameterSegment(definitionSegments[i])) {
        result.parameters[_parameterName(definitionSegments[i])] = uriSegment;
      } else {
        if (definitionSegments[i] != uriSegment) {
          return ParseResult(false, [], {}, {});
        }
      }
      result.segments.add(uriSegment);
    }
    result.success = true;
    return result;
  }

  static bool _isParameterSegment(String segment) {
    return segment.startsWith(':');
  }

  static String _parameterName(String segment) {
    return segment.substring(1);
  }

  static String _normalizePath(String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return path;
  }
}

class UriPathBuilder {
  static String build(String signature,
      {Map<String, String>? parameters, Map<String, String>? queries}) {
    var segments = signature.split('/');
    var formattedSegments = [];
    for (final segment in segments) {
      if (parameters != null && _isParameterSegment(segment)) {
        var paramName = _parameterName(segment);
        if (parameters[paramName] == null) {
          throw ArgumentError('パラメータが指定されていません: $paramName');
        }
        formattedSegments.add(parameters[paramName]);
      } else {
        formattedSegments.add(segment);
      }
    }

    var uri = segments.join('/');

    var queryStrings = [];
    if (queries != null && queries.isNotEmpty) {
      for (var q in queries.entries) {
        queryStrings.add('${q.key}=${q.value}');
      }
      uri += '?' + queryStrings.join('&');
    }

    return uri;
  }

  static bool _isParameterSegment(String segment) {
    return segment.startsWith(':');
  }

  static String _parameterName(String segment) {
    return segment.substring(1);
  }
}
