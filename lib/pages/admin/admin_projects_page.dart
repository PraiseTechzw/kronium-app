import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends State<AdminProjectsPage> {
  final List<Map<String, dynamic>> projects = [
    {
      'title': 'Solar Farm Installation',
      'status': 'Ongoing',
      'progress': 65,
      'client': 'Green Energy Solutions Ltd.',
      'location': 'Harare, Zimbabwe',
      'description': '5MW solar farm installation for commercial energy production',
    },
    {
      'title': 'Industrial Greenhouse Complex',
      'status': 'Pending Approval',
      'progress': 0,
      'client': 'FreshFarms Zimbabwe',
      'location': 'Bulawayo, Zimbabwe',
      'description': '10-acre automated greenhouse for year-round vegetable production',
    },
    {
      'title': 'Commercial Steel Structure',
      'status': 'Completed',
      'progress': 100,
      'client': 'LogiStore Africa',
      'location': 'Mutare, Zimbabwe',
      'description': '15,000 sq ft steel warehouse with office complex',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Admin Projects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            tooltip: 'Add Project',
            onPressed: () {
              // TODO: Add project creation logic
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(project['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Client: ${project['client']}'),
                  Text('Location: ${project['location']}'),
                  Text('Status: ${project['status']}'),
                  Text('Progress: ${project['progress']}%'),
                  Text('Description: ${project['description']}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      // TODO: Edit logic
                      break;
                    case 'approve':
                      // TODO: Approve logic
                      break;
                    case 'progress':
                      // TODO: Update progress logic
                      break;
                    case 'delete':
                      // TODO: Delete logic
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                  const PopupMenuItem(value: 'progress', child: Text('Update Progress')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 