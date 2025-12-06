import 'package:flutter/material.dart';

class AdminProjectRequestsPage extends StatelessWidget {
  const AdminProjectRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Requests'),
      ),
      body: const Center(
        child: Text('No project requests available.'),
      ),
    );
  }
} 