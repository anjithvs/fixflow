   import 'dart:convert';

   import 'package:flutter_secure_storage/flutter_secure_storage.dart';
   import 'package:http/http.dart' as http;

   import 'config.dart';

   /// An error with a message that is safe to show to the user.
   class AuthException implements Exception {
     final String message;
     AuthException(this.message);
   }

   /// Who is logged in right now.
   class UserSession {
     final String token;
     final String email;
     final String role; // RESIDENT, TECHNICIAN or ADMIN

     UserSession({required this.token, required this.email, required this.role});
   }

   class AuthService {
     static const _storage = FlutterSecureStorage();
     static const _tokenKey = 'auth_token';
     static const _jsonHeaders = {'Content-Type': 'application/json'};

     Future<UserSession> login(String email, String password) {
       return _authenticate('/api/auth/login', {
         'email': email.trim(),
         'password': password,
       });
     }

     Future<UserSession> register(String fullName, String email, String password) {
       return _authenticate('/api/auth/register', {
         'fullName': fullName.trim(),
         'email': email.trim(),
         'password': password,
       });
     }

     /// Called when the app starts. Returns the saved session if the saved
     /// token is still valid, otherwise null (meaning: show the login screen).
     Future<UserSession?> restoreSession() async {
       final token = await _storage.read(key: _tokenKey);
       if (token == null) return null;

       try {
         final response = await http
             .get(
               Uri.parse('$baseUrl/api/me'),
               headers: {'Authorization': 'Bearer $token'},
             )
             .timeout(const Duration(seconds: 10));

         if (response.statusCode == 200) {
           final data = jsonDecode(response.body);
           return UserSession(
             token: token,
             email: data['email'],
             role: (data['role'] as String).replaceFirst('ROLE_', ''),
           );
         }
         // Token expired or invalid: forget it.
         await _storage.delete(key: _tokenKey);
         return null;
       } catch (_) {
         return null;
       }
     }

     Future<void> logout() async {
       await _storage.delete(key: _tokenKey);
     }

     Future<UserSession> _authenticate(String path, Map<String, String> body) async {
       http.Response response;
       try {
         response = await http
             .post(
               Uri.parse('$baseUrl$path'),
               headers: _jsonHeaders,
               body: jsonEncode(body),
             )
             .timeout(const Duration(seconds: 10));
       } catch (_) {
         throw AuthException('Cannot reach the server. Check your connection.');
       }

       if (response.statusCode == 200 || response.statusCode == 201) {
         final data = jsonDecode(response.body);
         await _storage.write(key: _tokenKey, value: data['token']);
         return UserSession(
           token: data['token'],
           email: data['email'],
           role: data['role'],
         );
       }

       switch (response.statusCode) {
         case 400:
           throw AuthException('Please check your details. The password needs 8 or more characters.');
         case 401:
           throw AuthException('Invalid email or password.');
         case 409:
           throw AuthException('This email is already registered.');
         default:
           throw AuthException('Something went wrong (code ${response.statusCode}).');
       }
     }
   }

   // One shared copy that every screen uses.
   final authService = AuthService();