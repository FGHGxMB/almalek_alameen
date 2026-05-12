// lib/ui/screens/settings/currency_history_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/firestore_keys.dart';

class CurrencyHistoryScreen extends StatelessWidget {
  const CurrencyHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل تغيير سعر الدولار'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(FirestoreKeys.currencyHistory).orderBy('date', descending: true).limit(50).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا يوجد سجلات لتغيير السعر بعد.'));

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final rate = data['rate'] ?? 0.0;
              final userName = data['user_name'] ?? 'مجهول';
              final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.track_changes, color: Colors.white)),
                  title: Text('تم التغيير إلى: ${NumberFormat('#,##0').format(rate)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                  subtitle: Text('بواسطة: $userName'),
                  trailing: Text(DateFormat('yyyy-MM-dd\nHH:mm a').format(date), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}