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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Icon(Icons.assignment, color: Colors.blue[800]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'No Name',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  data['email'] ?? '',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (data['reviewed'] == true)
                            Chip(
                              label: const Text('Reviewed'),
                              backgroundColor: Colors.green[50],
                              labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            )
                          else
                            Chip(
                              label: const Text('Pending'),
                              backgroundColor: Colors.orange[50],
                              labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: Colors.deepPurple),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data['location'] ?? '',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Icon(Icons.category, size: 18, color: Colors.teal),
                          const SizedBox(width: 6),
                          Text(
                            data['category'] ?? '-',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.straighten, size: 18, color: Colors.indigo),
                          const SizedBox(width: 6),
                          Text(
                            data['size'] ?? '',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Spacer(),
                          if (data['createdAt'] != null)
                            Text(
                              'Requested: ${data['createdAt'].toDate().toString().split(' ')[0]}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: 'Mark as reviewed',
                            child: IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                              onPressed: () async {
                                await requests[index].reference.update({'reviewed': true});
                                Get.snackbar('Marked', 'Request marked as reviewed.', backgroundColor: Colors.green, colorText: Colors.white);
                              },
                            ),
                          ),
                          Tooltip(
                            message: 'Approve & Create Project',
                            child: IconButton(
                              icon: const Icon(Icons.add_box, color: Colors.blue, size: 28),
                              onPressed: () async {
                                Get.toNamed('/admin-projects', arguments: {
                                  'requestData': data,
                                  'requestId': requests[index].id,
                                });
                              },
                            ),
                          ),
                          Tooltip(
                            message: 'Delete Request',
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                              onPressed: () async {
                                await requests[index].reference.delete();
                                Get.snackbar('Deleted', 'Request deleted.', backgroundColor: Colors.red, colorText: Colors.white);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 