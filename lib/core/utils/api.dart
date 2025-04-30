import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  Future<dynamic> get({required String url, required String? token}) async {
    Map<String, String> headers = {};

    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }

    http.Response response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'there is a proplem with statues code ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post({
    required String url,
    required dynamic body,
    String? token,
  }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final String? authToken = token ?? AuthManager.authToken;

    if (authToken != null) {
      headers.addAll({'Authorization': 'Bearer $authToken'});
      print('Using token for request: $authToken');
    } else {
      print('Warning: No auth token available for request to $url');
    }

    http.Response response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: headers,
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      print('Decoded Response: $decodedResponse');
      if (decodedResponse is Map<String, dynamic>) {
        return decodedResponse;
      } else {
        throw Exception(
            'Decoded response is not a JSON object: $decodedResponse');
      }
    } else {
      throw Exception(
          'There is a problem with status code ${response.statusCode} with body ${response.body}');
    }
  }

  Future<dynamic> put(
      {required String url,
      @required dynamic body,
      @required String? token}) async {
    Map<String, String> headers = {};

    headers.addAll({'Content-Type': 'application/x-www-form-urlencoded'});

    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }

    print(
      'url = $url, body = $body , token = $token ',
    );

    http.Response response = await http.put(
      Uri.parse(url),
      body: body,
      headers: headers,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      print(data);
      return data;
    } else
      throw Exception(
          'there is a proplem with statues code ${response.statusCode} with body ${jsonDecode(response.body)}');
  }
}
