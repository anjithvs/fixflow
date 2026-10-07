   import 'package:flutter/material.dart';

   import 'auth_service.dart';
   import 'create_issue_screen.dart';
   import 'issue_service.dart';
   import 'login_screen.dart';

   class HomeScreen extends StatefulWidget {
     final UserSession session;

     const HomeScreen({super.key, required this.session});

     @override
     State<HomeScreen> createState() => _HomeScreenState();
   }

   class _HomeScreenState extends State<HomeScreen> {
     late Future<List<Issue>> _future = _load();

     Future<List<Issue>> _load() => issueService.fetchIssues(widget.session.token);

     void _refresh() {
       setState(() {
         _future = _load();
       });
     }

     Future<void> _logout() async {
       await authService.logout();
       if (!mounted) return;
       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (_) => const LoginScreen()),
         (route) => false,
       );
     }

     Future<void> _openCreateScreen() async {
       final created = await Navigator.of(context).push<bool>(
         MaterialPageRoute(
           builder: (_) => CreateIssueScreen(session: widget.session),
         ),
       );
       if (created == true) _refresh();
     }

     Color _priorityColor(String priority) {
       switch (priority) {
         case 'URGENT':
           return Colors.red;
         case 'HIGH':
           return Colors.orange;
         case 'MEDIUM':
           return Colors.blue;
         default:
           return Colors.grey;
       }
     }

     String _formatDate(DateTime d) {
       String two(int n) => n.toString().padLeft(2, '0');
       return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
     }

     @override
     Widget build(BuildContext context) {
       final canReport = widget.session.role != 'TECHNICIAN';

       return Scaffold(
         appBar: AppBar(
           title: const Text('FixFlow'),
           actions: [
             Padding(
               padding: const EdgeInsets.only(right: 4),
               child: Center(child: Chip(label: Text(widget.session.role))),
             ),
             IconButton(
               icon: const Icon(Icons.logout),
               tooltip: 'Log out',
               onPressed: _logout,
             ),
           ],
         ),
         floatingActionButton: canReport
             ? FloatingActionButton.extended(
                 onPressed: _openCreateScreen,
                 icon: const Icon(Icons.add),
                 label: const Text('Report issue'),
               )
             : null,
         body: FutureBuilder<List<Issue>>(
           future: _future,
           builder: (context, snapshot) {
             if (snapshot.connectionState != ConnectionState.done) {
               return const Center(child: CircularProgressIndicator());
             }

             if (snapshot.hasError) {
               final error = snapshot.error;
               final message =
                   error is ApiException ? error.message : 'Something went wrong.';
               final expired = error is ApiException && error.sessionExpired;
               return Center(
                 child: Padding(
                   padding: const EdgeInsets.all(24),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Icon(Icons.error_outline, size: 56, color: Colors.red),
                       const SizedBox(height: 12),
                       Text(message, textAlign: TextAlign.center),
                       const SizedBox(height: 16),
                       FilledButton(
                         onPressed: expired ? _logout : _refresh,
                         child: Text(expired ? 'Log in again' : 'Try again'),
                       ),
                     ],
                   ),
                 ),
               );
             }

             final issues = snapshot.data!;

             if (issues.isEmpty) {
               return Center(
                 child: Padding(
                   padding: const EdgeInsets.all(24),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                       const SizedBox(height: 12),
                       Text(
                         canReport
                             ? 'No issues yet.\nTap "Report issue" to add one.'
                             : 'No issues assigned to you yet.',
                         textAlign: TextAlign.center,
                       ),
                     ],
                   ),
                 ),
               );
             }

             return RefreshIndicator(
               onRefresh: () async {
                 _refresh();
                 try {
                   await _future;
                 } catch (_) {
                   // The error is shown by the builder above.
                 }
               },
               child: ListView.builder(
                 padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                 itemCount: issues.length,
                 itemBuilder: (context, index) {
                   final issue = issues[index];
                   return Card(
                     child: Padding(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(issue.title,
                               style: const TextStyle(
                                   fontSize: 17, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 4),
                           Text('${issue.location} - ${pretty(issue.category)}'),
                           const SizedBox(height: 8),
                           Wrap(
                             spacing: 8,
                             children: [
                               Chip(
                                 label: Text(pretty(issue.status)),
                                 visualDensity: VisualDensity.compact,
                               ),
                               Chip(
                                 label: Text(pretty(issue.priority),
                                     style: const TextStyle(color: Colors.white)),
                                 backgroundColor: _priorityColor(issue.priority),
                                 visualDensity: VisualDensity.compact,
                               ),
                             ],
                           ),
                           const SizedBox(height: 4),
                           Text(
                             'By ${issue.reporterName} - ${_formatDate(issue.createdAt)}',
                             style: const TextStyle(color: Colors.grey, fontSize: 12),
                           ),
                         ],
                       ),
                     ),
                   );
                 },
               ),
             );
           },
         ),
       );
     }
   }