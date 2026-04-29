import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/models.dart';

class BffClient {
  final Uri baseUri;
  final http.Client _client;

  BffClient({
    required this.baseUri,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<SourceCapabilities>> listSources() async {
    final res = await _client.get(baseUri.resolve('/v1/sources'));
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('listSources failed: ${res.statusCode}');
    }
    final arr = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return arr.map(SourceCapabilities.fromJson).toList();
  }

  Future<List<Track>> search({
    required String q,
    List<SourceId>? sources,
  }) async {
    final params = <String, String>{'q': q};
    if (sources != null && sources.isNotEmpty) {
      params['sources'] = sources.map((s) => s.name).join(',');
    }
    final uri = baseUri.resolve('/v1/search').replace(queryParameters: params);
    final res = await _client.get(uri);
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('search failed: ${res.statusCode}');
    }
    final body = (jsonDecode(res.body) as Map).cast<String, dynamic>();
    final results = (body['results'] as List).cast<Map<String, dynamic>>();

    final items = <Track>[];
    for (final r in results) {
      final list = (r['items'] as List).cast<Map<String, dynamic>>();
      items.addAll(list.map(Track.fromJson));
    }
    return items;
  }

  Future<Track> getTrack({required SourceId source, required String trackId}) async {
    final uri = baseUri.resolve('/v1/tracks/${source.name}/$trackId');
    final res = await _client.get(uri);
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('getTrack failed: ${res.statusCode}');
    }
    return Track.fromJson((jsonDecode(res.body) as Map).cast<String, dynamic>());
  }
}

