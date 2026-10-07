   import 'package:flutter/material.dart';

   import 'auth_service.dart';
   import 'issue_service.dart';

   const _categories = ['PLUMBING', 'ELECTRICAL', 'CLEANING', 'FURNITURE', 'OTHER'];
   const _priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];

   String pretty(String value) =>
       value[0] + value.substring(1).toLowerCase().replaceAll('_', ' ');

   class CreateIssueScreen extends StatefulWidget {
     final UserSession session;

     const CreateIssueScreen({super.key, required this.session});

     @override
     State<CreateIssueScreen> createState() => _CreateIssueScreenState();
   }

   class _CreateIssueScreenState extends State<CreateIssueScreen> {
     final _formKey = GlobalKey<FormState>();
     final _titleController = TextEditingController();
     final _descriptionController = TextEditingController();
     final _locationController = TextEditingController();
     String _category = 'PLUMBING';
     String _priority = 'MEDIUM';
     bool _loading = false;
     String? _error;

     @override
     void dispose() {
       _titleController.dispose();
       _descriptionController.dispose();
       _locationController.dispose();
       super.dispose();
     }

     Future<void> _submit() async {
       if (!_formKey.currentState!.validate()) return;

       setState(() {
         _loading = true;
         _error = null;
       });

       try {
         await issueService.createIssue(
           widget.session.token,
           title: _titleController.text,
           description: _descriptionController.text,
           category: _category,
           priority: _priority,
           location: _locationController.text,
         );
         if (!mounted) return;
         Navigator.of(context).pop(true); // true means "an issue was created"
       } on ApiException catch (e) {
         if (mounted) setState(() => _error = e.message);
       } finally {
         if (mounted) setState(() => _loading = false);
       }
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('Report an issue')),
         body: SafeArea(
           child: SingleChildScrollView(
             padding: const EdgeInsets.all(24),
             child: Form(
               key: _formKey,
               child: Column(
                 children: [
                   TextFormField(
                     controller: _titleController,
                     maxLength: 150,
                     textCapitalization: TextCapitalization.sentences,
                     decoration: const InputDecoration(
                       labelText: 'Title',
                       hintText: 'For example: Tap leaking',
                       border: OutlineInputBorder(),
                     ),
                     validator: (value) =>
                         (value == null || value.trim().isEmpty) ? 'Enter a title' : null,
                   ),
                   const SizedBox(height: 8),
                   TextFormField(
                     controller: _descriptionController,
                     maxLines: 4,
                     maxLength: 2000,
                     textCapitalization: TextCapitalization.sentences,
                     decoration: const InputDecoration(
                       labelText: 'Describe the problem',
                       alignLabelWithHint: true,
                       border: OutlineInputBorder(),
                     ),
                     validator: (value) => (value == null || value.trim().isEmpty)
                         ? 'Describe the problem'
                         : null,
                   ),
                   const SizedBox(height: 8),
                   TextFormField(
                     controller: _locationController,
                     maxLength: 150,
                     textCapitalization: TextCapitalization.words,
                     decoration: const InputDecoration(
                       labelText: 'Location',
                       hintText: 'For example: Block A, Floor 2',
                       border: OutlineInputBorder(),
                     ),
                     validator: (value) => (value == null || value.trim().isEmpty)
                         ? 'Enter the location'
                         : null,
                   ),
                   const SizedBox(height: 8),
                   DropdownButtonFormField<String>(
                     value: _category,
                     decoration: const InputDecoration(
                       labelText: 'Category',
                       border: OutlineInputBorder(),
                     ),
                     items: _categories
                         .map((c) => DropdownMenuItem(value: c, child: Text(pretty(c))))
                         .toList(),
                     onChanged: (value) => setState(() => _category = value!),
                   ),
                   const SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                     value: _priority,
                     decoration: const InputDecoration(
                       labelText: 'Priority',
                       border: OutlineInputBorder(),
                     ),
                     items: _priorities
                         .map((p) => DropdownMenuItem(value: p, child: Text(pretty(p))))
                         .toList(),
                     onChanged: (value) => setState(() => _priority = value!),
                   ),
                   if (_error != null) ...[
                     const SizedBox(height: 16),
                     Text(_error!, style: const TextStyle(color: Colors.red)),
                   ],
                   const SizedBox(height: 24),
                   SizedBox(
                     width: double.infinity,
                     child: FilledButton(
                       onPressed: _loading ? null : _submit,
                       child: _loading
                           ? const SizedBox(
                               height: 20,
                               width: 20,
                               child: CircularProgressIndicator(strokeWidth: 2),
                             )
                           : const Text('Submit'),
                     ),
                   ),
                 ],
               ),
             ),
           ),
         ),
       );
     }
   }