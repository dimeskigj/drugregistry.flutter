import 'dart:convert';

import 'package:flutter_drug_registry/core/extensions/response_extensions.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../models/drug.dart';
import '../models/paged_result.dart';

class DrugService {
  final Duration _timeOut = const Duration(seconds: 10);

  Future<PagedResult<Drug>> searchDrugs(
    String query, {
    int page = 0,
    int size = 10,
  }) async {
    final queryParameters = {
      'query': query,
      'page': page.toString(),
      'size': size.toString(),
    };
    final url = Uri.https(
      Constants.baseApiUrl,
      'api/drugs/search',
      queryParameters,
    );

    final response = await http.get(url).timeout(_timeOut);
    response.ensureSuccessStatusCode();

    final json = jsonDecode(response.body);
    return PagedResult<Drug>.fromJson(json);
  }

  Future<List<Drug>> getDrugsByIds(List<String> ids) async {
    final url = Uri.https(Constants.baseApiUrl, 'api/drugs/by-ids');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(ids),
        )
        .timeout(_timeOut);

    response.ensureSuccessStatusCode();
    final json = jsonDecode(response.body) as List<dynamic>;
    return json.map((drugJson) => Drug.fromJson(drugJson)).toList();
  }

  Future<Drug?> getDrugByEan(String ean) async {
    final url = Uri.https(Constants.baseApiUrl, 'api/v2/drugs/ean/$ean');

    final response = await http.get(url).timeout(_timeOut);

    if (response.statusCode == 404) {
      return null;
    }

    response.ensureSuccessStatusCode();
    final json = jsonDecode(response.body);
    return Drug.fromJson(json);
  }
}
