import 'dart:convert';

import 'package:http/http.dart' as http;

Future<http.Response> postTemperature(String temperature) {
  return http.post(
    Uri.parse('http://ec2-34-201-118-185.compute-1.amazonaws.com/api/temperature'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'value': temperature,
    }),
  );
}

Future<http.Response> postHumidity(String humidity) {
  return http.post(
    Uri.parse('http://ec2-34-201-118-185.compute-1.amazonaws.com/api/humidity'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'value': humidity,
    }),
  );
}