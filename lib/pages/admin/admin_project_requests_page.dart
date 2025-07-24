import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminProjectRequestsPage extends StatelessWidget {
  const AdminProjectRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projectRequests').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No project requests.'));
          }
          final requests = snapshot.data!.docs;
          return ListView.separated(
            itemCount: requests.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email'] ?? ''}'),
                    Text('Location: ${data['location'] ?? ''}'),
                    Text('Size: ${data['size'] ?? ''}'),
                    if (data['createdAt'] != null)
                      Text('Requested: ${data['createdAt'].toDate().toString().split(' ')[0]}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  tooltip: 'Mark as reviewed',
                  onPressed: () async {
                    await requests[index].reference.update({'reviewed': true});
                    Get.snackbar('Marked', 'Request marked as reviewed.', backgroundColor: Colors.green, colorText: Colors.white);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 