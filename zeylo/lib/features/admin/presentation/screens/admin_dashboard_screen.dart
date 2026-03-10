import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void approveBusiness(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // 1. Move to active businesses
    await FirebaseFirestore.instance.collection('businesses').add(data);
    
    // 2. Delete from pending
    await doc.reference.delete();
    
    // 3. Update the user's role to 'verified_business'
    final submittedBy = data['submittedBy'] as String?;
    if (submittedBy != null && submittedBy.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(submittedBy).update({'role': 'business'});
    }
  }

  void rejectBusiness(DocumentSnapshot doc) async {
    await doc.reference.update({'status': 'rejected'});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_businesses')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingDocs = snapshot.data?.docs ?? [];

          if (pendingDocs.isEmpty) {
            return const Center(child: Text('No pending businesses to review.'));
          }

          return ListView.builder(
            itemCount: pendingDocs.length,
            itemBuilder: (context, index) {
              final doc = pendingDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Unknown Business',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Location: ${data['location'] ?? 'Not provided'}'),
                      const Divider(),
                      const Text('Original Description (By User):', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(data['original_desc'] ?? ''),
                      const Divider(),
                      const Text('Enhanced Description (By AI):', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(data['enhanced_desc'] ?? ''),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => rejectBusiness(doc),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => approveBusiness(doc),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Approve'),
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

