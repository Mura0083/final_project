import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpHelper {
  static String movieNightBaseUrl = 'https://movie-night-api.onrender.com';

  static startSession(String? deviceId) async {
    var response = await http
        .get(Uri.parse('$movieNightBaseUrl/start-session?device_id=$deviceId'));
    return jsonDecode(response.body);
  }

  static joinSession(String? deviceId, int code) async {
    var response = await http.get(Uri.parse(
        '$movieNightBaseUrl/join-session?device_id=$deviceId&code=$code'));
    return jsonDecode(response.body);
  }

  static voteMovie(String sessionId, movieId, bool vote) async {
    final uri = Uri.parse('$movieNightBaseUrl/vote-movie').replace(
      queryParameters: {
        'session_id': sessionId,
        'movie_id': movieId.toString(),
        'vote': vote.toString(),
      },
    );

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to vote');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error voting: $e');
      }
      throw Exception('Failed to vote');
    }
  }
}
