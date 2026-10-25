import 'dart:convert';

import 'package:http/http.dart' as http;

/// GET a JSON document, closing the client even when the response is bad.
///
/// Throws instead of returning null so [FutureBuilder] can show a retry state.
Future<dynamic> fetchJson(String url) async {
  final client = http.Client();
  try {
    final response = await client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode})');
    }
    return jsonDecode(response.body);
  } finally {
    client.close();
  }
}

/// DELETE a record and return the server's JSON body.
Future<dynamic> deleteJson(String url) async {
  final client = http.Client();
  try {
    final response = await client.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode})');
    }
    return jsonDecode(response.body);
  } finally {
    client.close();
  }
}

/// GET an enrichment that the deployed backend may not have yet.
///
/// `flaggedreports.php` ships with this build but only answers once it has been
/// uploaded, so a missing one must degrade to "no flags" rather than blank the
/// whole roster.
Future<dynamic> fetchJsonOrEmpty(String url) async {
  try {
    return await fetchJson(url);
  } catch (e) {
    return const [];
  }
}

/// Rows under the `data` key every TrachCare list endpoint returns.
List<dynamic> rowsOf(dynamic raw) {
  if (raw is List) return raw;
  final data = raw is Map ? raw['data'] : null;
  if (data is List) return data;
  return const [];
}
