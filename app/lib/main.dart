   import 'dart:convert';

   import 'package:flutter/material.dart';
   import 'package:http/http.dart' as http;

   // 10.0.2.2 is how the Android emulator reaches YOUR computer.
   const String baseUrl = 'http://10.0.2.2:8080';

   void main() {
     runApp(const FixFlowApp());
   }

   class FixFlowApp extends StatelessWidget {
     const FixFlowApp({super.key});

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'FixFlow',
         theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
         home: const HealthScreen(),
       );
     }
   }

   class HealthScreen extends StatefulWidget {
     const HealthScreen({super.key});

     @override
     State<HealthScreen> createState() => _HealthScreenState();
   }

   class _HealthScreenState extends State<HealthScreen> {
     bool _loading = false;
     String _message = 'Press the button to check the backend';
     bool _isError = false;

     Future<void> _checkBackend() async {
       setState(() {
         _loading = true;
         _isError = false;
       });

       try {
         final response = await http
             .get(Uri.parse('$baseUrl/actuator/health'))
             .timeout(const Duration(seconds: 5));

         final data = jsonDecode(response.body);
         setState(() {
           _message = 'Backend status: ${data['status']}';
         });
       } catch (e) {
         setState(() {
           _isError = true;
           _message = 'Cannot reach the backend. Is it running?';
         });
       } finally {
         setState(() {
           _loading = false;
         });
       }
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('FixFlow')),
         body: Center(
           child: Padding(
             padding: const EdgeInsets.all(24),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(
                   _isError ? Icons.error_outline : Icons.check_circle_outline,
                   size: 72,
                   color: _isError ? Colors.red : Colors.green,
                 ),
                 const SizedBox(height: 16),
                 Text(
                   _message,
                   textAlign: TextAlign.center,
                   style: const TextStyle(fontSize: 18),
                 ),
                 const SizedBox(height: 24),
                 _loading
                     ? const CircularProgressIndicator()
                     : FilledButton(
                         onPressed: _checkBackend,
                         child: const Text('Check backend'),
                       ),
               ],
             ),
           ),
         ),
       );
     }
   }