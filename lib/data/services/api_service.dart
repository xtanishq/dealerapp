import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String gender,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'gender': gender,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      
      if (responseData['success'] == false) {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
      
      // isko thk krdena
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<List<DealerNotification>> getNotifications({
    required String token,
    String? type,
    String? category,
    String? language,
    int skip = 0,
    int take = 10,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.notifications}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'type': type,
        'category': category,
        'language': language,
        'skip': skip,
        'take': take,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      final notificationsList = data['data']?['notification_data'] ?? [];
      
      return (notificationsList as List)
          .map((json) => DealerNotification.fromJson(json))
          .toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}

class UnauthorizedException implements Exception {}
