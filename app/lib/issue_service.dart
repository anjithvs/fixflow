   import 'dart:convert';

   import 'package:http/http.dart' as http;

   import 'config.dart';

   /// An error with a message that is safe to show to the user.
   class ApiException implements Exception {
     final String message;
     final bool sessionExpired;

     ApiException(this.message, {this.sessionExpired = false});
   }

   class Issue {
     final int id;
     final String title;
     final String description;
     final String category;
     final String priority;
     final String status;
     final String location;
     final String reporterName;
     final String? assignedToName;
     final DateTime createdAt;

     Issue({
       required this.id,
       required this.title,
       required this.description,
       required this.category,
       required this.priority,
       required this.status,
       required this.location,
       required this.reporterName,
       required this.assignedToName,
       required this.createdAt,
     });

     factory Issue.fromJson(Map<String, dynamic> json) {
       return Issue(
         id: json['id'],
         title: json['title'],
         description: json['description'],
         category: json['category'],
         priority: json['priority'],
         status: json['status'],
         location: json['location'],
         reporterName: json['reporterName'],
         assignedToName: json['assignedToName'],
         createdAt: DateTime.parse(json['createdAt']).toLocal(),
       );
     }
   }

   class IssueService {
     Map<String, String> _headers(String token) => {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
         };

     Future<List<Issue>> fetchIssues(String token) async {
       http.Response response;
       try {
         response = await http
             .get(Uri.parse('$baseUrl/api/issues'), headers: _headers(token))
             .timeout(const Duration(seconds: 10));
       } catch (_) {
         throw ApiException('Cannot reach the server. Check your connection.');
       }

       _checkStatus(response);

       final list = jsonDecode(response.body) as List<dynamic>;
       return list.map((item) => Issue.fromJson(item as Map<String, dynamic>)).toList();
     }

     Future<Issue> createIssue(
       String token, {
       required String title,
       required String description,
       required String category,
       required String priority,
       required String location,
     }) async {
       http.Response response;
       try {
         response = await http
             .post(
               Uri.parse('$baseUrl/api/issues'),
               headers: _headers(token),
               body: jsonEncode({
                 'title': title.trim(),
                 'description': description.trim(),
                 'category': category,
                 'priority': priority,
                 'location': location.trim(),
               }),
             )
             .timeout(const Duration(seconds: 10));
       } catch (_) {
         throw ApiException('Cannot reach the server. Check your connection.');
       }

       _checkStatus(response);
       return Issue.fromJson(jsonDecode(response.body));
     }

     void _checkStatus(http.Response response) {
       if (response.statusCode == 200 || response.statusCode == 201) return;

       if (response.statusCode == 401) {
         throw ApiException('Your session expired. Please log in again.',
             sessionExpired: true);
       }
       if (response.statusCode == 400) {
         throw ApiException('Please check the details you entered.');
       }
       throw ApiException('Something went wrong (code ${response.statusCode}).');
     }
   }

   final issueService = IssueService();